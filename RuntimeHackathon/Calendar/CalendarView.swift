import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel: CalendarViewModel
    @State private var showingEventDetail = false
    @State private var selectedEvent: CalendarEvent?
    
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
                // Заголовок с навигацией
                CalendarHeaderView(
                    monthYearString: viewModel.monthYearString(),
                    onPreviousMonth: viewModel.previousMonth,
                    onNextMonth: viewModel.nextMonth
                )
                
                // Дни недели
                WeekdayHeaderView(weekdaySymbols: viewModel.weekdaySymbols())
                
                // Сетка календаря
                CalendarGridView(
                    calendarDays: viewModel.calendarDays
                ) { event in
                    selectedEvent = event
                    showingEventDetail = true
                }
                
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
}

#Preview {
    CalendarView()
}
