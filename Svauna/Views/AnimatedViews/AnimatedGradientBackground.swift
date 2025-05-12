//
//  AnimatedGradientBackground.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 5/1/25.
//

import SwiftUI

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    @State private var gradientPhase = 0.0
    
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    // Colors from our SvaunaColorPalette
    private let colors = [
        Color.Svauna.generalGradientStart,
        Color.Svauna.generalGradientMiddle,
        Color.Svauna.generalGradientEnd,
        Color.Svauna.generalGradientMiddle,
        Color.Svauna.generalGradientStart
    ]
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: UnitPoint(x: 0.5 + 0.5 * cos(gradientPhase),
                                  y: 0.5 + 0.5 * sin(gradientPhase)),
            endPoint: UnitPoint(x: 0.5 - 0.5 * cos(gradientPhase),
                               y: 0.5 - 0.5 * sin(gradientPhase))
        )
        .onReceive(timer) { _ in
            withAnimation(.linear(duration: 0.05)) {
                gradientPhase += 0.01
                if gradientPhase > 2 * .pi {
                    gradientPhase -= 2 * .pi
                }
            }
        }
    }
}

// Alternative implementation with more customization options
struct AnimatedSvaunaGradient: View {
    @State private var animate = false
    
    var intensity: Double = 1.0  // Controls the animation intensity (0.5 to 2.0 recommended)
    var speed: Double = 1.0      // Controls the animation speed (0.5 to 2.0 recommended)
    
    var body: some View {
        LinearGradient(
            colors: [
                Color.Svauna.generalGradientStart,
                Color.Svauna.generalGradientMiddle,
                Color.Svauna.generalGradientEnd
            ],
            startPoint: animate ? .topLeading : .bottomLeading,
            endPoint: animate ? .bottomTrailing : .topTrailing
        )
        .onAppear {
            withAnimation(
                .easeInOut(duration: 5 / speed)
                .repeatForever(autoreverses: true)
            ) {
                animate.toggle()
            }
        }
    }
}


// MARK: - Usage Example
//struct GradientBackgroundDemo: View {
//    @State private var animationType = 0
//    
//    var body: some View {
//        ZStack {
//            // Choose which animation style to display
//            Group {
//                if animationType == 0 {
//                    AnimatedGradientBackground()
//                } else {
//                    AnimatedSvaunaGradient(intensity: 1.0, speed: 1.0)
//                }
//            }
//            .edgesIgnoringSafeArea(.all)
//            
//            VStack {
//                Spacer()
//                
//                Text("Animated Svauna Gradient")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//                    .shadow(radius: 5)
//                    .padding()
//                
//                Picker("Animation Style", selection: $animationType) {
//                    Text("Fluid Motion").tag(0)
//                    Text("Easing Motion").tag(1)
//                }
//                .pickerStyle(SegmentedPickerStyle())
//                .padding()
//                .background(Color.white.opacity(0.2))
//                .cornerRadius(8)
//                .padding(.horizontal)
//                
//                Spacer()
//            }
//        }
//    }
//}
