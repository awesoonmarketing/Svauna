//
//  CalendarViewModel.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 2025-04-29.
//

// Fixed CalendarViewModel.swift
import SwiftUI

final class CalendarViewModel: ObservableObject {
    @Published var displayedMonth: Date = Date()
    @Published var sessionsByDay: [Date: [Session]] = [:]
    @Published var selectedDate: Date = Date()
    
    private let sessionLoader = SessionPersistenceService.shared
    private var allSessions: [Session] = []
    private var calendar = Calendar.current
    
    init() {
        loadSessions()
        observeNewSessions()
    }
    
    func reloadSessions() {
        allSessions = SessionPersistenceService.shared.loadAll()
        updateSessionsForCurrentMonth()
        // Force a UI update after reloading
        objectWillChange.send()
    }
    
    private func loadSessions() {
        allSessions = SessionPersistenceService.shared.loadAll()
        updateSessionsForCurrentMonth()
    }
    
    private func observeNewSessions() {
        NotificationCenter.default.addObserver(forName: .didReceiveNewSvaunaSessionFile, object: nil, queue: .main) { [weak self] _ in
            self?.loadSessions()
        }
    }
    
    private func updateSessionsForCurrentMonth() {
        sessionsByDay = [:]
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                let sessions = allSessions.filter { calendar.isDate($0.startDate, inSameDayAs: date) }
                if !sessions.isEmpty {
                    sessionsByDay[calendar.startOfDay(for: date)] = sessions
                }
            }
        }
    }
    
    func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = newMonth
            updateSessionsForCurrentMonth()
        }
    }
    
    func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
            displayedMonth = newMonth
            updateSessionsForCurrentMonth()
        }
    }
    
    func hasSessions(on date: Date) -> Bool {
        sessionsByDay[calendar.startOfDay(for: date)] != nil
    }
    
    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    func isSelected(_ date: Date) -> Bool {
        calendar.isDate(selectedDate, inSameDayAs: date)
    }
    
    func select(date: Date) {
        selectedDate = date
        // Notify observers immediately after selection
        objectWillChange.send()
    }
}
