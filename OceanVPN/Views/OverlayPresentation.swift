//
//  OverlayPresentation.swift
//  VigilSecVPN
//
//  Created by hyunho lee on 10/2/23.
//

import SwiftUI

/// Custom overlay presentation modifier
struct OverlayPresentation: ViewModifier {

    @Binding var present: Bool

    // MARK: - Main rendering function
    func body(content: Content) -> some View {
        ZStack {
            Color.black.opacity(present ? 0.7 : 0.0)
                .ignoresSafeArea().onTapGesture { dismissOverlay() }
            content
                .offset(y: present ? 0 : UIScreen.main.bounds.height)
                .padding(.bottom, UIDevice.current.hasNotch ? 0 : 20)
        }
    }

    /// Dismiss custom overlay presentation
    private func dismissOverlay() {
        hideKeyboard()
        withAnimation { present.toggle() }
    }
}

/// Custom extension to assign overlay presentation
extension View {
    func overlay(_ shouldPresent: Binding<Bool>) -> some View {
        modifier(OverlayPresentation(present: shouldPresent))
    }
}
