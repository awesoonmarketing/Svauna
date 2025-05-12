//
//  WatchRouter.swift
//  Svauna Watch App
//
//  Created by Rasoul Rasouli on 4/27/25.
//

import Foundation
import SwiftUI
import Combine

enum WatchRoute: Hashable {
    case getReady(SessionType)
    case tracking(SessionType)
}

final class WatchRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        WatchSessionManager.shared.$isSessionActive
            .sink { [weak self] isActive in
                if !isActive {
                    self?.reset()
                }
            }
            .store(in: &cancellables)
    }
    
    func startSessionFlow(for sessionType: SessionType) {
        path.append(WatchRoute.getReady(sessionType))
    }
    
    func proceedToTracking(for sessionType: SessionType) {
        path.append(WatchRoute.tracking(sessionType))
    }
    
    func reset() {
        path = NavigationPath()
    }
}
