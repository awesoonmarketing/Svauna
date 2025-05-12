//
//  NumberFormatters.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 2025-04-29.
//

import Foundation

final class NumberFormatters {
    static let shared = NumberFormatters()
    private let calorieFormatter: NumberFormatter
    
    private init() {
        calorieFormatter = NumberFormatter()
        calorieFormatter.maximumFractionDigits = 0
        calorieFormatter.numberStyle = .decimal
    }
    
    func formatCalories(_ calories: Double) -> String {
        guard let formatted = calorieFormatter.string(from: NSNumber(value: calories)) else {
            return "\(Int(calories)) kcal"
        }
        return "\(formatted) kcal"
    }
}
