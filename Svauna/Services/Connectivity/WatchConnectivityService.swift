//
//  WatchConnectivityService.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 2025-04-29.
//

import Foundation
import WatchConnectivity

final class WatchConnectivityService: NSObject, ObservableObject {
    
    static let shared = WatchConnectivityService()
    
    private let session = WCSession.default
    
    private override init() {
        super.init()
        activateSessionIfNeeded()
    }
    
    private func activateSessionIfNeeded() {
        guard WCSession.isSupported() else {
            print("⚠️ WCSession not supported on this device.")
            return
        }
        session.delegate = self
        session.activate()
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityService: WCSessionDelegate {
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Not needed now.
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Re-activate when switching watches
        self.session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("❌ WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("✅ WCSession activated on iPhone.")
        }
    }

    // ✅ New: Handle sessions sent via sendMessage
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let data = message["sessionData"] as? Data {
            do {
                let session = try JSONDecoder().decode(Session.self, from: data)
                SessionPersistenceService.shared.save(session)
                NotificationCenter.default.post(name: .didReceiveNewSvaunaSessionFile, object: nil)
                replyHandler(["status": "received"])
                print("📥 Received and saved session: \(session.id)")
            } catch {
                replyHandler(["status": "error", "reason": error.localizedDescription])
                print("❌ Failed to decode session: \(error.localizedDescription)")
            }
        }
    }
    
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        if let data = userInfo["sessionData"] as? Data {
            do {
                let session = try JSONDecoder().decode(Session.self, from: data)
                SessionPersistenceService.shared.save(session)
                NotificationCenter.default.post(name: .didReceiveNewSvaunaSessionFile, object: nil)
                print("📥 Received session via transferUserInfo: \(session.id)")

                // ✅ Send confirmation to Watch using sendMessage (fire-and-forget acknowledgment)
                if WCSession.default.isReachable {
                    WCSession.default.sendMessage(
                        ["confirmReceipt": session.id.uuidString],
                        replyHandler: nil,
                        errorHandler: { error in
                            print("⚠️ Could not send confirmation for \(session.id): \(error.localizedDescription)")
                        }
                    )
                }
            } catch {
                print("❌ Failed to decode session via transferUserInfo: \(error.localizedDescription)")
            }
        } else {
            print("⚠️ Received userInfo without session data.")
        }
    }



    
    func requestMissedSessionsFromWatch(completion: @escaping ([Session]) -> Void) {
        guard session.activationState == .activated else {
            print("⚠️ WCSession is not activated.")
            completion([])
            return
        }

        session.sendMessage(["requestSessions": true], replyHandler: { response in
            if let encodedSessions = response["sessions"] as? [Data] {
                let sessions = encodedSessions.compactMap { try? JSONDecoder().decode(Session.self, from: $0) }
                print("📥 Pulled \(sessions.count) session(s) from Watch.")
                sessions.forEach { SessionPersistenceService.shared.save($0) }
                NotificationCenter.default.post(name: .didReceiveNewSvaunaSessionFile, object: nil)
                completion(sessions)
            } else {
                print("⚠️ No sessions returned.")
                completion([])
            }
        }, errorHandler: { error in
            print("❌ Failed to request sessions from Watch: \(error.localizedDescription)")
            completion([])
        })
    }

    
    

}
