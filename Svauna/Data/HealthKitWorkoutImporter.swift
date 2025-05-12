//
//  HealthKitWorkoutImporter.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 5/6/25.
//


import Foundation
import HealthKit

final class HealthKitWorkoutImporter {
    
    static let shared = HealthKitWorkoutImporter()
    private init() {}
    
    private let healthStore = HKHealthStore()
    
    // MARK: - Request Authorization
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        let readTypes: Set<HKObjectType> = [
            .workoutType(),
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!
        ]

        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ HealthKit iOS auth failed: \(error.localizedDescription)")
                }
                completion(success)
            }
        }
    }
    
    // MARK: - Fetch + Import Workouts
    func fetchRecentSessions(since startDate: Date, completion: @escaping ([Session]) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: [])
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: 20, sortDescriptors: [sort]) { _, samples, error in
            guard let workouts = samples as? [HKWorkout], error == nil else {
                print("❌ Workout fetch error: \(error?.localizedDescription ?? "unknown")")
                completion([])
                return
            }

            let existingSessions = SessionPersistenceService.shared.loadAll()

            let sessions = workouts.compactMap { workout -> Session? in
                // 🔍 Check if similar session exists
                let isDuplicate = existingSessions.contains(where: { abs($0.startDate.timeIntervalSince(workout.startDate)) < 2 })
                guard !isDuplicate else { return nil }

                var session = Session(type: workout.workoutActivityType == .waterFitness ? .coldPlunge : .sauna, startDate: workout.startDate)
                session.endSession(at: workout.endDate)
                return session
            }

            sessions.forEach { SessionPersistenceService.shared.save($0) }

            DispatchQueue.main.async {
                completion(sessions)
            }
        }

        healthStore.execute(query)
    }

}
