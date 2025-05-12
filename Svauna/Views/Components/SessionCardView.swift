//
//  SessionCardView.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 5/1/25.
//

import SwiftUI

struct SessionCardView: View {
    let session: Session

    var body: some View {
        NavigationLink(destination: IndividualHistoryView(session: session)) {
            HStack(spacing: 16) {
                ZStack {
                    
                    Circle()
                        .fill(session.type == .sauna ? Color.Svauna.warmAccent.opacity(0.2) : Color.Svauna.coolAccent.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: session.type == .sauna ? "flame.fill" : "snowflake")
                        .font(.title2)
                        .foregroundColor(session.type == .sauna ? Color.Svauna.warmAccent : Color.Svauna.coolAccent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(session.type.rawValue)
                            .font(.headline)
                            .foregroundColor(Color.Svauna.primaryText)

                        Spacer()

                        Text(formatTime(session.startDate))
                            .font(.subheadline)
                            .foregroundColor(Color.Svauna.secondaryText)
                    }

                    HStack(spacing: 12) {
                        if let duration = session.totalDuration {
                            sessionMetric(icon: "clock", value: formatDuration(duration))
                        }

                        Rectangle()
                            .fill(Color.Svauna.divider)
                            .frame(width: 1, height: 16)

                        if let avgHR = session.averageHeartRate {
                            sessionMetric(icon: "heart.fill", value: "\(Int(avgHR))")
                        }

                        Rectangle()
                            .fill(Color.Svauna.divider)
                            .frame(width: 1, height: 16)

                        sessionMetric(icon: "flame.fill", value: "\(KCalorieFormatter(Float(session.totalActiveCalories))) kcal")
                    }
                    .padding(.top, 2)
                }

                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundColor(Color.Svauna.tertiaryText)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(Color.Svauna.panelBackground)
            .cornerRadius(16)
            .shadow(color: Color.Svauna.shadow.opacity(0.08), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private func sessionMetric(icon: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.footnote)
                .foregroundColor(Color.Svauna.secondaryText)

            Text(value)
                .font(.subheadline)
                .foregroundColor(Color.Svauna.primaryText)
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    private func KCalorieFormatter(_ calories: Float) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: calories)) ?? String(format: "%.2f", calories)
    }
}
