//
//  CalendarDayView.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 2025-04-29.
//
import SwiftUI

struct CalendarDayView: View {
    let date: Date
    let isToday: Bool
    let isSelected: Bool
    let hasSessions: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Selection background
                if isSelected {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 36, height: 36)
                } else if isToday {
                    Circle()
                        .stroke(Color.orange, lineWidth: 2)
                        .frame(width: 36, height: 36)
                }

                VStack(spacing: 4) {
                    Text(dayString(from: date))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(foregroundColor)
                    
                    if hasSessions {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 5, height: 5)
                    }
                }
                .frame(width: 36, height: 36)
            }
        }
        .buttonStyle(.plain)
    }

    private var foregroundColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .orange
        } else {
            return .primary
        }
    }

    private func dayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}
