//
//  HeartRateQueryManager.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 4/28/25.
//

// Services/HealthKit/HeartRateQueryManager.swift

import Foundation
import HealthKit

final class HeartRateQueryManager {
    
    private let healthStore: HKHealthStore
    private var query: HKAnchoredObjectQuery?
    
    var onNewData: ((HeartRateDataPoint) -> Void)?
    
    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }
    
    func start() {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        let startDate = Calendar.current.date(byAdding: .minute, value: -10, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nil)
        
        let query = HKAnchoredObjectQuery(type: quantityType, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] _, samples, _, _, _ in
            self?.processSamples(samples)
        }
        
        query.updateHandler = { [weak self] _, samples, _, _, _ in
            self?.processSamples(samples)
        }
        
        healthStore.execute(query)
        self.query = query
    }
    
    func stop() {
        if let query {
            healthStore.stop(query)
        }
    }
    
    private func processSamples(_ samples: [HKSample]?) {
        guard let heartSamples = samples as? [HKQuantitySample] else { return }
        
        for sample in heartSamples {
            let bpm = Int(sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())))
            let dataPoint = HeartRateDataPoint(bpm: bpm, timestamp: sample.startDate)
            
            print("❤️ Received Heart Rate: \(bpm) bpm at \(sample.startDate)")
            
            onNewData?(dataPoint)
        }
    }
}
