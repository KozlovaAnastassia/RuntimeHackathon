import Foundation

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let events: [CalendarEvent]
    let isCurrentMonth: Bool
    let isToday: Bool
    let isCurrentWeek: Bool
    
    var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }
    
    init(date: Date, events: [CalendarEvent], isCurrentMonth: Bool, isToday: Bool, isCurrentWeek: Bool = false) {
        self.date = date
        self.events = events
        self.isCurrentMonth = isCurrentMonth
        self.isToday = isToday
        self.isCurrentWeek = isCurrentWeek
    }
}
