//
//  DashboardContentView.swift
//  VigilSecVPN
//
//  Created by hyunho lee on 10/2/23.
//

import SwiftUI

/// Main dashboard for the app
struct DashboardContentView: View {

    @EnvironmentObject var manager: DataManager
    @State private var sessionTime: String = "00:00:00"
    private let timer: Timer.TimerPublisher = Timer.publish(every: 1.0, on: .main, in: .common)

    // MARK: - Main rendering function
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundColor.ignoresSafeArea()
                NavigationLink(destination: LocationsContentView().environmentObject(manager),
                               isActive: $manager.showLocationsFlow) { EmptyView() }
                VStack {
                    Spacer()
                    BottomContainerView
                }
                VStack {
                    TopContainerView
                    Spacer()
                }
            }
            /// Hide the default navigation bar
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle("").navigationBarHidden(true)
            .onReceive(timer.autoconnect()) { _ in
                sessionTime = manager.sessionStartTime.date()?.session ?? "00:00:00"
            }
            .fullScreenCover(item: $manager.fullScreenMode) { type in
                switch type {
                case .premium: SubscriptionContentView().environmentObject(manager)
                case .settings: SettingsContentView().environmentObject(manager)
                case .privacy: PrivacyContentView().environmentObject(manager)
                }
            }
        }
    }

    // MARK: - Top container
    private var TopContainerView: some View {
        ZStack {
            ContainerShape().foregroundColor(.secondaryBackgroundColor)
                .shadow(radius: 10, y: 5).ignoresSafeArea()
            ContinentsView().environmentObject(manager).opacity(0.1)
            VStack {
                HeaderView
                Spacer()
                VStack(spacing: 30) {
                    ConnectedDurationView
                    ConnectedLocationView().padding(.horizontal, 30)
                    ConnectionSpeedView()
                }.padding(.bottom, UIScreen.main.bounds.height * 0.08)
                Spacer()
            }.environmentObject(manager)
        }.frame(height: UIScreen.main.bounds.height/2.0 + 30.0)
    }

    /// Custom header view
    private var HeaderView: some View {
        ZStack {
            if let firstWord = AppConfig.appName.components(separatedBy: " ").first,
                let secondWord = AppConfig.appName.components(separatedBy: " ").last {
                Text(firstWord).font(.system(size: 23, weight: .regular))
                + Text(secondWord).font(.system(size: 23, weight: .bold))
            }
            HStack {
                Button { manager.fullScreenMode = .premium } label: {
                    ZStack {
                        Color.accentColor.cornerRadius(8)
                            .frame(width: 35, height: 33)
                        Image(systemName: "crown.fill").padding(10)
                    }.font(.system(size: 15))
                }
                Spacer()
                Button { manager.fullScreenMode = .settings } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.primaryTextColor)
                }
            }.padding(.horizontal)
        }.foregroundColor(.primaryTextColor)
    }

    /// Connected duration
    private var ConnectedDurationView: some View {
        VStack {
            Text("Session Time")
                .font(.system(size: 14, weight: .light))
                .opacity(0.7)
            Text(sessionTime).font(.system(size: 30, weight: .semibold, design: .rounded))
        }.foregroundColor(.primaryTextColor)
    }

    // MARK: - Bottom container
    private var BottomContainerView: some View {
        ZStack {
            LinearGradient(colors: [.bottomContainerStartColor, .bottomContainerEndColor], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack {
                Spacer()
                ConnectionStatusView
            }.padding(.bottom, bottomPadding)
            ConnectButton().environmentObject(manager)
                .padding(.bottom, bottomPadding).padding(.top, connectButtonTopPadding)
        }.frame(height: UIScreen.main.bounds.height/2.0)
    }

    /// Connection status label
    private var ConnectionStatusView: some View {
        HStack(spacing: 5) {
            Image(systemName: manager.connectionStatus.icon)
            Text(manager.connectionStatus.rawValue.capitalized)
        }
        .font(.system(size: 14, weight: .semibold))
        .foregroundColor(manager.connectionStatus.color)
    }

    /// Padding based on device type
    private var bottomPadding: Double {
        switch UIDevice.current.modelName {
        case .iPhone8, .iPhone8Plus, .iPhoneSE2, .iPhoneSE3: return 20.0
        default: return 0.0
        }
    }

    private var connectButtonTopPadding: Double {
        switch UIDevice.current.modelName {
        case .iPhone8, .iPhone8Plus, .iPhoneSE2, .iPhoneSE3: return 0.0
        case .iPhone14Pro, .iPhone14ProMax: return 60.0
        default: return 40.0
        }
    }
}

// MARK: - Preview UI
struct DashboardContentView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DataManager()
        manager.connectionStatus = .disconnected
        return DashboardContentView().environmentObject(manager)
    }
}

// MARK: - Top Container Shape
struct ContainerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path: Path = Path()
        path.move(to: .zero)
        path.addLine(to: .init(x: rect.width, y: 0))
        path.addLine(to: .init(x: rect.width, y: rect.height))
        path.addQuadCurve(to: .init(x: 0, y: rect.height),
                          control: .init(x: rect.width/2.0,
                                         y: rect.height - 100))
        return path
    }
}
