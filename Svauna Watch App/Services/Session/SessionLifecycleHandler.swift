//
//  SessionLifecycleHandler.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 4/28/25.
//
// Services/Session/SessionLifecycleHandler.swift

import Foundation

final class SessionLifecycleHandler {
    
    private(set) var currentSession: Session?
    private(set) var sessionStartTime: Date?
    private(set) var accumulatedPauseTime: TimeInterval = 0
    private(set) var pauseStartTime: Date?
    
    var isTracking: Bool {
        return currentSession != nil
    }
    
    var isPaused: Bool {
        return pauseStartTime != nil
    }
    
    func startSession(ofType type: SessionType) {
        currentSession = Session(type: type)
        sessionStartTime = Date()
        accumulatedPauseTime = 0

        // ✅ Assign session ID to WorkoutSessionManager for HealthKit tracking
        WorkoutSessionManager.shared.sessionID = currentSession!.id

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let startDate = self?.sessionStartTime else { return }
            WatchHealthKitService.shared.startStreamingHealthData(startDate: startDate)
        }

        WatchCrashRecoveryService.shared.startSessionRecovery(for: currentSession!)
    }

    func pauseSession() {
        guard currentSession != nil, !isPaused else { return }
        
        pauseStartTime = Date()
        currentSession?.pauseSession(at: Date())
        WatchHealthKitService.shared.pauseHealthSession()
    }

    func resumeSession() {
        guard currentSession != nil, isPaused else { return }
        
        if let pausedAt = pauseStartTime {
            accumulatedPauseTime += Date().timeIntervalSince(pausedAt)
        }
        
        pauseStartTime = nil
        currentSession?.resumeSession(at: Date())
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let startDate = self?.sessionStartTime else { return }
            WatchHealthKitService.shared.resumeHealthSession(startDate: startDate)
        }
    }

    func endSession() {
        guard let session = currentSession else { return }

        currentSession?.endSession(at: Date())

        WatchHealthKitService.shared.stopStreamingHealthData()
        WatchCrashRecoveryService.shared.stopSessionRecovery()

        WatchConnectivityService.shared.sendSession(session)

        sessionStartTime = nil
        accumulatedPauseTime = 0
        pauseStartTime = nil
    }

    func addSegment() {
        guard currentSession != nil, !isPaused else { return }
        currentSession?.addSegment(at: Date())
    }
    
    func resumeRecoveredSession(_ recovered: Session) {
        currentSession = recovered
        sessionStartTime = recovered.startDate
        accumulatedPauseTime = 0
        pauseStartTime = recovered.state == .paused ? Date() : nil
        
        WorkoutSessionManager.shared.sessionID = recovered.id // ✅ Ensure assignment during recovery

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let startDate = self?.sessionStartTime else { return }
            WatchHealthKitService.shared.startStreamingHealthData(startDate: startDate)
        }

        WatchCrashRecoveryService.shared.startSessionRecovery(for: recovered)
    }

    func clear() {
        currentSession = nil
        sessionStartTime = nil
        accumulatedPauseTime = 0
        pauseStartTime = nil
    }
}
