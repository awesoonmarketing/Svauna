//
//  CaloriesQueryManager.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 4/28/25.
//

// Services/HealthKit/CaloriesQueryManager.swift

import Foundation
import HealthKit

final class CaloriesQueryManager {
    
    private let healthStore: HKHealthStore
    private var query: HKAnchoredObjectQuery?
    
    var onNewData: ((CaloriesDataPoint) -> Void)?
    
    init(healthStore: HKHealthStore) {
        self.healthStore = healthStore
    }
    
    func start(from startDate: Date) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
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
        guard let calorieSamples = samples as? [HKQuantitySample] else { return }
        
        for sample in calorieSamples {
            let activeCalories = sample.quantity.doubleValue(for: HKUnit.kilocalorie())
            let dataPoint = CaloriesDataPoint(activeCalories: activeCalories, totalCalories: activeCalories, timestamp: sample.startDate)
            
            print("🔥 Received Active Calories: \(Float(activeCalories)) kcal at \(sample.startDate)")
            
            onNewData?(dataPoint)
        }
    }
}
