import SwiftUI



struct CalendarScreen: View {
    @StateObject private var viewModel: CalendarViewModel
    @EnvironmentObject var clubEventsService: ClubEventsService
    @State private var showingEventDetail = false
    @State private var selectedEvent: CalendarEvent?
    @State private var selectedTab = 0
    
    // Инициализатор по умолчанию с событиями клубов
    init() {
        self._viewModel = StateObject(wrappedValue: CalendarViewModel(withClubEvents: true))
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
                
                // Обновляем события из сервиса
                .onReceive(clubEventsService.$allClubEvents) { updatedEvents in
                    print("DEBUG: CalendarView получил обновление событий: \(updatedEvents.count) событий")
                    Task {
                        await viewModel.updateEvents(from: clubEventsService.allClubEvents)
                    }
                }
                .onAppear {
                    // Загружаем события при появлении экрана
                    Task {
                        await clubEventsService.loadAllEvents()
                        await viewModel.updateEvents(from: clubEventsService.allClubEvents)
                    }
                }
                
                // Контент в зависимости от выбранного таба
                switch selectedTab {
                case 0:
                    CalendarEventsListScreen(viewModel: viewModel) { event in
                        print("DEBUG: Нажато событие в списке: \(event.title)")
                        selectedEvent = event
                        showingEventDetail = true
                    }
                case 1:
                    CalendarDayScreen(viewModel: viewModel) { event in
                        print("DEBUG: Нажато событие в дне: \(event.title)")
                        selectedEvent = event
                        showingEventDetail = true
                    }
                case 2:
                    CalendarWeekScreen(viewModel: viewModel) { event in
                        print("DEBUG: Нажато событие в неделе: \(event.title)")
                        selectedEvent = event
                        showingEventDetail = true
                    }
                case 3:
                    CalendarMonthScreen(viewModel: viewModel) { event in
                        print("DEBUG: Нажато событие в месяце: \(event.title)")
                        selectedEvent = event
                        showingEventDetail = true
                    }
                case 4:
                    CalendarYearScreen(viewModel: viewModel) { event in
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
                    CalendarEventScreen(event: event)
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
    CalendarScreen()
        .withDataLayer()
}
