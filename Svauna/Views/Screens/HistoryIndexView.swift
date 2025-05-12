//
//  HistoryIndexView.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 2025-04-29.
//

import SwiftUI

struct HistoryIndexView: View {
    @ObservedObject var viewModel: HistoryIndexViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if viewModel.sessions.isEmpty {
                    emptyState
                } else {
                    sessionsList
                }
            }
            .padding(.horizontal)
            .animation(.easeInOut, value: viewModel.sessions.count)
        }
        .navigationTitle("Sessions")
        .background(Color.black)
    }

    // MARK: - View Components

    private var sessionsList: some View {
        ForEach(viewModel.sessions) { session in
            NavigationLink(destination: IndividualHistoryView(session: session)) {
                sessionCard(for: session)
            }
            .buttonStyle(PlainButtonStyle())
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "calendar.badge.exclamationmark")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(Color.Svauna.tertiaryText)
                .padding()
                .background(
                    Circle()
                        .fill(Color.Svauna.secondaryBackground)
                )

            Text("No sessions recorded")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(Color.Svauna.primaryText)

            Text("Your completed sauna and cold plunge\nsessions will appear here")
                .font(.subheadline)
                .foregroundColor(Color.Svauna.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding(.top, 20)
    }

    private func sessionCard(for session: Session) -> some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(session.type == .sauna ? Color.Svauna.warmAccent.opacity(0.2) : Color.Svauna.coolAccent.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: session.type == .sauna ? "flame.fill" : "snowflake")
                    .font(.title2)
                    .foregroundColor(session.type == .sauna ? Color.Svauna.warmAccent : Color.Svauna.coolAccent)
            }

            // Info
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
                        sessionMetric(icon: "heart.fill", value: "\(Int(avgHR)) bpm")
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

    // MARK: - Helpers

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        }
    }
    
    private func KCalorieFormatter(_ calories: Float) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: calories)) ?? String(format: "%.2f", calories)
    }
}
