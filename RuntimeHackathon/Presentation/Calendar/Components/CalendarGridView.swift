import SwiftUI

struct CalendarGridView: View {
    let calendarDays: [CalendarDay]
    let onEventTap: (CalendarEvent) -> Void
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
            ForEach(calendarDays) { day in
                CalendarDayView(day: day) { event in
                    onEventTap(event)
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    CalendarGridView(calendarDays: CalendarDataMock.sampleCalendarDays) { _ in }
}
