
//  WatchSessionManager.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 4/28/25.
//
// Services/Session/WatchSessionManager.swift


import Foundation
import Combine

final class WatchSessionManager: ObservableObject {
    
    static let shared = WatchSessionManager()
    
    private init() {}
    
    // MARK: - Core Session State
    @Published private(set) var session: Session?
    @Published private(set) var isTracking: Bool = false
    @Published private(set) var isPaused: Bool = false
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published private(set) var isSessionActive: Bool = false

    private var sessionLifecycle = SessionLifecycleHandler()
    private var timerManager: SessionTimerManager?
    private let workoutSessionManager = WorkoutSessionManager() // 👈 Important
    
}

// MARK: - Public API (Session Controls)

extension WatchSessionManager {
    
    func startSession(ofType type: SessionType) {
        sessionLifecycle.startSession(ofType: type)
        session = sessionLifecycle.currentSession
        isTracking = true
        isPaused = false
        elapsedTime = 0
        isSessionActive = true
        
        if let startTime = sessionLifecycle.sessionStartTime {
//            workoutSessionManager.startWorkout(ofType: type)
            
            WatchHealthKitService.shared.startFullHealthSession(for: type, startDate: startTime) // 🔥 Pass startTime
            timerManager = SessionTimerManager(
                startTime: startTime,
                getPauseStartTime: { self.sessionLifecycle.pauseStartTime },
                getAccumulatedPauseTime: { self.sessionLifecycle.accumulatedPauseTime },
                updateElapsedTime: { [weak self] elapsed in
                    self?.elapsedTime = elapsed
                }
            )
            timerManager?.start()
        }
    }

    
    func pauseSession() {
        sessionLifecycle.pauseSession()
        isPaused = true
        timerManager?.stop()
        
        workoutSessionManager.pauseWorkout() // 👈 Pause workout session
    }
    
    func resumeSession() {
        sessionLifecycle.resumeSession()
        isPaused = false
        timerManager?.start()
        
        workoutSessionManager.resumeWorkout() // 👈 Resume workout session
    }
    
    func addSegment() {
        sessionLifecycle.addSegment()
    }
    
    func endSession() {
        guard isTracking else {
            print("⚠️ No session to end.")
            return
        }

        // 1. End lifecycle and get finalized session
        sessionLifecycle.endSession()
        guard var finalSession = sessionLifecycle.currentSession else {
            print("❌ No session data found after ending.")
            return
        }

        // 2. Add buffered HealthKit data
        let metrics = WatchHealthKitService.shared.sessionMetrics
        finalSession.heartRateData = metrics.heartRates
        finalSession.caloriesData = metrics.calories
        finalSession.bloodOxygenData = metrics.bloodOxygenSamples

        // 3. Update state
        isTracking = false
        isPaused = false
        isSessionActive = false
        elapsedTime = 0
        timerManager?.stop()
        timerManager = nil
        workoutSessionManager.endWorkout()

        // 4. Save to disk (optional backup)
        SessionPersistenceService.shared.save(finalSession)

        // 5. Send session to iPhone
        WatchConnectivityService.shared.sendSession(finalSession)

        // 6. Stop streaming HealthKit data
        WatchHealthKitService.shared.stopFullHealthSession()

        // 7. Cleanup
        session = nil
        sessionLifecycle.clear()

        print("✅ Session ended and synced.")
    }


    
    func resumeRecoveredSession(_ recovered: Session) {
        sessionLifecycle.resumeRecoveredSession(recovered)
        session = recovered
        isTracking = true
        isPaused = (recovered.state == .paused)
        elapsedTime = 0
        isSessionActive = true
        
        // 👉 Optionally could restart workoutSessionManager here if needed
        
        if let startTime = sessionLifecycle.sessionStartTime {
            timerManager = SessionTimerManager(
                startTime: startTime,
                getPauseStartTime: { self.sessionLifecycle.pauseStartTime },
                getAccumulatedPauseTime: { self.sessionLifecycle.accumulatedPauseTime },
                updateElapsedTime: { [weak self] elapsed in
                    self?.elapsedTime = elapsed
                }
            )
            timerManager?.start()
        }
    }
}
