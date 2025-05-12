//
//  CaloriesDataPoint.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 4/28/25.
//

import Foundation

struct CaloriesDataPoint: Codable, Identifiable, Timestamped {
    let id: UUID
    let timestamp: Date
    let activeCalories: Double
    let totalCalories: Double
    
    init(activeCalories: Double, totalCalories: Double, timestamp: Date = Date()) {
        self.id = UUID()
        self.timestamp = timestamp
        self.activeCalories = activeCalories
        self.totalCalories = totalCalories
    }
}
