import Foundation
import SwiftUI

// Модель события календаря
struct CalendarEvent: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let startTime: Date
    let endTime: Date
    let color: Color
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var durationInMinutes: Int {
        Int(duration / 60)
    }
}

// Модель дня календаря
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
        let today = Date()
        let calendar = Calendar.current
        
        // Событие на 15 минут
        let shortEvent = CalendarEvent(
            title: "Короткая встреча",
            description: "Быстрая синхронизация",
            startTime: calendar.date(byAdding: .hour, value: 1, to: today) ?? today,
            endTime: calendar.date(byAdding: .minute, value: 15, to: calendar.date(byAdding: .hour, value: 1, to: today) ?? today) ?? today,
            color: .blue
        )
        
        // Событие на 2 часа
        let longEvent = CalendarEvent(
            title: "Длинная презентация",
            description: "Подробный обзор проекта",
            startTime: calendar.date(byAdding: .hour, value: 3, to: today) ?? today,
            endTime: calendar.date(byAdding: .hour, value: 5, to: today) ?? today,
            color: .green
        )
        
        // Событие на 4 часа
        let veryLongEvent = CalendarEvent(
            title: "Рабочий день",
            description: "Основная работа над проектом",
            startTime: calendar.date(byAdding: .hour, value: 9, to: today) ?? today,
            endTime: calendar.date(byAdding: .hour, value: 13, to: today) ?? today,
            color: .orange
        )
        
        events = [shortEvent, longEvent, veryLongEvent]
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
}
