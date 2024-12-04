//
//  ContinentsView.swift
//  VigilSecVPN
//
//  Created by hyunho lee on 10/2/23.
//

import SwiftUI

/// Shows the continents as background
struct ContinentsView: View {

    @EnvironmentObject var manager: DataManager
    @State private var continentsAnimation: [Continent] = [.europe, .australia, .southAmerica, .northAmerica]

    // MARK: - Main rendering function
    var body: some View {
        GeometryReader { reader in
            HStack(spacing: 2) {
                ForEach(0..<400, id: \.self) { _ in
                    Rectangle().foregroundColor(.white).frame(width: 1)
                }
            }
            .mask(
                Image("continents").resizable()
                    .aspectRatio(contentMode: .fit)
            )
            .frame(width: reader.size.width)
            .offset(x: reader.size.width * manager.currentContinent.xOffset)
            .offset(y: reader.size.height * manager.currentContinent.yOffset)
            .scaleEffect(manager.currentContinent.scale)
        }
        .frame(width: UIScreen.main.bounds.width)
        .mask(ContainerShape()).ignoresSafeArea()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if !manager.didAnimateContinents {
                    manager.didAnimateContinents = true
                    animateContinent(continentsAnimation.removeFirst(), delay: 1)
                }
            }
        }
    }

    /// Animate continent
    private func animateContinent(_ continet: Continent, delay: Double) {
        withAnimation(.easeOut(duration: 5).delay(delay)) {
            manager.currentContinent = continet
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                if continentsAnimation.count > 0 {
                    animateContinent(continentsAnimation.removeFirst(), delay: 1)
                }
            }
        }
    }
}

// MARK: - Preview UI
struct ContinentsView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DataManager()
        manager.currentContinent = .northAmerica
        return ZStack {
            Color.backgroundColor.ignoresSafeArea()
            VStack {
                ZStack {
                    ContainerShape().foregroundColor(.secondaryBackgroundColor)
                        .shadow(radius: 10, y: 5).ignoresSafeArea()
                    ContinentsView().environmentObject(manager)
                }.frame(height: UIScreen.main.bounds.height/2.0 + 30.0)
                Spacer()
            }
        }
    }
}
