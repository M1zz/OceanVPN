//
//  VigilSecVPNApp.swift
//  VigilSecVPN
//
//  Created by hyunho lee on 10/2/23.
//

import SwiftUI

@main
struct VigilSecVPNApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var manager: DataManager = DataManager(preview: false)

    // MARK: - Main rendering function
    var body: some Scene {
        WindowGroup {
            DashboardContentView().environmentObject(manager)
        }
    }
}

/// Present an alert from anywhere in the app
func presentAlert(title: String, message: String, primaryAction: UIAlertAction, secondaryAction: UIAlertAction? = nil, tertiaryAction: UIAlertAction? = nil) {
    DispatchQueue.main.async {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(primaryAction)
        if let secondary = secondaryAction { alert.addAction(secondary) }
        if let tertiary = tertiaryAction { alert.addAction(tertiary) }
        rootController?.present(alert, animated: true, completion: nil)
    }
}

extension UIAlertAction {
    static var Cancel: UIAlertAction {
        UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    }

    static var OK: UIAlertAction {
        UIAlertAction(title: "OK", style: .cancel, handler: nil)
    }
}

var rootController: UIViewController? {
    var root = UIApplication.shared.connectedScenes
        .filter({ $0.activationState == .foregroundActive })
        .first(where: { $0 is UIWindowScene }).flatMap({ $0 as? UIWindowScene })?.windows
        .first(where: { $0.isKeyWindow })?.rootViewController
    while root?.presentedViewController != nil {
        root = root?.presentedViewController
    }
    return root
}

var windowScene: UIWindowScene? {
    let allScenes = UIApplication.shared.connectedScenes
    return allScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
}

/// Hide keyboard from any view
extension View {
    func hideKeyboard() {
        DispatchQueue.main.async {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

extension ViewModifier {
    func hideKeyboard() {
        DispatchQueue.main.async {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

/// Handle certain date operations
extension Date {
    func string(format: String = "yyyy-MM-dd'T'HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: self)
    }

    var session: String {
        let secondsPassed = Int(Date().timeIntervalSince(self))
        let hours = secondsPassed / 3600
        let minutes = (secondsPassed % 3600) / 60
        let remainingSeconds = secondsPassed % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
        } else if minutes > 0 {
            return String(format: "00:%02d:%02d", minutes, remainingSeconds)
        }

        return String(format: "00:00:%02d", remainingSeconds)
    }
}

/// Convert string to date
extension String {
    func date(format: String = "yyyy-MM-dd'T'HH:mm:ss") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US")
        return formatter.date(from: self)
    }
}

/// Speed test formatting
extension Double {
    var speed: String {
        let bytesToBits = self * 8.0 /// 1 byte = 8 bits
        let megabits = bytesToBits / 1_000_000.0
        let kbps = bytesToBits / 1_000.0
        let gbps = bytesToBits / 1_000_000_000.0

        if gbps >= 1.0 {
            return String(format: "%.2f Gbps", gbps)
        } else if megabits >= 1.0 {
            return String(format: "%.2f Mbps", megabits)
        }

        return String(format: "%.2f Kbps", kbps)
    }
}

/// Create a shape with specific rounded corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

/// Check device model
extension UIDevice {
    var modelName: DeviceModel {
        #if targetEnvironment(simulator)
        let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
        #else
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        #endif
        switch identifier {
        case "iPhone10,1", "iPhone10,4":                return .iPhone8
        case "iPhone10,2", "iPhone10,5":                return .iPhone8Plus
        case "iPhone10,3", "iPhone10,6":                return .iPhoneX
        case "iPhone11,2":                              return .iPhoneXS
        case "iPhone11,4", "iPhone11,6":                return .iPhoneXSMax
        case "iPhone11,8":                              return .iPhoneXR
        case "iPhone12,1":                              return .iPhone11
        case "iPhone12,3":                              return .iPhone11Pro
        case "iPhone12,5":                              return .iPhone11ProMax
        case "iPhone12,8":                              return .iPhoneSE2
        case "iPhone13,1":                              return .iPhone12Mini
        case "iPhone13,2":                              return .iPhone12
        case "iPhone13,3":                              return .iPhone12Pro
        case "iPhone13,4":                              return .iPhone12ProMax
        case "iPhone14,4":                              return .iPhone13Mini
        case "iPhone14,5":                              return .iPhone13
        case "iPhone14,2":                              return .iPhone13Pro
        case "iPhone14,3":                              return .iPhone13ProMax
        case "iPhone14,6":                              return .iPhoneSE3
        case "iPhone14,7":                              return .iPhone14
        case "iPhone14,8":                              return .iPhone14Plus
        case "iPhone15,2":                              return .iPhone14Pro
        case "iPhone15,3":                              return .iPhone14ProMax
        default:                                        return .unknown
        }
    }
}

enum DeviceModel: String {
    case unknown
    case iPhone8 = "iPhone 8"
    case iPhone8Plus = "iPhone 8 Plus"
    case iPhoneX = "iPhone X"
    case iPhoneXS = "iPhone XS"
    case iPhoneXSMax = "iPhone XS Max"
    case iPhoneXR = "iPhone XR"
    case iPhone11 = "iPhone 11"
    case iPhone11Pro = "iPhone 11 Pro"
    case iPhone11ProMax = "iPhone 11 Pro Max"
    case iPhoneSE2 = "iPhone SE (2nd generation)"
    case iPhone12Mini = "iPhone 12 mini"
    case iPhone12 = "iPhone 12"
    case iPhone12Pro = "iPhone 12 Pro"
    case iPhone12ProMax = "iPhone 12 Pro Max"
    case iPhone13Mini = "iPhone 13 Mini"
    case iPhone13 = "iPhone 13"
    case iPhone13Pro = "iPhone 13 Pro"
    case iPhone13ProMax = "iPhone 13 Pro Max"
    case iPhoneSE3 = "iPhone SE (3rd generation)"
    case iPhone14 = "iPhone 14"
    case iPhone14Plus = "iPhone 14 Plus"
    case iPhone14Pro = "iPhone 14 Pro"
    case iPhone14ProMax = "iPhone 14 Pro Max"
}

/// Check if the device has a notch (starting with iPhone X)
extension UIDevice {
    var hasNotch: Bool {
        let bottom = windowScene?.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}
