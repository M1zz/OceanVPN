//
//  ConnectionSpeedView.swift
//  VigilSecVPN
//
//  Created by hyunho lee on 10/2/23.
//

import SwiftUI

/// Shows the download/upload speed
struct ConnectionSpeedView: View {

    @EnvironmentObject var manager: DataManager

    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            DownloadSpeedView
            Color.primaryTextColor.frame(width: 1)
                .opacity(0.3).padding(.vertical, 12)
            UploadSpeedView
        }.frame(height: 50)
    }

    /// Download speed view
    private var DownloadSpeedView: some View {
        HStack {
            let speed: String = manager.downloadSpeed
            Speed(icon: "arrow.down.circle", title: "Download",
                  value: speed.components(separatedBy: " ").first ?? "",
                  unit: speed.components(separatedBy: " ").last ?? "")
            Spacer()
        }
        .foregroundColor(.primaryTextColor)
        .padding(.leading, 50)
    }

    /// Upload speed view
    private var UploadSpeedView: some View {
        HStack {
            Spacer()
            let speed: String = manager.uploadSpeed
            Speed(icon: "arrow.up.circle", title: "Upload",
                  value: speed.components(separatedBy: " ").first ?? "",
                  unit: speed.components(separatedBy: " ").last ?? "")
        }
        .foregroundColor(.primaryTextColor)
        .padding(.trailing, 50)
    }

    /// Download/Upload speed view
    private func Speed(icon: String, title: String,
                       value: String, unit: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 25, weight: .light, design: .rounded))
                .opacity(0.8)
            VStack(alignment: .leading) {
                Text(title).font(.system(size: 12, weight: .light))
                    .opacity(0.5)
                HStack(alignment: .center, spacing: 0) {
                    Text(value).font(.system(size: 17, weight: .semibold))
                    Text(" \(unit)").font(.system(size: 15, weight: .medium))
                        .opacity(0.5)
                }
            }
        }
    }
}

// MARK: - Preview UI
struct ConnectionSpeedView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DataManager()
        return ZStack {
            Color.secondaryBackgroundColor.ignoresSafeArea()
            ConnectionSpeedView().environmentObject(manager)
        }
    }
}
