//
//  SessionSegment.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 4/28/25.
//

// Models/SessionSegment.swift

import Foundation

struct SessionSegment: Codable, Identifiable {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    
    init(startTime: Date) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = nil
    }
    
    var duration: TimeInterval? {
        guard let endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
}
