//
//  DataManager.swift
//  VigilSecVPN
//
//  Created by hyunho lee on 10/2/23.
//

import SwiftUI
import CoreData
import ParseSwift
import Foundation
import PurchaseKit
import NetworkExtension

/// Main data manager for the app
class DataManager: NSObject, ObservableObject {

    /// Dynamic properties that the UI will react to
    @Published var fullScreenMode: FullScreenMode?
    @Published var showLocationsFlow: Bool = false
    @Published var currentContinent: Continent = .northAmerica
    @Published var didAnimateContinents: Bool = false
    @Published var selectedServer: ServerModel?
    @Published var customServersData: [ServerModel] = [ServerModel]()
    @Published var countriesData: [CountryModel] = [CountryModel]()
    @Published var serversData: [ServerModel] = [ServerModel]()
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var downloadSpeed: String = "--"
    @Published var uploadSpeed: String = "--"

    /// Dynamic properties that the UI will react to AND store values in UserDefaults
    @AppStorage("didAcceptPrivacyTerms") var didAcceptPrivacyTerms: Bool = false
    @AppStorage("lastSelectedServer") var lastSelectedServer: String = ""
    @AppStorage("sessionStartTime") var sessionStartTime: String = ""
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false {
        didSet { Interstitial.shared.isPremiumUser = isPremiumUser }
    }

    /// Core Data container with the database model
    private let container: NSPersistentContainer = NSPersistentContainer(name: "Database")

    /// VPN Manager
    private let manager: NEVPNManager = NEVPNManager.shared()

    /// Default init method. Load the Core Data container
    init(preview: Bool = true) {
        super.init()
        if preview { container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null") }
        container.loadPersistentStores { _, _ in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }

        /// Fetch VPN Servers and Countries from Back4App
        /// Check current VPN Connection status and observe status changes
        if !preview {
            checkCurrentVPNConfiguration()
            manager.localizedDescription = AppConfig.appName
            NotificationCenter.default.addObserver(forName: .NEVPNStatusDidChange, object: nil, queue: nil) { _ in
                DispatchQueue.main.async { self.checkVPNConnectionStatus() }
            }
        }

        /// Show privacy terms
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if !self.didAcceptPrivacyTerms { self.fullScreenMode = .privacy }
        }

        /// Verify auto-renewable subscriptions receipt
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.verifySubscriptionReceipt()
        }
    }

    /// Verify subscription receipt
    private func verifySubscriptionReceipt() {
        var verifiedProductIDs: [String: Bool] = [String: Bool]()
        PKManager.shared.productIdentifiers.forEach { productId in
            PKManager.verifySubscription(identifier: productId) { _, status, _ in
                DispatchQueue.main.async {
                    verifiedProductIDs[productId] = status == .success
                    if verifiedProductIDs[AppConfig.oneMonthProductId] != nil
                        && verifiedProductIDs[AppConfig.oneYearProductId] != nil {
                        self.isPremiumUser = verifiedProductIDs.map({ $0.value }).contains(true)
                    }
                }
            }
        }
    }
}

// MARK: - Handle Custom Servers CoreData
extension DataManager {

    /// Delete a custom server
    /// - Parameter index: server index from the list
    func deleteServer(atIndex index: Int) {
        presentAlert(title: "Are you sure?", message: "If you delete this server, you won't be able to restore. You can only re-create it again.", primaryAction: .Cancel,
                     secondaryAction: .init(title: "Delete", style: .destructive, handler: { _ in
            self.deleteServer(withAddress: self.customServersData[index].address)
        }))
    }

    /// Delete a custom server from CoreData
    /// - Parameter address: server address to be deleted
    func deleteServer(withAddress address: String) {
        let serverRequest: NSFetchRequest<ServerEntity> = ServerEntity.fetchRequest()
        serverRequest.predicate = NSPredicate(format: "address = %@", address)
        if let matchingResult = try? self.container.viewContext.fetch(serverRequest).first {
            self.container.viewContext.delete(matchingResult)
            try? self.container.viewContext.save()
            self.fetchCustomServers()
        }
    }

    /// Save server to CoreData
    /// - Parameter model: server model
    func saveServer(model: ServerModel) {
        //guard isPremiumUser else { fullScreenMode = .premium; return }
        if customServersData.contains(where: { $0.address == model.address }) {
            presentAlert(title: "Existing Server", message: "You already have a server with this address", primaryAction: .Cancel)
        } else {
            if model.isValid {
                let serverEntity: ServerEntity = ServerEntity(context: container.viewContext)
                serverEntity.date = Date()
                serverEntity.address = model.address
                serverEntity.username = model.username
                serverEntity.password = model.password
                serverEntity.preSharedKey = model.preSharedKey
                try? container.viewContext.save()
                fetchCustomServers()
            } else {
                presentAlert(title: "Missing Information", message: "You must fill out all these fields", primaryAction: .OK)
            }
        }
    }

    /// Fetch all custom servers from CoreData
    func fetchCustomServers() {
        let serverRequest: NSFetchRequest<ServerEntity> = ServerEntity.fetchRequest()
        serverRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        if let results = try? self.container.viewContext.fetch(serverRequest) {
            DispatchQueue.main.async {
                self.customServersData = results.compactMap { .from($0) }
            }
        }
    }
}

// MARK: - Fetch VPN Servers Back4App
extension DataManager {

    /// Fetch all countries data from Back4App
    func fetchVPNCountries() {
        VPNCountry.query().findAll { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    print("data : ",data)
                    let countries = data.compactMap { $0.model }
                    self.countriesData = countries.filter { country in
                        self.serversData.contains(where: { $0.countryId == country.id })
                    }
                    self.countriesData = self.countriesData.sorted(by: { $0.id < $1.id })
                case .failure(let failure):
                    presentAlert(title: "VPN Countries", message: "\(failure.message)", primaryAction: .OK)
                }
            }
        }
    }

    /// Fetch all servers data from Back4App
    @objc func fetchVPNServers() {
        VPNServer.query().findAll { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.serversData = data.compactMap { $0.model }
                    self.selectedServer = self.serversData.first(where: { $0.address == self.lastSelectedServer })
                    self.fetchVPNCountries()
                case .failure(let failure):
                    presentAlert(title: "VPN Servers", message: "\(failure.message)", primaryAction: .OK)
                }
            }
        }
    }
}

// MARK: - Handle VPN Connection
extension DataManager {

    /// Connect (or disconnect) selected server
    func connect() {
        UIImpactFeedbackGenerator().impactOccurred()
        guard let server = selectedServer else {
            presentAlert(title: "Choose Location", message: "You must choose a server to connect", primaryAction: .OK)
            return
        }

        /// Update initial connection status for the UI
        switch connectionStatus {
        case .connected, .connecting:
            connectionStatus = .disconnecting
        case .disconnected, .disconnecting:
            connectionStatus = .connecting
        }

        /// Disconnect if needed
        guard connectionStatus == .connecting else {
            savePreferences { saveErrorMessage in
                if let error = saveErrorMessage {
                    self.presentVPNError(title: "VPN Connection", message: error)
                } else {
                    self.uploadSpeed = "--"
                    self.downloadSpeed = "--"
                    self.manager.connection.stopVPNTunnel()
                }
            }
            return
        }

        /// Load preferences, then save the new VPN preferences and start tunnel
        loadProfile { loadErrorMessage in
            if let error = loadErrorMessage {
                self.presentVPNError(title: "VPN Preferences", message: error)
            } else {
                /// Save server credentials to keychaing
                let keychain: KeychainManager = KeychainManager()
                let passwordKeychainKey: String = "VPN_PASSWORD"
                let preSharedKeyKeychainKey: String = "VPN_PSK"
                keychain.save(key: passwordKeychainKey, value: server.password)
                keychain.save(key: preSharedKeyKeychainKey, value: server.preSharedKey)

                /// Setup the IPSec VPN protocol configurations
                let protocolConfiguration = NEVPNProtocolIPSec()
                protocolConfiguration.username = server.username
                protocolConfiguration.serverAddress = server.address
                protocolConfiguration.authenticationMethod = NEVPNIKEAuthenticationMethod.sharedSecret
                protocolConfiguration.passwordReference = keychain.load(key: passwordKeychainKey)
                protocolConfiguration.sharedSecretReference = keychain.load(key: preSharedKeyKeychainKey)
                protocolConfiguration.useExtendedAuthentication = true
                protocolConfiguration.disconnectOnSleep = false

                /// Configure the VPN Manager with the IPSec VPN protocol configurations
                self.manager.protocolConfiguration = protocolConfiguration
                self.manager.isOnDemandEnabled = false
                self.manager.isEnabled = true
                self.savePreferences { saveErrorMessage in
                    if let error = saveErrorMessage {
                        self.presentVPNError(title: "VPN Connection", message: error)
                    } else {
                        self.startVPNTunnel()
                    }
                }
            }
        }
    }

    /// Update session start/end time
    private func updateSession() {
        if connectionStatus == .connected, sessionStartTime.isEmpty {
            sessionStartTime = Date().string()
        } else if connectionStatus == .disconnected {
            sessionStartTime = ""
        }
    }

    /// Check current VPN configuration and connection status
    private func checkCurrentVPNConfiguration() {
        loadProfile { _ in
            DispatchQueue.main.async {
                self.checkVPNConnectionStatus()
                self.lastSelectedServer = self.manager.protocolConfiguration?.serverAddress ?? ""
                self.performSelector(inBackground: #selector(self.fetchVPNServers), with: nil)
            }
        }
    }

    /// Loads the current VPN configuration from the caller's VPN preferences
    /// - Parameter completion: returns an error message if failed to load preferences
    private func loadProfile(completion: ((_ errorMessage: String?) -> Void)?) {
        manager.protocolConfiguration = nil
        manager.loadFromPreferences { preferencesError in
            if let error = preferencesError {
                completion?(error.localizedDescription)
            } else {
                completion?(nil)
            }
        }
    }

    /// Saves the VPN configuration in the caller's VPN preferences
    /// - Parameter completion: returns an error message if failed to load preferences
    private func savePreferences(completion: ((_ errorMessage: String?) -> Void)?) {
        manager.saveToPreferences { preferencesError in
            if let error = preferencesError {
                completion?(error.localizedDescription)
            } else {
                completion?(nil)
            }
        }
    }

    /// Present VPN Connection error message
    private func presentVPNError(title: String, message: String) {
        presentAlert(title: title, message: message, primaryAction: .Cancel)
        DispatchQueue.main.async { self.connectionStatus = .disconnected }
    }

    /// Check VPN Manager connection status
    @objc private func checkVPNConnectionStatus() {
        switch manager.connection.status {
        case .connected:
            connectionStatus = .connected
            lastSelectedServer = selectedServer?.address ?? ""
            startSpeedTest()
            updateSession()
        case .connecting, .reasserting:
            connectionStatus = .connecting
        case .disconnecting:
            connectionStatus = .disconnecting
        default:
            connectionStatus = .disconnected
            updateSession()
        }
    }

    /// Start the VPN tunnel using the current VPN configuration
    private func startVPNTunnel() {
        do {
            try manager.connection.startVPNTunnel()
        } catch NEVPNError.configurationInvalid {
            presentVPNError(title: "VPN Tunnel", message: "Failed to start tunnel due to invalid configuration.")
        } catch NEVPNError.configurationDisabled {
            presentVPNError(title: "VPN Tunnel", message: "Failed to start tunnel due to disabled configuration.")
        } catch {
            presentVPNError(title: "VPN Tunnel", message: "Failed to start tunnel. Try again later.")
        }
    }
}

// MARK: - Speed Test handling
extension DataManager {

    /// Start speed test after a successful VPN connection
    func startSpeedTest() {
        guard downloadSpeed == "--" || uploadSpeed == "--" else { return }
        SpeedTestManager.checkDownloadSpeed { downloadSpeedResult in
            DispatchQueue.main.async {
                if let download = downloadSpeedResult { self.downloadSpeed = download }
            }
            SpeedTestManager.checkUploadSpeed { uploadSpeedResult in
                DispatchQueue.main.async {
                    if let upload = uploadSpeedResult { self.uploadSpeed = upload }
                }
            }
        }
    }
}
