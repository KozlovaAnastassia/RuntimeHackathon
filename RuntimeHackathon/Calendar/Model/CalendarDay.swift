import Foundation

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let events: [CalendarEvent]
    let isCurrentMonth: Bool
    let isToday: Bool
    
    var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }
}
