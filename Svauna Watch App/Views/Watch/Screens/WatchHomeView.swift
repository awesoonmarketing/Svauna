//
//  WatchHomeView.swift
//  Svauna
//
//  Created by Rasoul Rasouli on 4/28/25.
//
// Views/Watch/Screens/WatchHomeView.swift

import SwiftUI

struct WatchHomeView: View {
    @StateObject private var viewModel = WatchHomeViewModel()
    @State private var navigateToTracking = false
    
    @State private var showingConfirmStopCurrentSession = false
    @State private var pendingNewSessionType: SessionType?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // App Logo/Title
//                    Image(systemName: "flame.circle.fill")
//                        .font(.system(size: 38))
//                        .foregroundStyle(
//                            LinearGradient(
//                                colors: [.orange, .red],
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            )
//                        )
//                        .padding(.top, 8)
                    
//                    Text("What are we tracking?")
//                        .font(.system(.headline, design: .rounded))
//                        .foregroundStyle(.white)
//                        .padding(.bottom, 10)
//                        .center
//
                    // Enhanced Resume Session Card (Only if available)
//                    if viewModel.recoveredSessionAvailable {
//                        ResumeSessionCard(
//                            sessionType: viewModel.currentSessionType,
//                            elapsedTime: viewModel.currentElapsedTime
//                        ) {
//                            viewModel.resumeRecoveredSession()
//                            navigateToTracking = true
//                        }
//                        .padding(.bottom, 4)
//                    }
                    
                    // Main Action Buttons
                    VStack(spacing: 14) {
                        
                        
                        
                        SessionButton(
                            title: "Sauna",
                            icon: "flame.fill",
                            colors: [.red.opacity(0.9), .orange.opacity(0.7)],
                            action: {
                                handleTap(for: .sauna)
                            }
                        )
                        
                        SessionButton(
                            title: "Plunge",
                            icon: "snowflake",
                            colors: [.blue.opacity(0.9), .cyan.opacity(0.7)],
                            action: {
                                handleTap(for: .coldPlunge)
                            }
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
//
//                    // Stats Summary (if any available)
//                    if viewModel.hasRecentSessions {
//                        HStack {
//                            Spacer()
//                            
//                            StatView(value: viewModel.weeklySessionCount, label: "Week")
//                            
//                            Divider()
//                                .frame(height: 24)
//                                .background(Color.white.opacity(0.2))
//                            
//                            StatView(value: viewModel.totalMinutesThisMonth, label: "Month")
//                            
//                            Spacer()
//                        }
//                        .padding(.vertical, 10)
//                        .padding(.horizontal, 6)
//                        .background(Color.black.opacity(0.1))
//                        .cornerRadius(12)
//                        .padding(.top, 8)
//                    }
                }
                .padding()
                .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity)
            .scrollIndicators(.hidden)
            .navigationBarHidden(true)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.1, green: 0.1, blue: 0.12), Color(red: 0.15, green: 0.15, blue: 0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            )
            .onAppear {
                viewModel.onAppear()
            }
            .navigationDestination(isPresented: $navigateToTracking) {
                WatchTrackingView()
            }
            .confirmationDialog("You have an active session. End it and start a new one?", isPresented: $showingConfirmStopCurrentSession) {
                Button("End Current Session") {
                    if let newType = pendingNewSessionType {
                        viewModel.endCurrentSession()
                        viewModel.startSession(ofType: newType)
                        navigateToTracking = true
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
    
    // MARK: - Handle Tap Based on Session State
    
    private func handleTap(for type: SessionType) {
        switch viewModel.handleSessionTap(for: type) {
        case .startNew(let sessionType):
            viewModel.startSession(ofType: sessionType)
            navigateToTracking = true
            
        case .resumeExisting:
            navigateToTracking = true
            
        case .confirmSwitch(let newType):
            pendingNewSessionType = newType
            showingConfirmStopCurrentSession = true
        }
    }
    
    private func sessionTitle(_ title: String) -> String {
        if viewModel.recoveredSessionAvailable {
            return viewModel.currentSessionType.rawValue.lowercased() == title.lowercased() ? "Resume" : title
        } else {
            return title
        }
    }

}

// MARK: - Resume Session Card

struct ResumeSessionCard: View {
    let sessionType: SessionType
    let elapsedTime: TimeInterval
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                // Header with icon and "Resume" text
                HStack {
                    Image(systemName: sessionType == .sauna ? "flame.fill" : "snowflake")
                        .font(.system(size: 14))
                        .foregroundStyle(sessionType == .sauna ? Color.orange : Color.blue)
                    
                    Text("Resume")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    // Elapsed time with clock icon
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.7))
                        
                        Text(formatTime(elapsedTime))
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                
                // Session type large text
                Text(sessionType == .sauna ? "Sauna" : "Cold Plunge")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.top, 2)
                
                // Progress bar
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 2)
                        .frame(height: 4)
                        .foregroundStyle(Color.white.opacity(0.2))
                    
                    // Foreground
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: 120, height: 4)
                        .foregroundStyle(
                            sessionType == .sauna ? Color.orange : Color.blue
                        )
                }
                .padding(.top, 6)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        sessionType == .sauna ?
                            LinearGradient(
                                colors: [Color.red.opacity(0.4), Color.orange.opacity(0.25)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.blue.opacity(0.4), Color.cyan.opacity(0.25)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                sessionType == .sauna ?
                                    Color.red.opacity(0.3) : Color.blue.opacity(0.3),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    

    
}

// MARK: - Session Button Component

struct SessionButton: View {
    let title: String
    let icon: String
    let colors: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .frame(width: 32)
                
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Stats View Component

struct StatView: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            
            Text(label)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(width: 60)
    }
}




