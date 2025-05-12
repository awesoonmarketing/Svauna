//
//  SessionMetricsBuffer.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 4/28/25.
//

// Services/HealthKit/SessionMetricsBuffer.swift

import Foundation

struct SessionMetricsBuffer {
    private(set) var heartRates: [HeartRateDataPoint] = []
    private(set) var calories: [CaloriesDataPoint] = []
    private(set) var bloodOxygenSamples: [BloodOxygenDataPoint] = []
    
    mutating func appendHeartRate(_ dataPoint: HeartRateDataPoint) {
        heartRates.append(dataPoint)
    }
    
    mutating func appendCalories(_ dataPoint: CaloriesDataPoint) {
        calories.append(dataPoint)
    }
    
    mutating func appendBloodOxygen(_ dataPoint: BloodOxygenDataPoint) {
        bloodOxygenSamples.append(dataPoint)
    }
    
    func latestHeartRate() -> HeartRateDataPoint? {
        heartRates.last
    }
    
    func latestCalories() -> CaloriesDataPoint? {
        calories.last
    }
    
    func latestBloodOxygen() -> BloodOxygenDataPoint? {
        bloodOxygenSamples.last
    }
}
