import Foundation
import SwiftUI

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var events: [CalendarEvent] = []
    @Published var calendarDays: [CalendarDay] = []
    
    private let calendar = Calendar.current
    
    init() {
        generateSampleEvents()
        updateCalendarDays()
    }
    
    // Генерация тестовых событий
    private func generateSampleEvents() {
        events = CalendarMock.generateSampleEvents()
    }
    
    // Обновление дней календаря
    func updateCalendarDays() {
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)?.start ?? startOfMonth
        
        var days: [CalendarDay] = []
        let today = Date()
        
        // Генерируем 42 дня (6 недель по 7 дней)
        for dayOffset in 0..<42 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) {
                let dayEvents = eventsForDate(date)
                let isCurrentMonth = calendar.isDate(date, equalTo: selectedDate, toGranularity: .month)
                let isToday = calendar.isDateInToday(date)
                
                let day = CalendarDay(
                    date: date,
                    events: dayEvents,
                    isCurrentMonth: isCurrentMonth,
                    isToday: isToday
                )
                days.append(day)
            }
        }
        
        calendarDays = days
    }
    
    // Получение событий для конкретной даты
    func eventsForDate(_ date: Date) -> [CalendarEvent] {
        return events.filter { event in
            calendar.isDate(event.startTime, inSameDayAs: date)
        }
    }
    
    // Переход к предыдущему месяцу
    func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
            updateCalendarDays()
        }
    }
    
    // Переход к следующему месяцу
    func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
            updateCalendarDays()
        }
    }
    
    // Форматирование названия месяца
    func monthYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: selectedDate).capitalized
    }
    
    // Форматирование названий дней недели
    func weekdaySymbols() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.shortWeekdaySymbols
    }
    
    // Добавление нового события
    func addEvent(_ event: CalendarEvent) {
        events.append(event)
        updateCalendarDays()
    }
    
    // Удаление события
    func removeEvent(_ event: CalendarEvent) {
        events.removeAll { $0.id == event.id }
        updateCalendarDays()
    }
    
    // Методы для загрузки разных типов моковых данных
    func loadWeekendEvents() {
        events = CalendarMock.generateWeekendEvents()
        updateCalendarDays()
    }
    
    func loadWorkdayEvents() {
        events = CalendarMock.generateWorkdayEvents()
        updateCalendarDays()
    }
    
    func loadEmptyEvents() {
        events = CalendarMock.generateEmptyEvents()
        updateCalendarDays()
    }
}
