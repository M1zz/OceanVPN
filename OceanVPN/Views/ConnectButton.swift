//
//  ConnectButton.swift
//  VigilSecVPN
//
//  Created by hyunho lee on 10/2/23.
//

import SwiftUI

/// The main connect button on the dashboard
struct ConnectButton: View {

    @EnvironmentObject var manager: DataManager

    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            GradientCircle(colors: [.tertiaryBackgroundColor, .secondaryBackgroundColor],
                           stroke: [.secondaryTextColor, .backgroundColor])
            GradientCircle(colors: [.backgroundColor, .tertiaryBackgroundColor],
                           stroke: [.secondaryTextColor, .secondaryBackgroundColor])
                .padding(size * 0.15)
            Image(systemName: "power")
                .font(.system(size: size * 0.2, weight: .bold))
                .foregroundColor(status.color)
                .shadow(color: .accentColor.opacity(0.5), radius: 10)
        }
        .frame(width: size, height: size).mask(Circle())
        .background(Circle().shadow(color: .backgroundColor.opacity(0.5), radius: 20))
        .padding(size * 0.17).onTapGesture { manager.connect() }
        .background(
            Circle().stroke(lineWidth: 10)
                .foregroundColor(.tertiaryBackgroundColor)
                .shadow(radius: 5, x: 10).shadow(radius: 5, x: -10)
                .shadow(radius: 5, y: -5).shadow(radius: 5, y: 10)
                .mask(Circle().padding(5)).opacity(0.25)
        )
    }

    /// Create gradient circle
    private func GradientCircle(colors: [Color], stroke: [Color]) -> some View {
        LinearGradient(colors: isConnected ? colors.reversed() : colors,
                       startPoint: .top, endPoint: .bottom)
            .mask(Circle())
            .overlay(
                LinearGradient(colors: stroke, startPoint: .top, endPoint: .bottom)
                    .mask(Circle().stroke(lineWidth: 2))
            )
    }

    /// Button size
    private var size: Double {
        UIScreen.main.bounds.width/2.0
    }

    /// Check connection status
    private var status: ConnectionStatus {
        manager.connectionStatus
    }

    /// Get connected status
    private var isConnected: Bool {
        status == .connected
    }
}

// MARK: - Preview UI
struct ConnectButton_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DataManager()
        manager.connectionStatus = .connected
        return ZStack {
            Color.secondaryBackgroundColor
            ConnectButton().environmentObject(manager)
        }
    }
}
