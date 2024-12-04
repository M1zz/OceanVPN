//
//  PrivacyContentView.swift
//  VigilSecVPN
//
//  Created by hyunho lee on 10/2/23.
//

import SwiftUI

/// A generic flow to show the VPN privacy terms
struct PrivacyContentView: View {

    @EnvironmentObject var manager: DataManager

    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
            VStack(spacing: 10) {
                Text("Privacy").font(.system(size: 20, weight: .semibold)).foregroundColor(.primaryTextColor)
                ScrollView(.vertical, showsIndicators: false) {
                    Spacer(minLength: 20)
                    Text(LocalizedStringKey(text)).padding(.horizontal, 20)
                        .foregroundColor(.primaryTextColor).font(.system(size: 16))
                    Spacer(minLength: 20)
                }.overlay(GradientOverlay)
                AgreeButton.padding(20)
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

    /// Agree button
    private var AgreeButton: some View {
        Button {
            manager.didAcceptPrivacyTerms = true
            manager.fullScreenMode = nil
        } label: {
            ZStack {
                Color.accentColor.cornerRadius(10)
                Text("Agree & Continue")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primaryTextColor)
            }
        }.frame(height: 45)
    }

    /// Privacy text
    private var text: String =
    """
    To be consistent with data protection laws, we are asking you to take a moment to review some key points of \(AppConfig.appName)'s Privacy Policy.

    **We do not log** how you utilize VPN connection, which means we do not see the applications, service or websites you use personally while connected to our Service nor do we store them.

    **We do not store** your original IP address or the server IP address that you connect to which means we cannot share it to anyone no matter what happened.

    **We will not sell**, use, or disclose any personal data to third parties not mentioned in this Privacy for any purpose.

    We designed our systems to not have sensitive data about our customers; even when compelled, we cannot provide data that we do not possess.


    **By clicking "Agree & Continue" you agree to our [Terms of Service](\(AppConfig.termsAndConditionsURL)) and [Privacy Policy](\(AppConfig.privacyURL)) that describes how we collect and process your data.**
    """
}

// MARK: - Preview UI
struct PrivacyContentView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyContentView().environmentObject(DataManager())
    }
}
