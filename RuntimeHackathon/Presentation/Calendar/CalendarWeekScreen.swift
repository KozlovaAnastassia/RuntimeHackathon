import SwiftUI

struct CalendarWeekScreen: View {
    let viewModel: CalendarViewModel
    let onEventTap: (CalendarEvent) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок с навигацией
            weekHeader
            
            // Заголовок таблицы с днями недели (зафиксированный)
            weekTableHeader
            
            // Таблица недели (прокручиваемая)
            weekTableContent
            
            Spacer()
        }
    }
    
    private var weekHeader: some View {
        HStack {
            Button(action: viewModel.previousWeek) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text(viewModel.selectedWeekString())
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: viewModel.nextWeek) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
    
    private var weekTableHeader: some View {
        HStack(spacing: 0) {
            // Ячейка для времени
            Rectangle()
                .fill(Color(.systemGray6))
                .frame(width: 60, height: 60)
                .overlay(
                    Text("Время")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                )
            
            // Заголовки дней недели
            ForEach(viewModel.weekDays) { day in
                Text(weekdaySymbol(for: day.date))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(day.isToday ? .blue : .secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color(.systemGray6))
                    .overlay(
                        Rectangle()
                            .stroke(Color(.systemGray5), lineWidth: 0.5)
                    )
            }
        }
        .frame(height: 60)
    }
    
    private var weekTableContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Строки с часами
                ForEach(0..<24) { hour in
                    WeekHourRowView(
                        hour: hour,
                        weekDays: viewModel.weekDays,
                        onEventTap: onEventTap
                    )
                }
            }
        }
    }
    
    private func weekdaySymbol(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.shortWeekdaySymbols[Calendar.current.component(.weekday, from: date) - 1]
    }
}

struct WeekHourRowView: View {
    let hour: Int
    let weekDays: [CalendarDay]
    let onEventTap: (CalendarEvent) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Ячейка времени
            Rectangle()
                .fill(Color(.systemBackground))
                .frame(width: 60)
                .overlay(
                    VStack {
                        Text(formatHour(hour))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 8)
                        
                        if hour < 23 {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .frame(width: 1)
                                .frame(maxHeight: .infinity)
                                .padding(.trailing, 8)
                        }
                    }
                )
                .overlay(
                    Rectangle()
                        .stroke(Color(.systemGray5), lineWidth: 0.5)
                )
            
            // Ячейки для каждого дня недели
            ForEach(weekDays) { day in
                VStack(spacing: 2) {
                    ForEach(eventsForHourAndDay(hour: hour, day: day)) { event in
                        WeekEventView(event: event)
                            .onTapGesture {
                                onEventTap(event)
                            }
                    }
                    
                    if eventsForHourAndDay(hour: hour, day: day).isEmpty && hour < 23 {
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .frame(height: 1)
                            .padding(.horizontal, 4)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 2)
                .background(Color(.systemBackground))
                .overlay(
                    Rectangle()
                        .stroke(Color(.systemGray5), lineWidth: 0.5)
                )
            }
        }
        .frame(height: 60)
    }
    
    private func formatHour(_ hour: Int) -> String {
        return String(format: "%02d:00", hour)
    }
    
    private func eventsForHourAndDay(hour: Int, day: CalendarDay) -> [CalendarEvent] {
        let calendar = Calendar.current
        return day.events.filter { event in
            let eventHour = calendar.component(.hour, from: event.date)
            return eventHour == hour
        }
    }
}

struct WeekEventView: View {
    let event: CalendarEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(event.title)
                .font(.caption2)
                .fontWeight(.medium)
                .lineLimit(1)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(event.color.opacity(0.1))
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(event.color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    CalendarWeekScreen(
        viewModel: CalendarViewModel(),
        onEventTap: { _ in }
    )
    .withDataLayer()
}
