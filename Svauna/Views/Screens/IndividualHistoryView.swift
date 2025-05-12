//  IndividualHistoryView.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 2025-04-29.
//

import SwiftUI
import Charts

struct IndividualHistoryView: View {
    let session: Session
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            backgroundGradient()
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    // Header
                    VStack(spacing: 4) {
                        HStack {
                            Image(systemName: session.type == .sauna ? "flame.fill" : "snowflake")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(session.type == .sauna ? Color.Svauna.warmAccent : Color.Svauna.coolAccent)

                            Text("\(session.type.rawValue) Session")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(Color.Svauna.primaryText)
                        }

                        Text(formattedDate(session.startDate))
                            .font(.subheadline)
                            .foregroundColor(Color.Svauna.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)

                    // Metrics
                    HStack(spacing: 16) {
                        if let duration = session.totalDuration {
                            MetricCard(icon: "timer", value: formatDuration(duration), label: "Duration", iconColor: Color.Svauna.secondaryText)
                        }

                        MetricCard(icon: "flame.fill", value: "\(KCalorieFormatter(Float(session.totalActiveCalories)))", label: "kcal", iconColor: Color.Svauna.caloriesIcon)

                        if let avgHR = session.averageHeartRate {
                            MetricCard(icon: "heart.fill", value: "\(Int(avgHR))", label: "bpm avg", iconColor: Color.Svauna.heartRateIcon)
                        }
                    }
                    .padding(.vertical, 10)

                    // Tab Picker
                    Picker("Data View", selection: $selectedTab) {
                        Text("Heart Rate").tag(0)
                        Text("Calories").tag(1)
                        Text("Segments").tag(2)
                        Text("Blood O₂").tag(3)
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 8)
                    .background(Color.Svauna.panelBackground)
                    .cornerRadius(10)

                    // Tab Content
                    Group {
                        switch selectedTab {
                        case 0:
                            if !session.heartRateData.isEmpty {
                                chartView(title: "Heart Rate", data: session.heartRateData, valueKey: \.bpmDouble, unit: "bpm", color: Color.Svauna.heartRateIcon)
                            } else {
                                noDataView(message: "No heart rate data available")
                            }

                        case 1:
                            if !session.caloriesData.isEmpty {
                                chartView(title: "Active Calories", data: session.caloriesData, valueKey: \.activeCalories, unit: "kcal", color: Color.Svauna.caloriesIcon)
                            } else {
                                noDataView(message: "No calorie data available")
                            }

                        case 2:
                            if session.segments.count > 1 {
                                segmentsView(segments: session.segments)
                            } else {
                                noDataView(message: "No segments recorded")
                            }

                        case 3:
                            if !session.bloodOxygenData.isEmpty {
                                chartView(title: "Blood Oxygen", data: session.bloodOxygenData, valueKey: \.percentage, unit: "%", color: .blue)
                            } else {
                                noDataView(message: "No blood oxygen data available")
                            }

                        default:
                            EmptyView()
                        }
                    }
                    .padding(.top, 4)

                    // Done Button
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Done")
                        }
                        .font(.headline)
                        .foregroundColor(Color.Svauna.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.Svauna.secondaryBackground.opacity(0.7))
                        .cornerRadius(16)
                        .shadow(color: Color.Svauna.shadow, radius: 3, x: 0, y: 2)
                    }
                    .padding(.top, 12)
                }
                .padding()
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .principal) { EmptyView() }
        }
    }

    // MARK: - Updated Chart with LineMark

    private func chartView<T: Timestamped>(
        title: String,
        data: [T],
        valueKey: KeyPath<T, Double>,
        unit: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color.Svauna.primaryText)

            let sortedData = data.sorted(by: { $0.timestamp < $1.timestamp })
            let sessionStart = sortedData.first?.timestamp ?? Date()

            Chart {
                ForEach(sortedData) { item in
                    let relativeTime = item.timestamp.timeIntervalSince(sessionStart)

                    LineMark(
                        x: .value("Time", relativeTime),
                        y: .value(unit, item[keyPath: valueKey])
                    )
                    .foregroundStyle(color)
                    .interpolationMethod(.catmullRom)
                }
            }

            .frame(height: 220)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    if let seconds = value.as(Double.self) {
                        AxisGridLine()
                        AxisValueLabel {
                            Text("\(Int(seconds))s")
                                .foregroundStyle(Color.Svauna.secondaryText)
                        }
                    }
                }
            }
            .padding(10)
            .background(Color.Svauna.panelBackground)
            .cornerRadius(16)
        }
    }

    // MARK: - Other Views (unchanged)...

    private func segmentsView(segments: [SessionSegment]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Segments")
                .font(.headline)
                .foregroundColor(Color.Svauna.primaryText)
                .padding(.bottom, 4)

            ForEach(segments) { segment in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(session.type == .sauna ? Color.Svauna.warmAccent.opacity(0.2) : Color.Svauna.coolAccent.opacity(0.2))
                            .frame(width: 36, height: 36)

                        Text("\(segments.firstIndex(where: { $0.id == segment.id })! + 1)")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(session.type == .sauna ? Color.Svauna.warmAccent : Color.Svauna.coolAccent)
                    }

                    VStack(alignment: .leading) {
                        Text(formatTimeOnly(segment.startTime))
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(Color.Svauna.primaryText)

                        if let end = segment.endTime {
                            HStack(spacing: 4) {
                                Text("→")
                                Text(formatTimeOnly(end))
                                if let duration = segment.duration {
                                    Text("(\(formatSegmentDuration(duration)))")
                                        .foregroundColor(Color.Svauna.tertiaryText)
                                }
                            }
                            .font(.subheadline)
                            .foregroundColor(Color.Svauna.secondaryText)
                        } else {
                            Text("Ongoing...")
                                .font(.subheadline)
                                .italic()
                                .foregroundColor(Color.Svauna.warmAccent)
                        }
                    }

                    Spacer()
                }
                .padding(12)
                .background(Color.Svauna.panelBackground)
                .cornerRadius(12)
            }
        }
    }

    private func noDataView(message: String) -> some View {
        VStack {
            Image(systemName: "chart.xyaxis.line")
                .font(.largeTitle)
                .foregroundColor(Color.Svauna.tertiaryText)
                .padding()

            Text(message)
                .foregroundColor(Color.Svauna.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(Color.Svauna.panelBackground)
        .cornerRadius(16)
    }

    // MARK: - Helpers

    private func backgroundGradient() -> LinearGradient {
        switch session.type {
        case .sauna: return LinearGradient.Svauna.saunaBackground()
        case .coldPlunge: return LinearGradient.Svauna.coldPlungeBackground()
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s"
    }

    private func formatSegmentDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatTimeOnly(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }

    
    private func KCalorieFormatter(_ calories: Float) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: calories)) ?? String(format: "%.2f", calories)
    }
}

// MARK: - Metric Card

struct MetricCard: View {
    let icon: String
    let value: String
    let label: String
    let iconColor: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(height: 24)

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color.Svauna.primaryText)

            Text(label)
                .font(.caption)
                .foregroundColor(Color.Svauna.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.Svauna.panelBackground)
        .cornerRadius(12)
    }
}
