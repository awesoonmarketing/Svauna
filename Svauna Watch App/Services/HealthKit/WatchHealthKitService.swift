//
//  WatchHealthKitService.swift
//  Svauna Watch App
//
//  Created by Rasoul Rasouli on 2025-04-27.
//

// Services/HealthKit/WatchHealthKitService.swift

import Foundation
import HealthKit
import Combine

final class WatchHealthKitService: NSObject, ObservableObject {
    
    // MARK: - Singleton
    static let shared = WatchHealthKitService()
    
    private override init() {
        super.init()
    }
    
    // MARK: - Services
    private let healthStore = HKHealthStore()
    private let workoutSessionManager = WorkoutSessionManager()
    private var heartRateManager: HeartRateQueryManager?
    private var caloriesManager: CaloriesQueryManager?
    private let bloodOxygenFetcher = BloodOxygenFetcher()
    @Published var totalActiveCalories: Double = 0.0
    private var bloodOxygenTimer: Timer?

    
    private var buffer = SessionMetricsBuffer()
    
    // MARK: - Publishers
    @Published var latestHeartRate: HeartRateDataPoint?
    @Published var latestCalories: CaloriesDataPoint?
    @Published var latestBloodOxygen: BloodOxygenDataPoint?
    
    // MARK: - Reset Total Calories
    func resetTotalActiveCalories() {
        totalActiveCalories = 0.0
    }
    
    // MARK: - Authorization
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!
        ]
        
        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.workoutType()
        ]
        
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ HealthKit authorization error: \(error.localizedDescription)")
                }
                completion(success)
            }
        }
    }
    
    
    
    // MARK: - Start Full Health Session
    func startFullHealthSession(for type: SessionType, startDate: Date) {
        resetTotalActiveCalories()
        workoutSessionManager.startWorkout(ofType: type)
        startStreamingHealthData(startDate: startDate)
        startBloodOxygenPolling() // 🩸 Add this line
    }

    
    

    
    func startStreamingHealthData(startDate: Date) {
        heartRateManager = HeartRateQueryManager(healthStore: healthStore)
        caloriesManager = CaloriesQueryManager(healthStore: healthStore)
        
        heartRateManager?.onNewData = { [weak self] dataPoint in
            self?.buffer.appendHeartRate(dataPoint)
            DispatchQueue.main.async {
                self?.latestHeartRate = dataPoint
            }
        }
        
        caloriesManager?.onNewData = { [weak self] dataPoint in
            self?.buffer.appendCalories(dataPoint)
            DispatchQueue.main.async {
                self?.latestCalories = dataPoint
                self?.totalActiveCalories += dataPoint.activeCalories
            }
        }
        
        heartRateManager?.start()
        caloriesManager?.start(from: startDate) // 🔥 pass session start time here
    }

    
    // MARK: - Pause
    func pauseHealthSession() {
        workoutSessionManager.pauseWorkout()
        stopStreamingHealthData()
    }
    
    // MARK: - Resume
    func resumeHealthSession(startDate: Date) {
        workoutSessionManager.resumeWorkout()
        startStreamingHealthData(startDate: startDate)
    }
    
    // MARK: - End
    func stopFullHealthSession() {
        workoutSessionManager.endWorkout()
        stopStreamingHealthData()
        stopBloodOxygenPolling() // 🛑 Add this

    }
    
    func stopStreamingHealthData() {
        heartRateManager?.stop()
        caloriesManager?.stop()
    }
    
    // MARK: - Blood Oxygen (Optional)
    func fetchLatestBloodOxygenSample() {
        bloodOxygenFetcher.fetchLatestSample(healthStore: healthStore) { [weak self] dataPoint in
            guard let dataPoint = dataPoint else { return }
            self?.buffer.appendBloodOxygen(dataPoint)
            DispatchQueue.main.async {
                self?.latestBloodOxygen = dataPoint
            }
        }
    }
    
    private func startBloodOxygenPolling() {
        bloodOxygenTimer?.invalidate() // Clear existing timer if any

        bloodOxygenTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            self?.fetchLatestBloodOxygenSample()
        }

        // Fire immediately once so you get a datapoint up front
        fetchLatestBloodOxygenSample()
    }

    private func stopBloodOxygenPolling() {
        bloodOxygenTimer?.invalidate()
        bloodOxygenTimer = nil
    }

    
    var sessionMetrics: SessionMetricsBuffer {
        return buffer
    }

}
