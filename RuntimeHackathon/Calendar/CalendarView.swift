import SwiftUI

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
                        selectedEvent = event
                        showingEventDetail = true
                    }
                case 1:
                    DayCalendarView(viewModel: viewModel) { event in
                        selectedEvent = event
                        showingEventDetail = true
                    }
                case 2:
                    WeekCalendarView(viewModel: viewModel) { event in
                        selectedEvent = event
                        showingEventDetail = true
                    }
                case 3:
                    MonthCalendarView(viewModel: viewModel) { event in
                        selectedEvent = event
                        showingEventDetail = true
                    }
                case 4:
                    YearCalendarView(viewModel: viewModel) { event in
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
                    EventDetailView(event: event, viewModel: viewModel)
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
