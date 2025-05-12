//
//  WatchTrackingViewModel.swift
//  Svauna Watch App
//
//  Created by Rasoul Rasouli on 2025-04-27.
//
//  ViewModels/Watch/WatchTrackingViewModel.swift

import Foundation
import Combine
import WatchKit

final class WatchTrackingViewModel: ObservableObject {
    
    // MARK: - Published States
    @Published var elapsedTime: TimeInterval = 0
    @Published var heartRate: Int = 0
    @Published var activeCalories: Double = 0
    @Published var totalActiveCalories: Double = 0
    @Published var bloodOxygen: Double?
    @Published var isPaused: Bool = false
    @Published var sessionType: SessionType = .sauna // default for bg color
    
    private var cancellables = Set<AnyCancellable>()
    private var sessionStarted = false
    
    private let sessionManager = WatchSessionManager.shared
    private let healthService = WatchHealthKitService.shared
}

// MARK: - Setup Subscriptions
extension WatchTrackingViewModel {
    
    func onAppear() {
        // Reset total calories when view appears
        totalActiveCalories = 0
        sessionStarted = false
        
        bindSession()
        bindHealthData()
    }
    
    private func bindSession() {
        sessionManager.$elapsedTime
            .receive(on: DispatchQueue.main)
            .assign(to: &$elapsedTime)
        
        sessionManager.$isPaused
            .receive(on: DispatchQueue.main)
            .assign(to: &$isPaused)
        
        if let type = sessionManager.session?.type {
            sessionType = type
        }
    }

    private func bindHealthData() {
        // Reset total calories at the start of tracking
        totalActiveCalories = 0
        
        // Heart rate binding
        healthService.$latestHeartRate
            .compactMap { $0?.bpm }
            .receive(on: DispatchQueue.main)
            .assign(to: &$heartRate)
        
        // Reset the accumulator in WatchHealthKitService
        healthService.resetTotalActiveCalories()
        
        // Bind directly to the service's total calories
        healthService.$totalActiveCalories
            .receive(on: DispatchQueue.main)
            .assign(to: &$totalActiveCalories)
        
        // Blood oxygen binding
        healthService.$latestBloodOxygen
            .compactMap { $0?.percentage }
            .receive(on: DispatchQueue.main)
            .assign(to: &$bloodOxygen)
    }
}

// MARK: - User Actions
extension WatchTrackingViewModel {
    
    func pauseOrResumeTapped() {
        if isPaused {
            sessionManager.resumeSession()
            WKInterfaceDevice.current().play(.click)
        } else {
            sessionManager.pauseSession()
            WKInterfaceDevice.current().play(.click)
        }
    }
    
    func addSegment() {
        sessionManager.addSegment()
        WKInterfaceDevice.current().play(.success)
    }
    
    func endSession() {
        sessionManager.endSession()
        WKInterfaceDevice.current().play(.success)
    }
}
