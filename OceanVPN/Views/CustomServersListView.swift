//
//  CustomServersListView.swift
//  VigilSecVPN
//
//  Created by hyunho lee on 10/2/23.
//

import SwiftUI

/// Shows the list of custom servers
struct CustomServersListView: View {

    @EnvironmentObject var manager: DataManager

    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                Spacer(minLength: 20)
                VStack(spacing: 15) {
                    ForEach(0..<manager.customServersData.count, id: \.self) { index in
                        ServerListItem(atIndex: index)
                    }
                }.padding(.horizontal)
                Spacer(minLength: 20)
            }.overlay(GradientOverlay)

            /// Show empty state when there are no custom servers
            if manager.customServersData.count == 0 {
                EmptyStateView
            }
        }.onAppear { manager.fetchCustomServers() }
    }

    /// Gradient for the scroll view top
    private var GradientOverlay: some View {
        VStack {
            LinearGradient(colors: [.backgroundColor, .backgroundColor.opacity(0)], startPoint: .top, endPoint: .bottom).frame(height: 20)
            Spacer()
        }.allowsHitTesting(false)
    }

    /// Empty servers list view
    private var EmptyStateView: some View {
        VStack {
            Image(systemName: "server.rack")
                .font(.system(size: 28, weight: .semibold))
            Text("No Servers").font(.system(size: 25, weight: .semibold))
            Text("You don't have any custom servers\nTap the + button to create on")
                .font(.system(size: 18, weight: .light))
                .multilineTextAlignment(.center)
                .opacity(0.7)
        }.foregroundColor(.primaryTextColor).padding(.bottom, 40)
    }

    /// Server list item
    private func ServerListItem(atIndex index: Int) -> some View {
        VStack {
            let server = manager.customServersData[index]
            let isSelected: Bool = manager.selectedServer?.address == server.address
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(isSelected ? .accentColor : .tertiaryBackgroundColor)
                    .opacity(isSelected ? 0.7 : 1.0)
                HStack(spacing: 5) {
                    VStack(alignment: .leading) {
                        HStack(spacing: 5) {
                            Image(systemName: isSelected ? "record.circle" : "circle")
                            Text(server.address).font(.system(size: 18, weight: .medium))
                        }
                        Button { manager.deleteServer(atIndex: index) } label: {
                            ZStack {
                                Color.primaryTextColor.cornerRadius(5).opacity(0.2)
                                Text("Delete")
                            }
                        }.frame(width: 80, height: 30)
                    }.padding([.vertical, .leading], 10)
                    Spacer()
                    ServerDetails(atIndex: index)
                }
                .font(.system(size: 15, weight: .light))
                .foregroundColor(.primaryTextColor)
            }.opacity(isSelected ? 1.0 : 0.5).contentShape(Rectangle()).onTapGesture {
                manager.selectedServer = server
            }
        }
    }

    /// Server details
    private func ServerDetails(atIndex index: Int) -> some View {
        VStack(alignment: .trailing, spacing: 5) {
            let server = manager.customServersData[index]
            VStack(alignment: .trailing, spacing: -2) {
                Text("Username").font(.system(size: 14, weight: .medium))
                Text(server.username).font(.system(size: 12, weight: .light))
            }
            VStack(alignment: .trailing, spacing: -2) {
                Text("Password").font(.system(size: 14, weight: .medium))
                Text(server.password).font(.system(size: 12, weight: .light))
            }
        }.padding([.trailing, .vertical], 10)
    }
}

// MARK: - Preview UI
struct CustomServersListView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DataManager()
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
        return ZStack {
            Color.backgroundColor.ignoresSafeArea()
            CustomServersListView().environmentObject(manager)
        }
    }
}
