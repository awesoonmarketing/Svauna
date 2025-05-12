//
//  LocalSessionStore.swift
//  Svauna Watch App
//
//  Created by Rasoul Rasouli on 2025-04-27.
//

import Foundation

final class LocalSessionStore {
    static let shared = LocalSessionStore()

    private let sessionsDirectoryName = "CompletedSessions"

    private var sessionsDirectoryURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(sessionsDirectoryName)
    }

    private init() {
        createSessionsDirectoryIfNeeded()
    }

    // MARK: - Directory Setup

    private func createSessionsDirectoryIfNeeded() {
        guard let url = sessionsDirectoryURL else { return }
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            } catch {
                print("❌ Failed to create sessions directory: \(error)")
            }
        }
    }

    // MARK: - Session Management

    func addSession(_ session: Session) {
        guard let url = sessionsDirectoryURL?.appendingPathComponent("\(session.id).json") else { return }
        do {
            let data = try JSONEncoder().encode(session)
            try data.write(to: url, options: .atomic)
        } catch {
            print("❌ Failed to save session: \(error)")
        }
    }

    func fetchAllSessions() -> [Session] {
        guard let url = sessionsDirectoryURL else { return [] }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            let sessions: [Session] = files.compactMap { fileURL in
                guard let data = try? Data(contentsOf: fileURL),
                      let session = try? JSONDecoder().decode(Session.self, from: data)
                else { return nil }
                return session
            }
            return sessions.sorted(by: { $0.startDate > $1.startDate })
        } catch {
            print("⚠️ Failed to fetch sessions: \(error)")
            return []
        }
    }

    func deleteSession(id: UUID) {
        guard let url = sessionsDirectoryURL?.appendingPathComponent("\(id).json") else { return }
        try? FileManager.default.removeItem(at: url)
    }

    func clearAllSessions() {
        guard let url = sessionsDirectoryURL else { return }
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("⚠️ Failed to clear sessions: \(error)")
        }
    }
}
