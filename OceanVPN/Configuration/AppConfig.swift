//
//  AppConfig.swift
//  VigilSecVPN
//
//  Created by hyunho lee on 10/2/23.
//

import SwiftUI
import Foundation

/// Generic configurations for the app
class AppConfig {

    /// This is the AdMob Interstitial ad id
    /// Test App ID: ca-app-pub-3940256099942544~1458002511
    static let adMobAdId: String = "ca-app-pub-9783279148790467~3904072712"

    // MARK: - Generic Configurations
    static let appName: String = "VigilSec VPN"
    static let imgBBAPIKey: String = "b744a83e2d99623ea988ae7cf5915c29"

    // MARK: - Back4App Configurations
    static let applicationId: String = "Db4koaDLBQyglwjtAqTJD0RXVG888raoR3MoQeIl"
    static let clientKey: String = "DGGPqZbNwT6o8EPekknuxVNo3Sel2ogTpy8HaV2x"
    static let serverURL: URL = URL(string: "https://parseapi.back4app.com")!

    // MARK: - Settings flow items
    static let emailSupport = "leeo@kakao.com"
    static let privacyURL: URL = URL(string: "https://www.google.com/")!
    static let termsAndConditionsURL: URL = URL(string: "https://www.google.com/")!
    static let yourAppURL: URL = URL(string: "https://apps.apple.com/app/idXXXXXXXXX")!

    // MARK: - In App Purchases
    static let appSecret: String = "YOUR_APP_SECRET_HERE"
    static let oneYearProductId: String = "com.productId.yearly"
    static let oneMonthProductId: String = "com.productId.monthly"
}

/// Connection status
enum ConnectionStatus: String {
    case connected, connecting
    case disconnected, disconnecting

    /// Icon for connection
    var icon: String {
        switch self {
        case .connected:
            return "checkmark.shield.fill"
        case .connecting, .disconnecting:
            return "exclamationmark.shield.fill"
        case .disconnected:
            return "xmark.shield.fill"
        }
    }

    /// Color for connection
    var color: Color {
        switch self {
        case .connected:
            return .connectedTextColor
        case .connecting, .disconnecting:
            return .secondaryTextColor
        case .disconnected:
            return .disconnectedTextColor
        }
    }
}

/// Main app colors
extension Color {
    static let backgroundColor: Color = Color("BackgroundColor")
    static let secondaryBackgroundColor: Color = Color("SecondaryBackgroundColor")
    static let tertiaryBackgroundColor: Color = Color("TertiaryBackgroundColor")
    static let primaryTextColor: Color = Color("PrimaryTextColor")
    static let secondaryTextColor: Color = Color("SecondaryTextColor")
    static let connectedTextColor: Color = Color("ConnectedTextColor")
    static let disconnectedTextColor: Color = Color("DisconnectedTextColor")
    static let bottomContainerStartColor: Color = Color("BottomContainerStartColor")
    static let bottomContainerEndColor: Color = Color("BottomContainerEndColor")
}

/// Full Screen flow
enum FullScreenMode: Int, Identifiable {
    case premium, settings, privacy
    var id: Int { hashValue }
}

/// VPN Continents
enum Continent: String, CaseIterable {
    case northAmerica, southAmerica
    case europe, africa, asia, australia

    /// Offset
    var xOffset: Double {
        switch self {
        case .northAmerica:
            return 0.7
        case .southAmerica:
            return 0.5
        case .europe:
            return -0.01
        case .africa:
            return -0.05
        case .asia:
            return -0.6
        case .australia:
            return -0.85
        }
    }

    var yOffset: Double {
        switch self {
        case .northAmerica:
            return 0.25
        case .southAmerica:
            return 0.02
        case .europe:
            return 0.28
        case .africa:
            return 0.15
        case .asia:
            return 0.2
        case .australia:
            return -0.15
        }
    }

    /// Scale
    var scale: Double {
        switch self {
        case .northAmerica:
            return 2.5
        case .southAmerica:
            return 1.8
        case .europe:
            return 3.5
        case .africa:
            return 2.2
        case .asia:
            return 2.0
        case .australia:
            return 3.2
        }
    }
}
