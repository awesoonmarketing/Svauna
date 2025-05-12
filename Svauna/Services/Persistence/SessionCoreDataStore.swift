//
//  SessionCoreDataStore.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 2025-04-30.
//

import Foundation
import CoreData
import SwiftUI

final class SessionCoreDataStore {
    
    static let shared = SessionCoreDataStore()
    private init() {}

    // MARK: - Core Data Context
    private var context: NSManagedObjectContext {
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        return container.viewContext
    }

    // MARK: - Save Session
    func save(_ session: Session) {
        let cd = CDSession(context: context)
        cd.id = session.id
        cd.type = session.type.rawValue
        cd.state = session.state.rawValue
        cd.startDate = session.startDate
        cd.endDate = session.endDate
        cd.heartRateData = try? JSONEncoder().encode(session.heartRateData)
        cd.caloriesData = try? JSONEncoder().encode(session.caloriesData)
        cd.bloodOxygenData = try? JSONEncoder().encode(session.bloodOxygenData)
        cd.segmentsData = try? JSONEncoder().encode(session.segments)
        
        do {
            try context.save()
            print("💾 Core Data: Saved session \(session.id)")
        } catch {
            print("❌ Core Data Save Error: \(error.localizedDescription)")
        }
    }

    // MARK: - Load All Sessions
    func loadAll() -> [Session] {
        let request: NSFetchRequest<CDSession> = CDSession.fetchRequest()
        
        do {
            let cds = try context.fetch(request)
            return cds.compactMap { toSession(from: $0) }
        } catch {
            print("❌ Core Data Fetch Error: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Convert CDSession → Session
    private func toSession(from cd: CDSession) -> Session? {
        guard
            let type = SessionType(rawValue: cd.type!),
            let state = SessionState(rawValue: cd.state!)
        else {
            return nil
        }

        var session = Session(type: type, startDate: cd.startDate!)
        session.id = cd.id!
        session.endDate = cd.endDate
        session.state = state
        
        if let data = cd.heartRateData {
            session.heartRateData = (try? JSONDecoder().decode([HeartRateDataPoint].self, from: data)) ?? []
        }
        
        if let data = cd.caloriesData {
            session.caloriesData = (try? JSONDecoder().decode([CaloriesDataPoint].self, from: data)) ?? []
        }
        
        if let data = cd.bloodOxygenData {
            session.bloodOxygenData = (try? JSONDecoder().decode([BloodOxygenDataPoint].self, from: data)) ?? []
        }

        if let data = cd.segmentsData {
            session.segments = (try? JSONDecoder().decode([SessionSegment].self, from: data)) ?? []
        }

        return session
    }

    // MARK: - Delete All (for dev/testing)
    func deleteAll() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CDSession.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
            print("🗑 Deleted all sessions from Core Data")
        } catch {
            print("❌ Core Data Delete Error: \(error.localizedDescription)")
        }
    }
}
