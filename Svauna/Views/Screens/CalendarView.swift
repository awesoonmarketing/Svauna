
import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel
    private let calendar = Calendar.current

    private var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: viewModel.displayedMonth)
    }

    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: viewModel.displayedMonth),
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: viewModel.displayedMonth)) else {
            return []
        }
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }

    private var startingWeekdayOffset: Int {
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: viewModel.displayedMonth)) else {
            return 0
        }
        return (calendar.component(.weekday, from: startOfMonth) - calendar.firstWeekday + 7) % 7
    }

    var body: some View {
        VStack(spacing: 16) {
            header
            weekdayHeaders
            calendarGrid
        }
        .padding()
        .background(
            ZStack {
                Color.clear
                    .background(.ultraThinMaterial)
                    .overlay(
                        LinearGradient(
                            colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .blur(radius: 10)
                    )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
        .animation(.spring(), value: viewModel.displayedMonth)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button(action: { viewModel.previousMonth() }) {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.plain)
            .padding(8)

            Spacer()

            Text(monthName)
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()

            Button(action: { viewModel.nextMonth() }) {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.plain)
            .padding(8)
        }
    }

    // MARK: - Weekdays Row

    private var weekdayHeaders: some View {
        let symbols = calendar.veryShortWeekdaySymbols
        return HStack(spacing: 0) {
            ForEach(symbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Days Grid

    private var calendarGrid: some View {
        let days = Array(repeating: Date?.none, count: startingWeekdayOffset) + daysInMonth.map { Optional($0) }

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
            ForEach(days, id: \.self) { date in
                if let date = date {
                    CalendarDayView(
                        date: date,
                        isToday: viewModel.isToday(date),
                        isSelected: viewModel.isSelected(date),
                        hasSessions: viewModel.hasSessions(on: date)
                    ) {
                        withAnimation {
                            viewModel.select(date: date)
                        }
                    }
                } else {
                    Color.clear.frame(height: 36)
                }
            }
        }
        .padding(.top, 4)
    }
}
