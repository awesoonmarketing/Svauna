import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    



    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.Svauna.generalBackground()
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 24) {
                        
                        CalendarView(viewModel: viewModel.calendarViewModel)
                            .padding(.horizontal)

                        if viewModel.sessionsForSelectedDay.isEmpty {
                            Text("No sessions for this day")
                                .foregroundColor(.secondary)
                                .font(.callout)
                                .padding(.top, 8)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(viewModel.sessionsForSelectedDay) { session in
                                    SessionCardView(session: session)
                                }
                            }
                            .animation(.easeInOut, value: viewModel.sessionsForSelectedDay.count)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                    .navigationTitle("Welcome to Svauna!")
                }
            }
        }
        .task() {
            syncFromWatch()
        }
    }

    private func syncFromWatch() {
        WatchConnectivityService.shared.requestMissedSessionsFromWatch { sessions in
            print("✅ Received \(sessions.count) session(s) from Watch")
            viewModel.loadSessions()
        }
    }
}
