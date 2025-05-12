//
//  HistoryIndexViewModel.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 2025-04-29.
//

import SwiftUI
import Foundation

final class HistoryIndexViewModel: ObservableObject {
    @Published var sessions: [Session] = []

    private let sessionLoader = SessionPersistenceService.shared
    private var calendar = Calendar.current
    private var observedDate: Date

    init(for date: Date) {
        self.observedDate = date
        loadSessions(for: date)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewSessionFile),
            name: .didReceiveNewSvaunaSessionFile,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func reload(for date: Date) {
        observedDate = date
        loadSessions(for: date)
    }

    private func loadSessions(for date: Date) {
        let allSessions = SessionPersistenceService.shared.loadAll()

        sessions = allSessions.filter {
            calendar.isDate($0.startDate, inSameDayAs: date)
        }.sorted(by: { $0.startDate > $1.startDate })
    }

    @objc private func handleNewSessionFile() {
        DispatchQueue.main.async {
            self.loadSessions(for: self.observedDate)
        }
    }
}
