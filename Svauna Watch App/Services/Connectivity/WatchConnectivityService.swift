//
//  WatchConnectivityService.swift
//  Svauna Watch App
//
//  Created by Rasoul Rasouli on 2025-04-29.
//

import Foundation
import WatchConnectivity

final class WatchConnectivityService: NSObject, ObservableObject {
    
    static let shared = WatchConnectivityService()
    
    private let session = WCSession.default
    private var sessionsBeingSent = Set<UUID>() // Track sessions being transmitted
    
    private override init() {
        super.init()
        activateSessionIfNeeded()
    }
    
    private func activateSessionIfNeeded() {
        guard WCSession.isSupported() else {
            print("⚠️ WCSession is not supported on this device.")
            return
        }
        session.delegate = self
        session.activate()
    }
    
    /// 🔥 Call this to send a completed session to iPhone
    func sendSession(_ sessionData: Session) {
        do {
            let data = try JSONEncoder().encode(sessionData)
            let payload: [String: Any] = ["sessionData": data]

            // 🚚 Transfer guaranteed by WatchConnectivity
            session.transferUserInfo(payload)
            print("📤 transferUserInfo queued for session: \(sessionData.id)")

            // ❌ Don't delete here anymore — wait for confirmation or let retry handle it
            // WatchSessionPersistenceService.shared.delete(sessionData)
        } catch {
            print("❌ Encoding failed, queuing to disk: \(error.localizedDescription)")
            WatchSessionPersistenceService.shared.save(sessionData)
        }
    }
}

extension WatchConnectivityService: WCSessionDelegate {
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        
        if let error = error {
            print("❌ WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("✅ WCSession activated successfully.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.resendQueuedSessions()
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("📶 Reachability changed: \(session.isReachable)")
        if session.isReachable {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.resendQueuedSessions()
            }
        }
    }
    
    private func resendQueuedSessions() {
        let unsent = WatchSessionPersistenceService.shared.loadAll()
        let filteredUnsent = unsent.filter { !sessionsBeingSent.contains($0.id) }
        
        print("🔄 Attempting to resend \(filteredUnsent.count) unsent session(s)")
        
        for (index, session) in filteredUnsent.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) { [weak self] in
                self?.sendSession(session)
            }
        }
    }

    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any],
                 replyHandler: @escaping ([String : Any]) -> Void) {
        
        if message["requestSessions"] as? Bool == true {
            let sessions = SessionPersistenceService.shared.loadAll()
            let encodedSessions = sessions.compactMap { try? JSONEncoder().encode($0) }
            replyHandler(["sessions": encodedSessions])
            print("📤 Sent \(encodedSessions.count) session(s) to iPhone")
        }
    }
    
    // 2. Handles confirmation from iPhone after a session was received
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let confirmedID = message["confirmReceipt"] as? String,
           let uuid = UUID(uuidString: confirmedID) {
            var dummy = Session(type: .sauna)
            dummy.id = uuid
            WatchSessionPersistenceService.shared.delete(dummy)
            print("✅ Confirmation received — deleted session \(uuid)")
        }
    }
}
