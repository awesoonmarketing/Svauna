
//  WatchHomeViewModel.swift
//  Svauna Watch App
//
//  Created by Rasoul Rasouli on 2025-04-27.
//
//  ViewModels/Watch/WatchHomeViewModel.swift

import Foundation
import Combine

// MARK: - Session Action Enum

enum SessionAction {
    case startNew(SessionType)
    case resumeExisting
    case confirmSwitch(to: SessionType)
}

// MARK: - ViewModel

final class WatchHomeViewModel: ObservableObject {
    
    // MARK: - Published State
    
    @Published private(set) var recoveredSessionAvailable: Bool = false
    @Published private(set) var pastSessions: [Session] = []
    
    @Published var currentElapsedTime: TimeInterval = 0
    @Published var currentSessionType: SessionType = .sauna
    
    // MARK: - Dependencies
    
    private let sessionManager = WatchSessionManager.shared
    private let crashRecoveryService = WatchCrashRecoveryService.shared
    private let calendar = Calendar.current
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    func onAppear() {
        recoveredSessionAvailable = crashRecoveryService.attemptSessionRecovery()

        sessionManager.$elapsedTime
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentElapsedTime)

        sessionManager.$session
            .compactMap { $0?.type }
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentSessionType)

        loadPastSessions()
    }
    
    private func loadPastSessions() {
        pastSessions = SessionPersistenceService.shared.loadAll()
    }
    
    // MARK: - Computed Stats
    
    var hasRecentSessions: Bool {
        !pastSessions.isEmpty
    }
    
    var weeklySessionCount: Int {
        let weekOfYear = calendar.component(.weekOfYear, from: Date())
        let year = calendar.component(.yearForWeekOfYear, from: Date())
        
        return pastSessions.filter {
            let comps = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: $0.startDate)
            return comps.weekOfYear == weekOfYear && comps.yearForWeekOfYear == year
        }.count
    }
    
    var totalMinutesThisMonth: Int {
        let month = calendar.component(.month, from: Date())
        let year = calendar.component(.year, from: Date())

        let seconds = pastSessions
            .filter {
                let comps = calendar.dateComponents([.month, .year], from: $0.startDate)
                return comps.month == month && comps.year == year
            }
            .compactMap { $0.totalDuration }
            .reduce(0, +)

        return Int(seconds / 60)
    }
    
    // MARK: - Session Handling
    
    func handleSessionTap(for type: SessionType) -> SessionAction {
        if let activeSession = sessionManager.session {
            if activeSession.type == type {
                return .resumeExisting
            } else {
                return .confirmSwitch(to: type)
            }
        } else {
            return .startNew(type)
        }
    }
    
    func startSession(ofType type: SessionType) {
        sessionManager.startSession(ofType: type)
        recoveredSessionAvailable = false
    }
    
    func resumeRecoveredSession() {
        guard let recovered = crashRecoveryService.recoveredSession else {
            recoveredSessionAvailable = false
            return
        }
        sessionManager.resumeRecoveredSession(recovered)
        recoveredSessionAvailable = false
    }
    
    func endCurrentSession() {
        sessionManager.endSession()
    }
}
