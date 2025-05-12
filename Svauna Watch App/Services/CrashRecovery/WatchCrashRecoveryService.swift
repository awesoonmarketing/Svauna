//
//  WatchCrashRecoveryService.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 4/28/25.
//

// Services/CrashRecovery/WatchCrashRecoveryService.swift

import Foundation

final class WatchCrashRecoveryService: ObservableObject {
    
    static let shared = WatchCrashRecoveryService()
    
    private let persistenceManager = SessionPersistenceManager()
    private var backgroundSaver: BackgroundSessionSaver?
    
    private init() {}
    
    @Published var recoveredSession: Session?
    
    // MARK: - Start Session
    func startSessionRecovery(for session: Session) {
        backgroundSaver = BackgroundSessionSaver(saveInterval: 10) { [weak self] in
            self?.saveSession(session)
        }
        backgroundSaver?.start()
    }
    
    // MARK: - Save
    func saveSession(_ session: Session) {
        persistenceManager.save(session)
    }
    
    // MARK: - Stop
    func stopSessionRecovery() {
        backgroundSaver?.stop()
        backgroundSaver = nil
        persistenceManager.deleteCurrentSession()
    }
    
    func attemptSessionRecovery() -> Bool {
        guard let session = persistenceManager.loadSession() else {
            print("🟡 No crashed session found.")
            return false
        }

        guard session.state == .active || session.state == .paused else {
            print("ℹ️ Last session was completed.")
            persistenceManager.deleteCurrentSession()
            return false
        }

        print("♻️ Recovered crashed session: \(session.id)")

        var finished = session
        finished.endSession(at: Date())

        WatchHealthKitService.shared.stopFullHealthSession()
        SessionPersistenceService.shared.save(finished)
        WatchConnectivityService.shared.sendSession(finished)
        persistenceManager.deleteCurrentSession()

        return true
    }


}
