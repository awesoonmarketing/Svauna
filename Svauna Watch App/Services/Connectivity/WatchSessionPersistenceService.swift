//
//  WatchSessionPersistenceService.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 5/1/25.
//

import Foundation

final class WatchSessionPersistenceService {
    
    static let shared = WatchSessionPersistenceService()
    private init() {}
    
    private let directoryName = "QueuedSessions"
    
    private var sessionsDirectory: URL {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docDir.appendingPathComponent(directoryName)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    func save(_ session: Session) {
        let path = sessionsDirectory.appendingPathComponent("\(session.id.uuidString).json")
        do {
            let data = try JSONEncoder().encode(session)
            try data.write(to: path)
            print("💾 Queued session saved: \(path.lastPathComponent)")
        } catch {
            print("❌ Failed to persist session: \(error.localizedDescription)")
        }
    }
    
    func delete(_ session: Session) {
        let path = sessionsDirectory.appendingPathComponent("\(session.id.uuidString).json")
        try? FileManager.default.removeItem(at: path)
        print("🗑 Removed session from queue: \(path.lastPathComponent)")
    }
    
    func loadAll() -> [Session] {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: sessionsDirectory, includingPropertiesForKeys: nil)
            return files.compactMap {
                guard let data = try? Data(contentsOf: $0) else { return nil }
                return try? JSONDecoder().decode(Session.self, from: data)
            }
        } catch {
            print("❌ Failed to load queued sessions: \(error.localizedDescription)")
            return []
        }
    }
}
