//
//  SessionPersistenceService.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 4/30/25.
//

import CoreData
import SwiftUI

final class SessionPersistenceService {
    
    static let shared = SessionPersistenceService()
    
    private let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "SvaunaModel") // Replace with your actual .xcdatamodeld filename if different
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("❌ Failed to load Core Data store: \(error.localizedDescription)")
            }
            print("✅ Core Data loaded: \(description.url?.absoluteString ?? "nil")")
        }
    }
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    // MARK: - Save
    func save(_ session: Session) {
        let request: NSFetchRequest<CDSession> = CDSession.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", session.id as CVarArg)
        request.fetchLimit = 1

        let entity: CDSession
        if let existing = try? context.fetch(request).first {
            entity = existing
        } else {
            entity = CDSession(context: context)
            entity.id = session.id
        }

        entity.type = session.type.rawValue
        entity.startDate = session.startDate
        entity.endDate = session.endDate
        entity.state = session.state.rawValue

        entity.segmentsData = try? JSONEncoder().encode(session.segments)
        entity.heartRateData = try? JSONEncoder().encode(session.heartRateData)
        entity.caloriesData = try? JSONEncoder().encode(session.caloriesData)
        entity.bloodOxygenData = try? JSONEncoder().encode(session.bloodOxygenData)

        do {
            try context.save()
            print("💾 Core Data session saved: \(session.id)")
        } catch {
            print("❌ Failed to save session to Core Data: \(error.localizedDescription)")
        }
    }

    
    // MARK: - Load
    
    func loadAll() -> [Session] {
        let request: NSFetchRequest<CDSession> = CDSession.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        
        do {
            let results = try context.fetch(request)
            return results.compactMap { cd in
                var session = Session(type: SessionType(rawValue: cd.type ?? "") ?? .sauna)
                session.id = cd.id ?? UUID()
                session.startDate = cd.startDate ?? Date()
                session.endDate = cd.endDate
                session.state = SessionState(rawValue: cd.state ?? "") ?? .completed

                if let segmentsData = cd.segmentsData {
                    session.segments = (try? JSONDecoder().decode([SessionSegment].self, from: segmentsData)) ?? []
                }
                if let hrData = cd.heartRateData {
                    session.heartRateData = (try? JSONDecoder().decode([HeartRateDataPoint].self, from: hrData)) ?? []
                }
                if let calData = cd.caloriesData {
                    session.caloriesData = (try? JSONDecoder().decode([CaloriesDataPoint].self, from: calData)) ?? []
                }
                if let oxyData = cd.bloodOxygenData {
                    session.bloodOxygenData = (try? JSONDecoder().decode([BloodOxygenDataPoint].self, from: oxyData)) ?? []
                }

                return session
            }
        } catch {
            print("❌ Failed to fetch sessions from Core Data: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Delete
    
    func deleteSession(with id: UUID) {
        let request: NSFetchRequest<CDSession> = CDSession.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        if let sessionToDelete = try? context.fetch(request).first {
            context.delete(sessionToDelete)
            try? context.save()
            print("🗑 Deleted Core Data session: \(id)")
        }
    }
    
    func deleteAllSessions() {
        let request: NSFetchRequest<NSFetchRequestResult> = CDSession.fetchRequest()
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        _ = try? context.execute(delete)
        print("🧹 Cleared all sessions from Core Data.")
    }
}
