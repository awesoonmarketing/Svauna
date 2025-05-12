//
//  SessionPersistenceManager.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 4/28/25.
//

// Services/CrashRecovery/SessionPersistenceManager.swift

import Foundation

final class SessionPersistenceManager {
    
    private let fileName = "current_session.json"
    
    private var fileURL: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent(fileName)
    }
    
    func save(_ session: Session) {
        do {
            let data = try JSONEncoder().encode(session)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("❌ Failed to save session: \(error)")
        }
    }
    
    func loadSession() -> Session? {
        do {
            let data = try Data(contentsOf: fileURL)
            let session = try JSONDecoder().decode(Session.self, from: data)
            return session
        } catch {
            if let cocoaError = error as NSError?, cocoaError.code == NSFileReadNoSuchFileError {
                print("ℹ️ No recoverable session found — starting fresh.")
            } else {
                print("⚠️ Failed to load recovery session: \(error)")
            }
            return nil
        }
    }

    
    func deleteCurrentSession() {
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("⚠️ Failed to delete current session: \(error)")
        }
    }
}
