import SwiftUI

struct CalendarDayView: View {
    let day: CalendarDay
    let onEventTap: (CalendarEvent) -> Void
    
    var body: some View {
        VStack(spacing: 2) {
            // Номер дня
            Text("\(day.dayNumber)")
                .font(.system(size: 16, weight: day.isToday ? .bold : .medium))
                .foregroundColor(dayColor)
                .frame(width: 32, height: 32)
                .background(day.isToday ? Color.blue.opacity(0.2) : Color.clear)
                .clipShape(Circle())
            
            // Индикаторы событий
            if !day.events.isEmpty {
                VStack(spacing: 1) {
                    ForEach(day.events.prefix(3)) { event in
                        EventIndicatorView(event: event)
                            .onTapGesture {
                                onEventTap(event)
                            }
                    }
                    
                    if day.events.count > 3 {
                        Text("+\(day.events.count - 3)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .frame(height: 80)
        .background(day.isCurrentMonth ? Color.clear : Color(.systemGray6).opacity(0.3))
        .overlay(
            Rectangle()
                .stroke(Color(.systemGray5), lineWidth: 0.5)
        )
    }
    
    private var dayColor: Color {
        if !day.isCurrentMonth {
            return .secondary
        } else if day.isToday {
            return .blue
        } else {
            return .primary
        }
    }
}

#Preview {
    CalendarDayView(
        day: CalendarDataMock.sampleDayWithEvents
    ) { _ in }
}
