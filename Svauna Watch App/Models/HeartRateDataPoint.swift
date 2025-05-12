//
//  HeartRateDataPoint.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 4/28/25.
//

import Foundation

struct HeartRateDataPoint: Codable, Identifiable, Timestamped {
    let id: UUID
    let timestamp: Date
    let bpm: Int
    let source: String?
    
    init(bpm: Int, timestamp: Date = Date(), source: String? = nil) {
        self.id = UUID()
        self.bpm = bpm
        self.timestamp = timestamp
        self.source = source
    }
    
    var bpmDouble: Double {
        return Double(bpm)
    }
}
