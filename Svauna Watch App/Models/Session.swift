//
//  Session.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 4/28/25.
//


import Foundation

struct Session: Codable, Identifiable {
    var id: UUID
    var type: SessionType
    var startDate: Date
    var endDate: Date?
    var segments: [SessionSegment]
    var heartRateData: [HeartRateDataPoint]
    var caloriesData: [CaloriesDataPoint]
    var bloodOxygenData: [BloodOxygenDataPoint]
    var state: SessionState
    
    init(type: SessionType, startDate: Date = Date()) {
        self.id = UUID()
        self.type = type
        self.startDate = startDate
        self.endDate = nil
        self.segments = [SessionSegment(startTime: startDate)]
        self.heartRateData = []
        self.caloriesData = []
        self.bloodOxygenData = []
        self.state = .active
    }
    
    var totalDuration: TimeInterval? {
        guard let endDate else { return nil }
        return endDate.timeIntervalSince(startDate)
    }
    
    var totalActiveCalories: Double {
        caloriesData.reduce(0) { $0 + $1.activeCalories }
    }
    
    var averageHeartRate: Double? {
        guard !heartRateData.isEmpty else { return nil }
        let total = heartRateData.reduce(0) { $0 + $1.bpm }
        return Double(total) / Double(heartRateData.count)
    }
    
    mutating func endSession(at date: Date) {
        guard state != .completed else { return }
        self.endDate = date
        self.state = .completed
        
        if var lastSegment = segments.last, lastSegment.endTime == nil {
            lastSegment.endTime = date
            segments[segments.count - 1] = lastSegment
        }
    }
    
    mutating func pauseSession(at date: Date) {
        guard state == .active else { return }
        self.state = .paused
        if var lastSegment = segments.last, lastSegment.endTime == nil {
            lastSegment.endTime = date
            segments[segments.count - 1] = lastSegment
        }
    }
    
    mutating func resumeSession(at date: Date) {
        guard state == .paused else { return }
        self.state = .active
        segments.append(SessionSegment(startTime: date))
    }
    
    mutating func addSegment(at date: Date) {
        if var lastSegment = segments.last, lastSegment.endTime == nil {
            lastSegment.endTime = date
            segments[segments.count - 1] = lastSegment
        }
        segments.append(SessionSegment(startTime: date))
    }
}
