//
//  SubscriptionContentView.swift
//  VigilSecVPN
//
//  Created by hyunho lee on 10/2/23.
//

import SwiftUI
import PurchaseKit

/// Shows the auto-renewable subscriptions
struct SubscriptionContentView: View {

    @EnvironmentObject var manager: DataManager
    @State private var selectedProductId: String = AppConfig.oneMonthProductId
    @State private var showLoadingState: Bool = false

    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
            VStack(spacing: 0) {
                HeaderView
                ScrollView(.vertical, showsIndicators: false) {
                    Spacer(minLength: 20)
                    VStack {
                        TitleSubtitleView
                        FeaturesListView
                        PlansListView
                    }
                    Color.primaryTextColor.frame(height: 1).opacity(0.3)
                        .padding(.horizontal, 60).padding(.top, 20)
                    PurchasePlanButton.padding(.horizontal, 20).padding(.vertical)
                    Text(disclaimerText).foregroundColor(.secondaryTextColor)
                        .font(.system(size: 13, weight: .light)).opacity(0.7)
                        .padding(20).multilineTextAlignment(.center)
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

    /// Subscription title and subtitle
    private var TitleSubtitleView: some View {
        VStack {
            ZStack {
                Color.accentColor.cornerRadius(22)
                    .frame(width: 65, height: 65).opacity(0.2)
                Image(systemName: "crown.fill").padding(10)
                    .foregroundColor(.accentColor)
            }.font(.system(size: 30))
            Text("Upgrade to Premium").font(.system(size: 20, weight: .semibold))
            Text("Access all servers and add new servers")
                .font(.system(size: 15, weight: .light)).opacity(0.5)
        }.foregroundColor(.primaryTextColor)
    }

    /// Subscription features list
    private var FeaturesListView: some View {
        VStack(alignment: .leading, spacing: 25) {
            FeatureItem(title: "No Ads", subtitle: "Enjoy this app without ads",
                        icon: "tag.slash.fill")
            FeatureItem(title: "All Servers", subtitle: "Access all servers worldwide",
                        icon: "globe.europe.africa.fill")
            FeatureItem(title: "Custom VPN", subtitle: "Your own IPsec VPN configuration", icon: "gear.badge.checkmark")
        }.padding(30)
    }

    /// Feature list item
    private func FeatureItem(title: String,
                             subtitle: String, icon: String) -> some View {
        HStack(spacing: 15) {
            ZStack {
                Color.tertiaryBackgroundColor.cornerRadius(12)
                    .frame(width: 40, height: 40)
                Image(systemName: icon).resizable().aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
            VStack(alignment: .leading) {
                Text(title).font(.system(size: 18, weight: .semibold))
                Text(subtitle).font(.system(size: 14, weight: .light)).opacity(0.5)
            }
            Spacer()
        }.foregroundColor(.primaryTextColor)
    }

    /// Subscription plans list
    private var PlansListView: some View {
        VStack(spacing: 15) {
            SubscriptionPlanListItem(productId: AppConfig.oneMonthProductId)
            SubscriptionPlanListItem(productId: AppConfig.oneYearProductId)
        }.padding(.horizontal, 20)
    }

    /// Plan list item
    private func SubscriptionPlanListItem(productId: String) -> some View {
        let isSelected: Bool = selectedProductId == productId
        return HStack {
            Text(planName(forProductId: productId))
                .font(.system(size: 16, weight: .semibold))
            Spacer()
            Text(planPrice(forProductId: productId))
                .font(.system(size: 20, weight: .semibold))
            Image(systemName: isSelected ? "record.circle.fill" : "circle")
                .foregroundColor(isSelected ? .accentColor : .secondaryTextColor)
        }
        .foregroundColor(isSelected ? .primaryTextColor : .secondaryTextColor)
        .padding(15).background(
            ZStack {
                let color: Color = isSelected ? .accentColor : .tertiaryBackgroundColor
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(color).opacity(0.05)
                RoundedRectangle(cornerRadius: 12).stroke(lineWidth: 1.5)
                    .foregroundColor(color)
            }
        ).contentShape(Rectangle()).onTapGesture {
            UIImpactFeedbackGenerator().impactOccurred()
            selectedProductId = productId
        }
    }

    /// Plan details
    private func planName(forProductId productId: String) -> String {
        PKManager.productTitle(identifier: productId)
    }

    /// Plan price
    private func planPrice(forProductId productId: String) -> String {
        PKManager.productPrice(identifier: productId)
    }

    /// Subscriptions disclaimer
    private var disclaimerText: String {
        PKManager.disclaimer
    }

    /// Purchase plan button
    private var PurchasePlanButton: some View {
        Button {
            showLoadingState = true
            PKManager.purchaseProduct(identifier: selectedProductId) { error, status, _ in
                DispatchQueue.main.async {
                    self.showLoadingState = false
                    self.manager.fullScreenMode = nil
                    if let errorMessage = error {
                        presentAlert(title: "Oops!", message: errorMessage, primaryAction: .Cancel)
                    } else if status == .success {
                        self.manager.isPremiumUser = true
                    }
                }
            }
        } label: {
            ZStack {
                Color.accentColor.cornerRadius(10)
                Text(showLoadingState ? "please wait..." : "Subscribe Now")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryTextColor)
            }
        }.frame(height: 45).disabled(showLoadingState)
    }
}

// MARK: - Preview UI
struct SubscriptionContentView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionContentView().environmentObject(DataManager())
    }
}
