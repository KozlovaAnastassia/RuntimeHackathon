import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var showingEventDetail = false
    @State private var selectedEvent: CalendarEvent?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Заголовок с навигацией
                calendarHeader
                
                // Дни недели
                weekdayHeader
                
                // Сетка календаря
                calendarGrid
                
                Spacer()
            }
            .navigationTitle("Календарь")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingEventDetail) {
                if let event = selectedEvent {
                    EventDetailView(event: event, viewModel: viewModel)
                }
            }
        }
    }
    
    // Заголовок календаря с кнопками навигации
    private var calendarHeader: some View {
        HStack {
            Button(action: viewModel.previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text(viewModel.monthYearString())
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: viewModel.nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
    
    // Заголовок дней недели
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.weekdaySymbols(), id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
        }
        .background(Color(.systemGray6))
    }
    
    // Сетка календаря
    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
            ForEach(viewModel.calendarDays) { day in
                CalendarDayView(day: day) { event in
                    selectedEvent = event
                    showingEventDetail = true
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

// Представление дня календаря
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
                        EventIndicator(event: event)
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

// Индикатор события
struct EventIndicator: View {
    let event: CalendarEvent
    
    var body: some View {
        HStack(spacing: 2) {
            Circle()
                .fill(event.color)
                .frame(width: 6, height: 6)
            
            Text(event.title)
                .font(.caption2)
                .lineLimit(1)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(event.color.opacity(0.1))
        .cornerRadius(4)
    }
}

// Детальное представление события
struct EventDetailView: View {
    let event: CalendarEvent
    let viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Цветовая полоса
                Rectangle()
                    .fill(event.color)
                    .frame(height: 4)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Заголовок
                    Text(event.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    // Описание
                    Text(event.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    // Время
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.blue)
                            Text("Время")
                                .fontWeight(.medium)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(timeString(from: event.startTime))
                            Text(timeString(from: event.endTime))
                        }
                        .font(.body)
                        .foregroundColor(.secondary)
                    }
                    
                    // Продолжительность
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(.green)
                            Text("Продолжительность")
                                .fontWeight(.medium)
                        }
                        
                        Text(durationString)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Кнопка удаления
                Button(action: {
                    viewModel.removeEvent(event)
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Удалить событие")
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Детали события")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Закрыть") {
                dismiss()
            })
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private var durationString: String {
        let hours = event.durationInMinutes / 60
        let minutes = event.durationInMinutes % 60
        
        if hours > 0 {
            return "\(hours) ч \(minutes) мин"
        } else {
            return "\(minutes) мин"
        }
    }
}

#Preview {
    CalendarView()
}
