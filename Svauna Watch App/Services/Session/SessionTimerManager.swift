//
//  SessionTimerManager.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 4/28/25.
//
// Services/Session/SessionTimerManager.swift

import Foundation

final class SessionTimerManager {
    
    private var timer: Timer?
    private let startTime: Date
    private let getPauseStartTime: () -> Date?
    private let getAccumulatedPauseTime: () -> TimeInterval
    private let updateElapsedTime: (TimeInterval) -> Void
    private var secondsSinceLastBloodOxygenFetch: Int = 0

    
    init(startTime: Date,
         getPauseStartTime: @escaping () -> Date?,
         getAccumulatedPauseTime: @escaping () -> TimeInterval,
         updateElapsedTime: @escaping (TimeInterval) -> Void) {
        self.startTime = startTime
        self.getPauseStartTime = getPauseStartTime
        self.getAccumulatedPauseTime = getAccumulatedPauseTime
        self.updateElapsedTime = updateElapsedTime
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func tick() {
        let now = Date()
        let pauseStartTime = getPauseStartTime()
        let accumulated = getAccumulatedPauseTime()
        
        let elapsed: TimeInterval
        if let pausedAt = pauseStartTime {
            elapsed = pausedAt.timeIntervalSince(startTime) - accumulated
        } else {
            elapsed = now.timeIntervalSince(startTime) - accumulated
        }
        
        updateElapsedTime(elapsed)
        
        // ✅ Blood Oxygen Auto-Refresh Logic
        secondsSinceLastBloodOxygenFetch += 1
        if secondsSinceLastBloodOxygenFetch >= 300 { // 5 minutes = 300 seconds
            WatchHealthKitService.shared.fetchLatestBloodOxygenSample()
            secondsSinceLastBloodOxygenFetch = 0
        }
    }

}
