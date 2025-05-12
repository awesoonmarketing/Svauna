//
//  WorkoutSessionManager.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 2025-04-28.
//
// Services/HealthKit/WorkoutSessionManager.swift

import Foundation
import HealthKit

final class WorkoutSessionManager: NSObject, ObservableObject {

    static let shared = WorkoutSessionManager() // ✅ Singleton access

    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?
    private var totalActiveCalories: Double = 0.0

    var sessionID: UUID? // ✅ Was private — now internal so it can be set externally

    override init() {
        super.init()
    }
    
    // MARK: - Start Workout Session
    
    func startWorkout(ofType type: SessionType) {
        guard workoutSession?.state != .running else {
            print("⚠️ Workout already running.")
            return
        }


        let configuration = HKWorkoutConfiguration()
        configuration.locationType = .indoor

        switch type {
        case .sauna:
            configuration.activityType = .mindAndBody
        case .coldPlunge:
            configuration.activityType = .waterFitness
        }

        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            workoutBuilder = workoutSession?.associatedWorkoutBuilder()
            workoutBuilder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
            workoutSession?.delegate = self
            workoutBuilder?.delegate = self

            let now = Date()
            workoutSession?.startActivity(with: now)
            workoutBuilder?.beginCollection(withStart: now) { success, error in
                if let error = error {
                    print("❌ Workout Builder Begin Error: \(error.localizedDescription)")
                }
            }
        } catch {
            print("❌ Failed to start workout session: \(error.localizedDescription)")
        }
    }

    
    // MARK: - Pause
    
    func pauseWorkout() {
        workoutSession?.pause()
    }
    
    // MARK: - Resume
    
    func resumeWorkout() {
        workoutSession?.resume()
    }
    
    // MARK: - End Workout
    
    // End Workout Properly (new improved method)
    func endWorkout() {
        workoutSession?.end()
        
        workoutBuilder?.endCollection(withEnd: Date()) { [weak self] success, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Failed to end workout collection: \(error.localizedDescription)")
                return
            }

            let metadata: [String: Any] = {
                guard let sessionID = self.sessionID else { return [:] }
                return [HKMetadataKeyExternalUUID: sessionID.uuidString]
            }()

            self.workoutBuilder?.finishWorkout { workout, error in
                if let error = error {
                    print("❌ Failed to finish workout: \(error.localizedDescription)")
                } else if let workout = workout {
                    print("✅ Workout saved with ID: \(self.sessionID?.uuidString ?? "unknown")")
                }            }

        }
    }



}

// MARK: - HKWorkoutSessionDelegate

extension WorkoutSessionManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("Workout session changed from \(fromState.rawValue) to \(toState.rawValue)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed with error: \(error.localizedDescription)")
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate

extension WorkoutSessionManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // No-op for now
    }
    
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }
            
            if quantityType == HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
                let statistics = workoutBuilder.statistics(for: quantityType)
                if let totalEnergy = statistics?.sumQuantity() {
                    let kcal = totalEnergy.doubleValue(for: HKUnit.kilocalorie())
                    print("🔥 Cumulative Active Calories: \(kcal) kcal")
                    totalActiveCalories = kcal
                }
            }
        }
    }

}
