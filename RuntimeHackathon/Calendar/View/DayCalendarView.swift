import SwiftUI

struct DayCalendarView: View {
    let viewModel: CalendarViewModel
    let onEventTap: (CalendarEvent) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок с навигацией
            dayHeader
            
            // Временные слоты
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(0..<24) { hour in
                        HourSlotView(
                            hour: hour,
                            events: eventsForHour(hour),
                            onEventTap: onEventTap
                        )
                    }
                }
            }
        }
    }
    
    private var dayHeader: some View {
        HStack {
            Button(action: viewModel.previousDay) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text(viewModel.selectedDayString())
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: viewModel.nextDay) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
    
    private func eventsForHour(_ hour: Int) -> [CalendarEvent] {
        let calendar = Calendar.current
        return viewModel.events.filter { event in
            let eventHour = calendar.component(.hour, from: event.date)
            return eventHour == hour
        }
    }
}

struct HourSlotView: View {
    let hour: Int
    let events: [CalendarEvent]
    let onEventTap: (CalendarEvent) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Время
            VStack {
                Text(formatHour(hour))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .trailing)
                
                if hour < 23 {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                }
            }
            
            // События
            VStack(spacing: 2) {
                ForEach(events) { event in
                    DayEventView(event: event)
                        .onTapGesture {
                            onEventTap(event)
                        }
                }
                
                if events.isEmpty && hour < 23 {
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .frame(height: 1)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 60)
        .background(Color(.systemBackground))
    }
    
    private func formatHour(_ hour: Int) -> String {
        return String(format: "%02d:00", hour)
    }
}

struct DayEventView: View {
    let event: CalendarEvent
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(event.location)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(event.color.opacity(0.1))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(event.color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    DayCalendarView(
        viewModel: CalendarViewModel(),
        onEventTap: { _ in }
    )
}
