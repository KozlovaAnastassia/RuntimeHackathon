import SwiftUI

struct CalendarMonthScreen: View {
    let viewModel: CalendarViewModel
    let onEventTap: (CalendarEvent) -> Void
    
    var body: some View {
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
                onEventTap(event)
            }
            
            Spacer()
        }
    }
}

#Preview {
    CalendarMonthScreen(
        viewModel: CalendarViewModel(),
        onEventTap: { _ in }
    )
}
