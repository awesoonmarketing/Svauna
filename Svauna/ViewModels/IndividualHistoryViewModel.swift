//
//  IndividualHistoryViewModel.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 2025-04-29.
//

import SwiftUI

final class IndividualHistoryViewModel: ObservableObject {
    let session: Session
    private var calendar = Calendar.current

    // Processed Data
    @Published var heartRatePoints: [ChartDataPoint] = []
    @Published var caloriePoints: [ChartDataPoint] = []
    @Published var segmentMarkers: [Date] = []
    
    init(session: Session) {
        self.session = session
        prepareData()
    }
    
    private func prepareData() {
        prepareHeartRateData()
        prepareCalorieData()
        prepareSegmentMarkers()
    }
    
    private func prepareHeartRateData() {
        heartRatePoints = session.heartRateData.map { dataPoint in
            ChartDataPoint(timestamp: dataPoint.timestamp, value: Double(dataPoint.bpm))
        }
    }
    
    private func prepareCalorieData() {
        caloriePoints = session.caloriesData.map { dataPoint in
            ChartDataPoint(timestamp: dataPoint.timestamp, value: dataPoint.activeCalories)
        }
    }
    
    private func prepareSegmentMarkers() {
        segmentMarkers = session.segments.map { $0.startTime }
    }
    
    // MARK: - Session Summary Helpers
    
    var averageHeartRateText: String {
        if let avg = session.averageHeartRate {
            return "\(Int(avg)) bpm"
        } else {
            return "N/A"
        }
    }
    
    var totalCaloriesText: String {
        NumberFormatters.shared.formatCalories(session.totalActiveCalories)
    }
    
    var durationText: String {
        if let duration = session.totalDuration {
            return TimeFormatters.shared.format(duration: duration)
        } else {
            return "Ongoing"
        }
    }
    
    var sessionTypeText: String {
        session.type.rawValue
    }
}
