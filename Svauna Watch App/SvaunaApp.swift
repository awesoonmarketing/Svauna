//
//  SvaunaApp.swift
//  Svauna Watch App
//
//  Created by Rasoul Rasouli on 4/26/25.
//

import SwiftUI

@main
struct Svauna_Watch_AppApp: App {
    
    // Request HealthKit Authorization when app launches
    init() {
        _ = WatchCrashRecoveryService.shared.attemptSessionRecovery()

        WatchHealthKitService.shared.requestAuthorization { success in
            if success {
                print("✅ HealthKit access granted.")
            } else {
                print("❌ HealthKit access denied.")
            }
        }
    }

    
    var body: some Scene {
        WindowGroup {
            WatchHomeView()
        }
    }
}
