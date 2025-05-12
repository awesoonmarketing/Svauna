//
//  SvaunaApp.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 4/26/25.
//

import SwiftUI

@main
struct SvaunaApp: App {
    
    init() {
        // ✅ Force WatchConnectivityService initialization at launch
        _ = WatchConnectivityService.shared
    }

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
