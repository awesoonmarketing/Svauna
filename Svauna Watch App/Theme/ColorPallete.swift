//
//  SvaunaColorPalette.swift
//  Svauna
//
//  Created for Svauna on 4/28/25.
//

import SwiftUI

// MARK: - Color Extension for Svauna App
extension Color {
    enum Svauna {
        // MARK: - Primary Theme Colors
        
        // Sauna Experience Colors
        static let saunaGradientStart = Color(hex: "E74C3C").opacity(0.8)
        static let saunaGradientEnd = Color(hex: "F39C12").opacity(0.6)
        static let warmAccent = Color(hex: "F39C12")
        
        // Cold Plunge Colors
        static let coldGradientStart = Color(hex: "3498DB").opacity(0.7)
        static let coldGradientEnd = Color(hex: "6C5B7B").opacity(0.5)
        static let coolAccent = Color(hex: "1ABC9C")
        
        // General App Theme Colors (Mixed Warm & Cool)
        static let generalGradientStart = Color(hex: "3498DB").opacity(0.6) // Blue base
        static let generalGradientMiddle = Color(hex: "6C5B7B").opacity(0.4) // Purple transition
        static let generalGradientEnd = Color(hex: "F39C12").opacity(0.5) // Orange accent
        
        // MARK: - UI Element Colors
        
        // Background Colors
        static let appBackground = Color(hex: "1A1A1F")
        static let secondaryBackground = Color(hex: "262633")
        static let panelBackground = Color.black.opacity(0.15)
        
        // Action Button Colors
        static let pauseButton = Color(hex: "F1C40F")
        static let resumeButton = Color(hex: "2ECC71")
        static let endButton = Color(hex: "E74C3C").opacity(0.7)
        static let segmentButton = Color.white.opacity(0.2)
        
        // Text & Icons
        static let primaryText = Color.white
        static let secondaryText = Color.white.opacity(0.8)
        static let tertiaryText = Color.white.opacity(0.7)
        static let heartRateIcon = Color(hex: "E74C3C")
        static let caloriesIcon = Color(hex: "F39C12")
        static let bloodOxygenIcon = Color(hex: "3498DB")
        
        // Status & Feedback
        static let pausedStatus = Color.black.opacity(0.5)
        static let shadow = Color.black.opacity(0.15)
        static let divider = Color.white.opacity(0.2)
    }
}

// MARK: - Hex Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradient Convenience Functions
extension LinearGradient {
    enum Svauna {
        static func saunaBackground() -> LinearGradient {
            LinearGradient(
                colors: [Color.Svauna.saunaGradientStart, Color.Svauna.saunaGradientEnd],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        
        static func coldPlungeBackground() -> LinearGradient {
            LinearGradient(
                colors: [Color.Svauna.coldGradientStart, Color.Svauna.coldGradientEnd],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        
        static func appBackground() -> LinearGradient {
            LinearGradient(
                colors: [Color.Svauna.appBackground, Color.Svauna.secondaryBackground],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        
        static func generalBackground() -> LinearGradient {
            LinearGradient(
                colors: [
                    Color.Svauna.generalGradientStart,
                    Color.Svauna.generalGradientMiddle,
                    Color.Svauna.generalGradientEnd
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        static func animatedGeneralBackground() -> some View {
            AnimatedGradientBackground()
        }
        
        static func animatedGeneralBackground(intensity: Double = 1.0, speed: Double = 1.0) -> some View {
            AnimatedSvaunaGradient(intensity: intensity, speed: speed)
        }
    }
}

// Usage Example:
/*
 struct SaunaView: View {
     var body: some View {
         ZStack {
             LinearGradient.Svauna.saunaBackground()
                 .edgesIgnoringSafeArea(.all)
             
             VStack {
                 Text("Sauna Timer")
                     .foregroundColor(Color.Svauna.primaryText)
                 
                 Button("Pause") {
                     // Action
                 }
                 .background(Color.Svauna.pauseButton)
                 .foregroundColor(Color.Svauna.primaryText)
             }
         }
     }
 }
 
 struct MainAppView: View {
     var body: some View {
         ZStack {
             // Use the general background gradient for main app screens
             LinearGradient.Svauna.generalBackground()
                 .edgesIgnoringSafeArea(.all)
             
             // Your content here
         }
     }
 }
 */
