
//
//  WatchTrackingView.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 4/28/25.
//

// Views/Watch/Screens/WatchTrackingView.swift

import SwiftUI

struct WatchTrackingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = WatchTrackingViewModel()
    @State private var sessionEnded = false
    @State private var showDetails = false
    @State private var segmentCount = 0
    
    var body: some View {
        ZStack {
            backgroundColor()
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 16) {
                    // Hero Timer
                    Text(formatTime(viewModel.elapsedTime))
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.vertical, 8)
                        .contentTransition(.numericText())
                        .animation(.smooth, value: viewModel.elapsedTime)
                    
                    // Metrics Section
                    // 🧠 In body > Metrics Section:
                    VStack(spacing: 12) {
                        MetricRow(
                            icon: "heart.fill",
                            value: isMetricLoaded(viewModel.heartRate) ? "\(viewModel.heartRate)" : nil,
                            unit: "bpm",
                            color: .red
                        )

                        MetricRow(
                            icon: "flame.fill",
                            value: isMetricLoaded(viewModel.totalActiveCalories) ? "\(Int(viewModel.totalActiveCalories))" : nil,
                            unit: "kcal",
                            color: .orange
                        )

                        MetricRow(
                            icon: "drop.fill",
                            value: isMetricLoaded(viewModel.bloodOxygen) ? "\(Int(viewModel.bloodOxygen ?? 0))" : nil,
                            unit: "% SpO₂",
                            color: .blue
                        )

                        SegmentCounter(count: segmentCount)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(Color.black.opacity(0.15))
                    .cornerRadius(16)
                    
                    Spacer(minLength: 10)
                    
                    // Control Buttons with SF Symbols
                    HStack(spacing: 12) {
                        // Segment Button
                        ActionButton(
                            action: {
                                viewModel.addSegment()
                                segmentCount += 1
                            },
                            icon: "flag.fill",
                            backgroundColor: Color.white.opacity(0.2)
                        )
                        
                        // Pause/Resume Button
                        ActionButton(
                            action: { viewModel.pauseOrResumeTapped() },
                            icon: viewModel.isPaused ? "play.fill" : "pause.fill",
                            backgroundColor: viewModel.isPaused ? Color.green : Color.yellow
                        )
                        
                        // End Button
                        ActionButton(
                            action: {
                                viewModel.endSession()
                                sessionEnded = true
                            },
                            icon: "xmark",
                            backgroundColor: Color.red.opacity(0.7)
                        )
                    }
                    .padding(.bottom, 8)
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            
            // Status Indicator
            if viewModel.isPaused {
                VStack {
                    Text("PAUSED")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                    
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.width < -20 {
                        // Swipe left to add segment
                        viewModel.addSegment()
                        segmentCount += 1
                        
                        // Haptic feedback
                        WKInterfaceDevice.current().play(.click)
                    }
                }
        )
        .onAppear {
            viewModel.onAppear()
        }
        .onChange(of: sessionEnded) {
            if sessionEnded {
                dismiss()
            }
        }
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func backgroundColor() -> LinearGradient {
        switch viewModel.sessionType {
        case .sauna:
            return LinearGradient(
                colors: [Color.red.opacity(0.8), Color.orange.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .coldPlunge:
            return LinearGradient(
                colors: [Color.blue.opacity(0.7), Color.indigo.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

// MARK: - Reusable Components
private struct MetricRow: View {
    let icon: String
    let value: String?
    let unit: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.headline)
                .frame(width: 26, alignment: .center)

            if let value = value {
                Text(value)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            } else {
                ShimmerView()
            }

            Text(unit)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.8))

            Spacer()
        }
    }
}


private struct SegmentCounter: View {
    let count: Int
    
    var body: some View {
        HStack {
            Image(systemName: "flag.fill")
                .foregroundColor(.white)
                .font(.headline)
                .frame(width: 26, alignment: .center)
            
            Text("\(count)")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("segments")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
        }
    }
}

private struct ActionButton: View {
    let action: () -> Void
    let icon: String
    let backgroundColor: Color
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}

private func isMetricLoaded<T>(_ metric: T?) -> Bool {
    if let intMetric = metric as? Int { return intMetric > 0 }
    if let doubleMetric = metric as? Double { return doubleMetric > 0 }
    return false
}

private struct ShimmerView: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [.white.opacity(0.3), .white.opacity(0.1), .white.opacity(0.3)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 50, height: 16)
            .opacity(0.5)
            .mask(
                Rectangle()
                    .fill(Color.white)
                    .rotationEffect(.degrees(30))
                    .offset(x: phase)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    phase = 150
                }
            }
    }
}


//#Preview {
//    WatchTrackingView()
//}
