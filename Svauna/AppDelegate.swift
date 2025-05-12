//
//  AppDelegate.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 2025-04-30.
//

import UIKit
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SvaunaModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("❌ Failed to load Core Data stack: \(error)")
            }
        }
        return container
    }()
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        HealthKitWorkoutImporter.shared.requestAuthorization { granted in
            guard granted else {
                print("❌ HealthKit authorization denied.")
                return
            }

            let daysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            HealthKitWorkoutImporter.shared.fetchRecentSessions(since: daysAgo) { sessions in
                print("🛬 Synced \(sessions.count) HealthKit sessions from Watch.")
                NotificationCenter.default.post(name: .didReceiveNewSvaunaSessionFile, object: nil)
            }
        }
    }
}
