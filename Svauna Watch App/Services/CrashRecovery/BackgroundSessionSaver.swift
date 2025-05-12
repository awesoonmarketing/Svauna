//
//  BackgroundSessionSaver.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 4/28/25.
//

// Services/CrashRecovery/BackgroundSessionSaver.swift

import Foundation

final class BackgroundSessionSaver {
    
    private var timer: Timer?
    private let saveInterval: TimeInterval
    private let saveAction: () -> Void
    
    init(saveInterval: TimeInterval, saveAction: @escaping () -> Void) {
        self.saveInterval = saveInterval
        self.saveAction = saveAction
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: saveInterval, repeats: true) { [weak self] _ in
            self?.saveAction()
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
