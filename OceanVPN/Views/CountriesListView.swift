//
//  CountriesListView.swift
//  VigilSecVPN
//
//  Created by hyunho lee on 10/2/23.
//

import SwiftUI

/// Shows a list of countries
struct CountriesListView: View {

    @EnvironmentObject var manager: DataManager
    @Binding var selectedCountry: CountryModel?
    private let height: Double = 45.0

    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                Spacer(minLength: 20)
                VStack(spacing: 15) {
                    ForEach(manager.countriesData) { country in
                        VStack {
                            CountryListItem(country)
                            if let selection = selectedCountry, selection.id == country.id {
                                ServersList(forCountryId: selection.id)
                            }
                        }.background(
                            ZStack {
                                let color: Color = selectedCountry?.id == country.id ? .accentColor : .tertiaryBackgroundColor
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(color).opacity(0.03)
                                RoundedRectangle(cornerRadius: 12).stroke(lineWidth: 1)
                                    .foregroundColor(color)
                            }
                        )
                    }
                }.padding(.horizontal)
                Spacer(minLength: 20)
            }.overlay(GradientOverlay)

            /// Show empty state when there are no countries
            if manager.countriesData.count == 0 {
                EmptyStateView
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

    /// Empty countries list view
    private var EmptyStateView: some View {
        VStack {
            Image(systemName: "globe.americas.fill")
                .font(.system(size: 28, weight: .semibold))
            Text("No Countries").font(.system(size: 25, weight: .semibold))
            Text("There are no countries available\nCome back later")
                .font(.system(size: 18, weight: .light))
                .multilineTextAlignment(.center)
                .opacity(0.7)
        }.foregroundColor(.primaryTextColor).padding(.bottom, 40)
    }

    /// Country list item
    private func CountryListItem(_ item: CountryModel) -> some View {
        let isSelected: Bool = selectedCountry?.id == item.id
        let isPremium: Bool = !manager.isPremiumUser && item.isPremium
        return HStack(spacing: 12) {
            LocationFlagView(name: item.flagName)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).font(.system(size: 16, weight: .semibold))
                Text(serversCount(for: item)).opacity(0.5)
                    .font(.system(size: 14, weight: .light))
            }
            Spacer()
            ZStack {
                Circle().foregroundColor(.tertiaryBackgroundColor)
                let chevronIcon: String = "chevron.\(isSelected ? "up" : "down")"
                Image(systemName: isPremium ? "lock.fill" : chevronIcon)
                    .font(.system(size: 12)).offset(y: isSelected || isPremium ? 0 : 1)
            }.frame(width: 25, height: 25)
        }
        .foregroundColor(.primaryTextColor)
        .frame(height: height).padding(.trailing, 8)
        .padding(.leading, 2).padding(5)
        .opacity(isSelected || selectedCountry == nil ? 1 : 0.2)
        .contentShape(Rectangle()).onTapGesture {
            if isPremium {
                manager.fullScreenMode = .premium
            } else {
                if selectedCountry?.id == item.id {
                    selectedCountry = nil
                } else {
                    selectedCountry = item
                }
            }
        }
    }

    /// Servers count for country
    private func serversCount(for country: CountryModel) -> String {
        let count = manager.serversData.filter { server in
            server.countryId == country.id
        }.count
        return "\(count) server\(count != 1 ? "s" : "")"
    }

    /// Location flag view
    private func LocationFlagView(name: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .frame(width: height + 5).frame(height: height - 5)
                .foregroundColor(.secondaryBackgroundColor)
            Image(name).resizable().aspectRatio(contentMode: .fit)
                .cornerRadius(5).padding(5)
                .frame(width: height).frame(height: height - 10)
        }
    }

    /// Servers list for a country id
    private func ServersList(forCountryId countryId: Int) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
            let data = manager.serversData.filter { $0.countryId == countryId }
            ForEach(0..<data.count, id: \.self) { index in
                let server = data[index]
                let isSelected: Bool = manager.selectedServer?.address == server.address
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .foregroundColor(isSelected ? .accentColor : .tertiaryBackgroundColor)
                        .opacity(isSelected ? 0.7 : 1.0)
                    HStack(spacing: 5) {
                        Image(systemName: isSelected ? "record.circle" : "circle")
                        Text(server.address)
                        Spacer()
                    }
                    .font(.system(size: 15, weight: .light))
                    .foregroundColor(.primaryTextColor)
                    .contentShape(Rectangle()).padding(5).onTapGesture {
                        manager.selectedServer = server
                    }
                }.opacity(isSelected ? 1.0 : 0.5)
            }
        }.padding([.horizontal, .bottom], 8)
    }
}

// MARK: - Preview UI
struct CountriesListView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DataManager()
        manager.countriesData = [
            .init(id: 0, name: "United States", flagName: "us", isPremium: false),
            .init(id: 1, name: "India", flagName: "in", isPremium: true),
            .init(id: 2, name: "Germany", flagName: "ge", isPremium: true)
        ]
        manager.serversData = [
            .init(countryId: 0, address: "192.0.0.1", password: "",
                  username: "vpn-test", preSharedKey: ""),
            .init(countryId: 0, address: "168.0.0.0", password: "",
                  username: "vpn-test", preSharedKey: ""),
            .init(countryId: 0, address: "128.0.0.0", password: "",
                  username: "vpn-test", preSharedKey: ""),
            .init(countryId: 0, address: "111.0.0.0", password: "",
                  username: "vpn-test", preSharedKey: "")
        ]
        return CountriesListViewPreview().environmentObject(manager)
    }

    struct CountriesListViewPreview: View {
        @State private var selectedCountry: CountryModel?
        var body: some View {
            ZStack {
                Color.backgroundColor.ignoresSafeArea()
                CountriesListView(selectedCountry: $selectedCountry)
            }
        }
    }
}
