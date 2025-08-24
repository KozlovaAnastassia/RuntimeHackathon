import SwiftUI

struct EventsListView: View {
    let viewModel: CalendarViewModel
    let onEventTap: (CalendarEvent) -> Void
    
    var body: some View {
        List {
            ForEach(groupedEvents.keys.sorted(), id: \.self) { date in
                Section(header: Text(formatDate(date))) {
                    ForEach(groupedEvents[date] ?? [], id: \.id) { event in
                        EventRowView(event: event)
                            .onTapGesture {
                                onEventTap(event)
                            }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private var groupedEvents: [Date: [CalendarEvent]] {
        let calendar = Calendar.current
        return Dictionary(grouping: viewModel.events.sorted { $0.date < $1.date }) { event in
            calendar.startOfDay(for: event.date)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

struct EventRowView: View {
    let event: CalendarEvent
    
    var body: some View {
        HStack(spacing: 12) {
            // Цветной индикатор
            Circle()
                .fill(event.color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(event.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(formatTime(event.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

#Preview {
    EventsListView(
        viewModel: CalendarViewModel(),
        onEventTap: { _ in }
    )
}
