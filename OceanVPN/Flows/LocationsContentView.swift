//
//  LocationsContentView.swift
//  VigilSecVPN
//
//  Created by hyunho lee on 10/2/23.
//

import SwiftUI

/// Shows a list of locations
struct LocationsContentView: View {

    @EnvironmentObject var manager: DataManager
    @State private var selectedTabIndex: Int = 0
    @State private var selectedCountry: CountryModel?
    @State private var showServerSetup: Bool = false

    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
            VStack {
                HeaderView
                SegmentedControlView
                ZStack {
                    if selectedTabIndex == 0 {
                        CountriesListView(selectedCountry: $selectedCountry)
                    } else {
                        CustomServersListView()
                    }
                }.animation(nil, value: selectedTabIndex)
            }.environmentObject(manager)

            /// Server setup overlay
            ServerConfigOverlay {
                withAnimation { showServerSetup.toggle() }
            }.environmentObject(manager).overlay($showServerSetup)
        }
        /// Hide the default navigation bar
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("").navigationBarHidden(true)
    }

    /// Custom header view
    private var HeaderView: some View {
        ZStack {
            Text("Locations").font(.system(size: 23, weight: .bold))
            HStack {
                Button { manager.showLocationsFlow = false } label: {
                    ZStack {
                        Color.tertiaryBackgroundColor.cornerRadius(8)
                            .frame(width: 35, height: 33)
                        Image(systemName: "chevron.left").padding(10)
                    }.font(.system(size: 15))
                }
                Spacer()
                if selectedTabIndex == 1 {
                    Button {
                        withAnimation { showServerSetup.toggle() }
                    } label: {
                        ZStack {
                            Color.tertiaryBackgroundColor.cornerRadius(8)
                                .frame(width: 35, height: 33)
                            Image(systemName: "plus").padding(10)
                        }.font(.system(size: 15))
                    }
                }
            }.padding(.horizontal)
        }.foregroundColor(.primaryTextColor)
    }

    /// Custom segmented control
    private var SegmentedControlView: some View {
        ZStack {
            Color.tertiaryBackgroundColor.cornerRadius(10)
            Color.primaryTextColor.cornerRadius(8).opacity(0.1)
                .padding(5).frame(width: segmentWidth)
                .offset(x: selectedTabIndex == 0 ? -segmentOffset : segmentOffset)
            HStack(spacing: 0) {
                SegmentView(title: "Countries", index: 0)
                Spacer()
                SegmentView(title: "Custom", index: 1)
            }.padding(.horizontal, 5)
        }
        .frame(height: 50).padding(.horizontal)
        .padding(.top, 10)
    }

    /// Custom segment tab
    private func SegmentView(title: String, index: Int) -> some View {
        Button {
            withAnimation { selectedTabIndex = index }
        } label: {
            ZStack {
                Color.tertiaryBackgroundColor.opacity(0.01)
                Text(title).font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primaryTextColor)
                    .opacity(selectedTabIndex == index ? 1.0 : 0.3)
            }
        }.frame(width: segmentWidth, height: 50.0)
    }

    /// Segment width
    private var segmentWidth: Double {
        UIScreen.main.bounds.width/2.0 - 25.0
    }

    /// Segment background offset
    private var segmentOffset: Double {
        segmentWidth/2.0 + 9
    }
}

// MARK: - Preview UI
struct LocationsContentView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DataManager()
        manager.countriesData = [
            .init(id: 0, name: "United States", flagName: "us", isPremium: false),
            .init(id: 1, name: "India", flagName: "in", isPremium: true),
            .init(id: 2, name: "Germany", flagName: "de", isPremium: true)
        ]
        manager.serversData = [
            .init(countryId: 0, address: "188.166.224.228", password: "wVFCM151fTeP9p2cGzQ47xMh",
                  username: "vpnuser", preSharedKey: "bMNoCDCkBLPMI2INjAlJZD1K"),
            .init(countryId: 0, address: "168.0.0.0", password: "",
                  username: "vpn-test", preSharedKey: ""),
            .init(countryId: 0, address: "128.0.0.0", password: "",
                  username: "vpn-test", preSharedKey: ""),
            .init(countryId: 0, address: "111.0.0.0", password: "",
                  username: "vpn-test", preSharedKey: "")
        ]
        manager.customServersData = [
            .init(countryId: 0, address: "192.0.0.1", password: "12345",
                  username: "vpn-test", preSharedKey: "test-xccssdww"),
            .init(countryId: 0, address: "168.0.0.0", password: "67890",
                  username: "vpn-test", preSharedKey: "test-xccssdww"),
            .init(countryId: 0, address: "128.0.0.0", password: "qwerty",
                  username: "vpn-test", preSharedKey: "test-xccssdww"),
            .init(countryId: 0, address: "111.0.0.0", password: "zxc323",
                  username: "vpn-test", preSharedKey: "test-xccssdww")
        ]
        return LocationsContentView().environmentObject(manager)
    }
}
