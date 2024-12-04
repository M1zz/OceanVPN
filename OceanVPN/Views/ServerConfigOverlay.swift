//
//  ServerConfigOverlay.swift
//  VigilSecVPN
//
//  Created by hyunho lee on 10/2/23.
//

import SwiftUI

/// Shows the server configurations for custom servers
struct ServerConfigOverlay: View {

    @EnvironmentObject var manager: DataManager
    @State private var address: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var preSharedKey: String = ""
    @State var saveCompletion: (() -> Void)?

    // MARK: - Main rendering function
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                RoundedCorner(radius: 36, corners: [.topLeft, .topRight])
                    .foregroundColor(.secondaryBackgroundColor).ignoresSafeArea()
                VStack {
                    Capsule().frame(width: 60, height: 7).offset(y: -12)
                    Spacer()
                }.foregroundColor(.secondaryBackgroundColor)
                VStack {
                    Text("VPN Server Setup")
                        .font(.system(size: 25, weight: .semibold))
                    Text("Customize IPSec server settings for your VPN")
                        .font(.system(size: 15, weight: .light)).opacity(0.75)
                    VStack(spacing: UIDevice.current.hasNotch ? 20 : 15) {
                        TextInput(title: "Server Address", placeholder: "192.0.0.1", text: $address)
                        TextInput(title: "Username", placeholder: "vpnuser", text: $username)
                        TextInput(title: "Password", placeholder: "Password for VPN", text: $password)
                        TextInput(title: "Pre-Shared Key", placeholder: "Pre-Shared Key (PSK)", text: $preSharedKey)
                    }.padding(.vertical, 15)
                    SaveServerDetails
                }
                .multilineTextAlignment(.center).padding().padding(.top)
                .foregroundColor(.primaryTextColor)
            }.frame(height: 460.0)
        }
    }

    /// Custom text input field
    private func TextInput(title: String, placeholder: String,
                           text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: -8) {
            Text(title).padding(2).background(Color.secondaryBackgroundColor)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .zIndex(1).padding(.leading, 8)
            TextField("", text: text).padding(10).background(
                RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 1.5)
                    .foregroundColor(text.wrappedValue.isEmpty ? .tertiaryBackgroundColor : .primaryTextColor)
            ).zIndex(0).multilineTextAlignment(.leading).background(
                HStack {
                    Text(placeholder).foregroundColor(.secondaryTextColor)
                        .opacity(text.wrappedValue.isEmpty ? 1 : 0)
                    Spacer()
                }.padding(.leading, 10).allowsHitTesting(false)
            ).autocorrectionDisabled().tint(.primaryTextColor)
        }.foregroundColor(.primaryTextColor)
    }

    /// Save VPN Server details button
    private var SaveServerDetails: some View {
        Button {
            hideKeyboard()
            manager.saveServer(model: .init(countryId: 0, address: address, password: password, username: username, preSharedKey: preSharedKey))
            saveCompletion?()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                address = ""; username = ""; password = ""; preSharedKey = ""
            }
        } label: {
            ZStack {
                Color.accentColor.cornerRadius(10)
                Text(manager.isPremiumUser ? "Save VPN Server" : "Upgrade to Premium")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryTextColor)
            }
        }.frame(height: 45)
    }
}

// MARK: - Preview UI
struct ServerConfigOverlay_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DataManager()
        return ServerConfigOverlay().environmentObject(manager)
    }
}
