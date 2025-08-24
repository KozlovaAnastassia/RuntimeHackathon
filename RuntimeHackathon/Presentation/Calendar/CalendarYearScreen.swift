import SwiftUI

struct CalendarYearScreen: View {
    let viewModel: CalendarViewModel
    let onEventTap: (CalendarEvent) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок с навигацией
            yearHeader
            
            // Сетка месяцев
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(1...12, id: \.self) { month in
                    MonthMiniView(
                        month: month,
                        year: viewModel.selectedYear,
                        events: eventsForMonth(month),
                        onEventTap: onEventTap
                    )
                }
            }
            .padding(8)
        }
    }
    
    private var yearHeader: some View {
        HStack {
            Button(action: viewModel.previousYear) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text("\(viewModel.selectedYear)")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: viewModel.nextYear) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    private func eventsForMonth(_ month: Int) -> [CalendarEvent] {
        let calendar = Calendar.current
        return viewModel.events.filter { event in
            let eventMonth = calendar.component(.month, from: event.date)
            let eventYear = calendar.component(.year, from: event.date)
            return eventMonth == month && eventYear == viewModel.selectedYear
        }
    }
}

struct MonthMiniView: View {
    let month: Int
    let year: Int
    let events: [CalendarEvent]
    let onEventTap: (CalendarEvent) -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            // Название месяца
            Text(monthName)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // Мини-календарь
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 1) {
                // Дни месяца
                ForEach(monthDays, id: \.self) { day in
                    if day > 0 {
                        DayMiniView(
                            day: day,
                            events: eventsForDay(day),
                            isToday: isToday(day),
                            onEventTap: onEventTap
                        )
                    } else {
                        Color.clear
                            .frame(height: 16)
                    }
                }
            }
            
            Spacer()
        }
        .padding(4)
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(6)
    }
    
    private var monthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.monthSymbols[month - 1]
    }
    
    private var monthDays: [Int] {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: year, month: month, day: 1)
        guard let firstDay = calendar.date(from: dateComponents) else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDay)?.count ?? 0
        
        var days: [Int] = []
        
        // Пустые дни в начале
        for _ in 1..<firstWeekday {
            days.append(0)
        }
        
        // Дни месяца
        for day in 1...daysInMonth {
            days.append(day)
        }
        
        return days
    }
    
    private func eventsForDay(_ day: Int) -> [CalendarEvent] {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: year, month: month, day: day)
        guard let date = calendar.date(from: dateComponents) else { return [] }
        
        return events.filter { event in
            calendar.isDate(event.date, inSameDayAs: date)
        }
    }
    
    private func isToday(_ day: Int) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        
        return todayComponents.year == year && 
               todayComponents.month == month && 
               todayComponents.day == day
    }
}

struct DayMiniView: View {
    let day: Int
    let events: [CalendarEvent]
    let isToday: Bool
    let onEventTap: (CalendarEvent) -> Void
    
    var body: some View {
        VStack(spacing: 1) {
            Text("\(day)")
                .font(.caption2)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(isToday ? .white : .primary)
                .frame(width: 16, height: 16)
                .background(isToday ? Color.blue : Color.clear)
                .clipShape(Circle())
            
            if !events.isEmpty {
                HStack(spacing: 1) {
                    ForEach(events.prefix(2)) { event in
                        Circle()
                            .fill(event.color)
                            .frame(width: 3, height: 3)
                    }
                }
            }
        }
        .frame(height: 16)
        .onTapGesture {
            if let firstEvent = events.first {
                onEventTap(firstEvent)
            }
        }
    }
}

#Preview {
    CalendarYearScreen(
        viewModel: CalendarViewModel(),
        onEventTap: { _ in }
    )
}
