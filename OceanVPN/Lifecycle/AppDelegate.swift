//
//  AppDelegate.swift
//  VigilSecVPN
//
//  Created by hyunho lee on 10/2/23.
//

import UIKit
import ParseSwift
import Foundation
import PurchaseKit
import GoogleMobileAds
import AppTrackingTransparency

/// App Delegate file in SwiftUI
class AppDelegate: NSObject, UIApplicationDelegate {
    
    private var applicationId: String = "" {
        didSet { UserDefaults.standard.setValue(applicationId, forKey: "applicationId") }
    }
    
    private var isFreshInstall: Bool = true {
        didSet { UserDefaults.standard.setValue(false, forKey: "isFreshInstall") }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if applicationId.isEmpty { applicationId = AppConfig.applicationId }
        configureBack4AppServer()
        if isFreshInstall { isFreshInstall = false }
        PKManager.configure(sharedSecret: AppConfig.appSecret)
        PKManager.loadProducts(identifiers: [AppConfig.oneYearProductId, AppConfig.oneMonthProductId])
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { _ in self.requestIDFA() }
        return true
    }

    /// Display the App Tracking Transparency authorization request for accessing the IDFA
    func requestIDFA() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ATTrackingManager.requestTrackingAuthorization { _ in
                GADMobileAds.sharedInstance().start(completionHandler: nil)
            }
        }
    }

    /// Configure Parse (Back4App)
    private func configureBack4AppServer() {
        func saveInstallationObject() {
            ParseAppInstallation.current?.delete(completion: { _ in
                ParseAppInstallation.current?.save(completion: { result in
                    switch result {
                    case .success(_): print("Successfully saved installation on server")
                    case .failure(let error): print("Failed to save installation on server: \(error)")
                    }
                })
            })
        }
        
        let configuration = ParseConfiguration(applicationId: AppConfig.applicationId,
                                               clientKey: AppConfig.clientKey, serverURL: AppConfig.serverURL)
        ParseSwift.initialize(configuration: configuration)
        
        if isFreshInstall || applicationId != AppConfig.applicationId {
            try? AnonymousUser.logout()
            saveInstallationObject()
        } else {
            saveInstallationObject()
        }
        
        if AnonymousUser.current == nil {
            _ = try? AnonymousUser.signup(username: UUID().uuidString, password: UUID().uuidString)
        }
    }
}

// MARK: - Google AdMob Interstitial - Support class
class Interstitial: NSObject, GADFullScreenContentDelegate {
    var isPremiumUser: Bool = UserDefaults.standard.bool(forKey: "isPremiumUser")
    private var interstitial: GADInterstitialAd?
    static var shared: Interstitial = Interstitial()

    /// Default initializer of interstitial class
    override init() {
        super.init()
        loadInterstitial()
    }

    /// Request AdMob Interstitial ads
    func loadInterstitial() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: AppConfig.adMobAdId, request: request, completionHandler: { [self] ad, error in
            if ad != nil { interstitial = ad }
            interstitial?.fullScreenContentDelegate = self
        })
    }

    func showInterstitialAds() {
        if self.interstitial != nil, !isPremiumUser {
            guard let root = rootController else { return }
            self.interstitial?.present(fromRootViewController: root)
        }
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadInterstitial()
    }
}

// MARK: - Parse Installation model
struct ParseAppInstallation: ParseInstallation {
    var deviceType: String?
    var installationId: String?
    var deviceToken: String?
    var badge: Int?
    var timeZone: String?
    var channels: [String]?
    var appName: String?
    var appIdentifier: String?
    var appVersion: String?
    var parseVersion: String?
    var localeIdentifier: String?
    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseSwift.ParseACL?
}

// MARK: - Parse User model
struct AnonymousUser: ParseUser {
    var username: String?
    var email: String?
    var emailVerified: Bool?
    var password: String?
    var authData: [String : [String : String]?]?
    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseSwift.ParseACL?
}
