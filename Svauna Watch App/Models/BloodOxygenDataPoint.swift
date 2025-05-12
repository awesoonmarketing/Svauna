//
//  BloodOxygenDataPoint.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 4/28/25.
//


import Foundation

struct BloodOxygenDataPoint: Codable, Identifiable, Timestamped {
    let id: UUID
    let timestamp: Date
    let percentage: Double
    let confidence: Double?
    
    init(percentage: Double, confidence: Double? = nil, timestamp: Date = Date()) {
        self.id = UUID()
        self.timestamp = timestamp
        self.percentage = percentage
        self.confidence = confidence
    }
    
    var isFresh: Bool {
        // Sample is considered fresh if it's less than 5 minutes old
        return Date().timeIntervalSince(timestamp) < 300
    }
}
