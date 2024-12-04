//
//  ConnectedLocationView.swift
//  VigilSecVPN
//
//  Created by hyunho lee on 10/2/23.
//

import SwiftUI

/// Shows the connected location view on the dashboard
struct ConnectedLocationView: View {

    @EnvironmentObject var manager: DataManager
    private let height: Double = 65.0

    // MARK: - Main rendering function
    var body: some View {
        Button {
            manager.showLocationsFlow = true
        } label: {
            HStack(spacing: 12) {
                LocationFlagView
                VStack(alignment: .leading, spacing: 5) {
                    Text(locationTitle).font(.system(size: 18, weight: .semibold))
                    Text(locationSubtitle ?? "Select a server to connect")
                        .font(.system(size: 14, weight: .light)).opacity(0.5)
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
        .foregroundColor(.primaryTextColor)
        .frame(height: height).padding(.horizontal, 5).padding(5)
        .background(
            ZStack {
                Color.backgroundColor.cornerRadius(18)
                RoundedRectangle(cornerRadius: 18).stroke(lineWidth: 1)
                    .foregroundColor(.secondaryTextColor)
            }
        )
    }

    /// Location flag view
    private var LocationFlagView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: height + 5).frame(height: height - 10)
                .foregroundColor(.secondaryBackgroundColor)
            if let flag = flagName {
                Image(flag).resizable().aspectRatio(contentMode: .fit)
                    .cornerRadius(5).padding(5)
                    .frame(width: height).frame(height: height - 10)
            } else {
                Image(systemName: "globe.americas.fill")
                    .resizable().aspectRatio(contentMode: .fit)
                    .frame(width: height/2.0, height: height/2.0)
                    .foregroundColor(.secondaryTextColor)
            }
        }
    }

    /// Connected location title
    private var locationTitle: String {
        manager.countriesData.first { country in
            country.id == manager.selectedServer?.countryId
        }?.name ?? "Choose location"
    }

    /// Connected location subtitle
    private var locationSubtitle: String? {
        manager.selectedServer?.address
    }

    /// Connected location flag name
    private var flagName: String? {
        manager.countriesData.first { country in
            country.id == manager.selectedServer?.countryId
        }?.flagName
    }
}

// MARK: - Preview UI
struct ConnectedLocationView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DataManager()
        return ZStack {
            Color.secondaryBackgroundColor.ignoresSafeArea()
            ConnectedLocationView().environmentObject(manager).padding()
        }
    }
}
