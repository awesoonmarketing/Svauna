//
//  ChartDataPoint.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 2025-04-29.
//

import Foundation

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let value: Double
}
