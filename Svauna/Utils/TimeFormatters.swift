//
//  TimeFormatters.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 2025-04-29.
//

import Foundation

final class TimeFormatters {
    static let shared = TimeFormatters()
    private let formatter: DateComponentsFormatter
    
    private init() {
        formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
    }
    
    func format(duration: TimeInterval) -> String {
        return formatter.string(from: duration) ?? "N/A"
    }
}
