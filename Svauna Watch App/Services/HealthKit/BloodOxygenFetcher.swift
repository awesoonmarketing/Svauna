//
//  BloodOxygenFetcher.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 5/2/25.
//


import Foundation
import HealthKit

final class BloodOxygenFetcher {
    
    func fetchLatestSample(healthStore: HKHealthStore, completion: @escaping (BloodOxygenDataPoint?) -> Void) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation) else {
            completion(nil)
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: quantityType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil)
                return
            }
            
            let percentage = sample.quantity.doubleValue(for: HKUnit.percent()) * 100.0
            let dataPoint = BloodOxygenDataPoint(percentage: percentage, timestamp: sample.endDate)
            
            print("🩸 Received Blood Oxygen: \(String(format: "%.1f", percentage))% at \(sample.endDate)")
            
            completion(dataPoint)
        }
        
        healthStore.execute(query)
    }
}
