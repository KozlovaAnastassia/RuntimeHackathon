import SwiftUI

// Простая версия EventDetailScreen для тестирования
struct SimpleEventDetailScreen: View {
    let event: CalendarEvent
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Цветовая полоса
                    Rectangle()
                        .fill(event.color)
                        .frame(height: 4)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Заголовок
                        Text(event.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        // Описание
                        Text(event.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        // Местоположение
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.red)
                            Text("Место: \(event.location)")
                        }
                        
                        // Дата и время
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            Text("Дата: \(formatDate(event.date))")
                        }
                        
                        // Продолжительность
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.green)
                            Text("Продолжительность: \(formatDuration(event.durationInMinutes))")
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .navigationTitle("Детали мероприятия")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Закрыть") {
                    dismiss()
                },
                trailing: Button("Записаться") {
                    // Здесь будет логика записи
                }
                .foregroundColor(.blue)
            )
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return "\(hours) ч \(remainingMinutes) мин"
        } else {
            return "\(remainingMinutes) мин"
        }
    }
}

struct CalendarView: View {
    @StateObject private var viewModel: CalendarViewModel
    @State private var showingEventDetail = false
    @State private var selectedEvent: CalendarEvent?
    @State private var selectedTab = 0
    
    // Инициализатор по умолчанию с моковыми данными
    init() {
        self._viewModel = StateObject(wrappedValue: CalendarViewModel())
    }
    
    // Инициализатор с внешними событиями ClubEvent
    init(clubEvents: [ClubEvent]) {
        self._viewModel = StateObject(wrappedValue: CalendarViewModel(clubEvents: clubEvents))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Табы для переключения представлений
                calendarTabs
                
                // Контент в зависимости от выбранного таба
                switch selectedTab {
                case 0:
                    EventsListView(viewModel: viewModel) { event in
                        print("DEBUG: Нажато событие в списке: \(event.title)")
                        selectedEvent = event
                        showingEventDetail = true
                    }
                case 1:
                    DayCalendarView(viewModel: viewModel) { event in
                        print("DEBUG: Нажато событие в дне: \(event.title)")
                        selectedEvent = event
                        showingEventDetail = true
                    }
                case 2:
                    WeekCalendarView(viewModel: viewModel) { event in
                        print("DEBUG: Нажато событие в неделе: \(event.title)")
                        selectedEvent = event
                        showingEventDetail = true
                    }
                case 3:
                    MonthCalendarView(viewModel: viewModel) { event in
                        print("DEBUG: Нажато событие в месяце: \(event.title)")
                        selectedEvent = event
                        showingEventDetail = true
                    }
                case 4:
                    YearCalendarView(viewModel: viewModel) { event in
                        print("DEBUG: Нажато событие в годе: \(event.title)")
                        selectedEvent = event
                        showingEventDetail = true
                    }
                default:
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingEventDetail) {
                if let event = selectedEvent {
                    SimpleEventDetailScreen(event: event)
                } else {
                    Text("Ошибка: событие не найдено")
                        .padding()
                }
            }
        }
    }
    
    // Табы для переключения представлений
    private var calendarTabs: some View {
        HStack(spacing: 0) {
            ForEach(0..<5) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    VStack(spacing: 4) {
                        Text(tabTitle(for: index))
                            .font(.caption)
                            .fontWeight(selectedTab == index ? .semibold : .regular)
                            .foregroundColor(selectedTab == index ? .blue : .secondary)
                        
                        Rectangle()
                            .fill(selectedTab == index ? Color.blue : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .stroke(Color(.systemGray5), lineWidth: 0.5)
        )
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Список"
        case 1: return "День"
        case 2: return "Неделя"
        case 3: return "Месяц"
        case 4: return "Год"
        default: return ""
        }
    }
}

#Preview {
    CalendarView()
}
