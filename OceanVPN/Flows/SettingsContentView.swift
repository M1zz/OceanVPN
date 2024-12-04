//
//  SettingsContentView.swift
//  VigilSecVPN
//
//  Created by hyunho lee on 10/2/23.
//

import SwiftUI
import StoreKit
import MessageUI
import PurchaseKit

/// Shows the main settings flow for the app
struct SettingsContentView: View {

    @EnvironmentObject var manager: DataManager

    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
            VStack(spacing: 10) {
                HeaderView
                ScrollView(.vertical, showsIndicators: false) {
                    Spacer(minLength: 20)
                    VStack {
                        InAppPurchasesPromoBannerView
                        CustomHeader(title: "In-App Purchases")
                        InAppPurchasesView
                        CustomHeader(title: "Spread the Word")
                        RatingShareView
                        CustomHeader(title: "Support & Privacy")
                        PrivacySupportView
                    }.padding(.horizontal, 20)
                    Spacer(minLength: 20)
                }.overlay(GradientOverlay)
            }
        }
    }

    /// Gradient for the scroll view top
    private var GradientOverlay: some View {
        VStack {
            LinearGradient(colors: [.backgroundColor, .backgroundColor.opacity(0)], startPoint: .top, endPoint: .bottom).frame(height: 20)
            Spacer()
        }.allowsHitTesting(false)
    }

    /// Custom header view
    private var HeaderView: some View {
        ZStack {
            Text("Settings").font(.system(size: 20, weight: .semibold))
            HStack {
                Spacer()
                Button { manager.fullScreenMode = nil } label: {
                    ZStack {
                        Color.tertiaryBackgroundColor.cornerRadius(8)
                            .frame(width: 35, height: 33)
                        Image(systemName: "xmark").padding(10)
                    }.font(.system(size: 15))
                }
            }.padding(.horizontal)
        }.foregroundColor(.primaryTextColor)
    }

    /// Create custom header view
    private func CustomHeader(title: String) -> some View {
        HStack {
            Text(title).font(.system(size: 18, weight: .medium))
            Spacer()
        }.foregroundColor(.secondaryTextColor)
    }

    /// Custom settings item
    private func SettingsItem(title: String, icon: String, action: @escaping() -> Void) -> some View {
        Button(action: {
            action()
        }, label: {
            HStack {
                Image(systemName: icon).resizable().aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22, alignment: .center)
                Text(title).font(.system(size: 18))
                Spacer()
                Image(systemName: "chevron.right")
            }.foregroundColor(.primaryTextColor).padding()
        })
    }

    // MARK: - In App Purchases
    private var InAppPurchasesView: some View {
        VStack {
            SettingsItem(title: "Upgrade Premium", icon: "crown") {
                manager.fullScreenMode = .premium
            }
            Color.tertiaryBackgroundColor.frame(height: 1)
            SettingsItem(title: "Restore Purchases", icon: "arrow.clockwise") {
                manager.fullScreenMode = .premium
            }
        }.padding([.top, .bottom], 5).background(
            Color.secondaryBackgroundColor.cornerRadius(15)
                .shadow(color: .black.opacity(0.12), radius: 15)
        ).padding(.bottom, 30)
    }

    private var InAppPurchasesPromoBannerView: some View {
        ZStack {
            if manager.isPremiumUser == false {
                ZStack {
                    LinearGradient(colors: [.accentColor.opacity(0.2), .accentColor.opacity(0.7)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Premium Version").bold().font(.system(size: 20))
                            Text("- Remove Ads").font(.system(size: 15)).opacity(0.7)
                            Text("- Unlock All Servers").font(.system(size: 15)).opacity(0.7)
                            Text("- Custom IPsec VPN Config").font(.system(size: 15)).opacity(0.7)
                        }
                        Spacer()
                        Image(systemName: "crown.fill").font(.system(size: 45))
                    }.foregroundColor(.primaryTextColor).padding([.leading, .trailing], 20)
                }.frame(height: 110).cornerRadius(16).padding(.bottom, 15)
            }
        }
    }

    // MARK: - Rating and Share
    private var RatingShareView: some View {
        VStack {
            SettingsItem(title: "Rate App", icon: "star") {
                if let scene = windowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
            Color.tertiaryBackgroundColor.frame(height: 1)
            SettingsItem(title: "Share App", icon: "square.and.arrow.up") {
                let shareController = UIActivityViewController(activityItems: [AppConfig.yourAppURL], applicationActivities: nil)
                rootController?.present(shareController, animated: true, completion: nil)
            }
        }.padding([.top, .bottom], 5).background(
            Color.secondaryBackgroundColor.cornerRadius(15)
                .shadow(color: .black.opacity(0.12), radius: 15)
        ).padding(.bottom, 30)
    }

    // MARK: - Support & Privacy
    private var PrivacySupportView: some View {
        VStack {
            SettingsItem(title: "E-Mail us", icon: "envelope.badge") {
                EmailPresenter.shared.present()
            }
            Color.tertiaryBackgroundColor.frame(height: 1)
            SettingsItem(title: "Privacy Policy", icon: "hand.raised") {
                UIApplication.shared.open(AppConfig.privacyURL, options: [:], completionHandler: nil)
            }
            Color.tertiaryBackgroundColor.frame(height: 1)
            SettingsItem(title: "Terms of Use", icon: "doc.text") {
                UIApplication.shared.open(AppConfig.termsAndConditionsURL, options: [:], completionHandler: nil)
            }
        }.padding([.top, .bottom], 5).background(
            Color.secondaryBackgroundColor.cornerRadius(15)
                .shadow(color: .black.opacity(0.12), radius: 15)
        )
    }
}

// MARK: - Preview UI
struct SettingsContentView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsContentView().environmentObject(DataManager())
    }
}

// MARK: - Mail presenter for SwiftUI
class EmailPresenter: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = EmailPresenter()
    private override init() { }

    func present() {
        if !MFMailComposeViewController.canSendMail() {
            presentAlert(title: "Email Client", message: "Your device must have the native iOS email app installed for this feature.", primaryAction: .OK)
            return
        }
        let picker = MFMailComposeViewController()
        picker.setToRecipients([AppConfig.emailSupport])
        picker.mailComposeDelegate = self
        rootController?.present(picker, animated: true, completion: nil)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        rootController?.dismiss(animated: true, completion: nil)
    }
}
