//
//  HomeViewModel.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 2025-04-29.
//

import Foundation
import Combine

// Fix for HomeViewModel.swift
// Updated HomeViewModel.swift with better observation pattern
@MainActor
final class HomeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var sessions: [Session] = []
    @Published var isLoading: Bool = false
    @Published var latestSession: Session?
    @Published var calendarViewModel = CalendarViewModel()
    @Published var sessionsForSelectedDay: [Session] = []
    private var loadedSessionIDs = Set<UUID>()

    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupObservers()
        loadSessions()
        
        // Observe both selectedDate changes AND objectWillChange notifications
        calendarViewModel.$selectedDate
            .sink { [weak self] _ in
                self?.updateSessionsForSelectedDay()
            }
            .store(in: &cancellables)
        
        // Add this to catch manual objectWillChange.send() notifications
        calendarViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.updateSessionsForSelectedDay()
            }
            .store(in: &cancellables)
    }
    
    private func setupObservers() {
        NotificationCenter.default.publisher(for: .didReceiveNewSvaunaSessionFile)
            .sink { [weak self] _ in
                self?.loadSessions()
            }
            .store(in: &cancellables)
    }
    
    func loadSessions() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let loadedSessions = SessionPersistenceService.shared.loadAll()

            DispatchQueue.main.async {
                let newSessions = loadedSessions.filter { !self.loadedSessionIDs.contains($0.id) }

                guard !newSessions.isEmpty else {
                    self.isLoading = false
                    return
                }

                self.loadedSessionIDs.formUnion(newSessions.map(\.id)) // ✅ Track them
                self.sessions.append(contentsOf: newSessions)
                self.sessions.sort(by: { $0.startDate > $1.startDate })
                self.latestSession = self.sessions.first
                self.isLoading = false

                self.calendarViewModel.reloadSessions()
                self.updateSessionsForSelectedDay()
            }
        }
    }


    // Make sure this is executed whenever the selected date changes
    private func updateSessionsForSelectedDay() {
        let selectedDate = calendarViewModel.selectedDate
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        self.sessionsForSelectedDay = calendarViewModel.sessionsByDay[startOfDay] ?? []
        
        // Debug print to verify updates
        print("📅 Updated sessions for \(selectedDate): found \(self.sessionsForSelectedDay.count) sessions")
    }
}
