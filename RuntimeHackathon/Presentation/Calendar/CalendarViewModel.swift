import Foundation
import SwiftUI

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var events: [CalendarEvent] = []
    @Published var calendarDays: [CalendarDay] = []
    @Published var weekDays: [CalendarDay] = []
    
    private let calendar = Calendar.current
    
    init() {
        generateSampleEvents()
        updateCalendarDays()
        updateWeekDays()
    }
    
    // Инициализатор с внешними событиями
    init(clubEvents: [ClubEvent]) {
        self.events = CalendarEvent.fromClubEvents(clubEvents)
        updateCalendarDays()
        updateWeekDays()
    }
    
    // Инициализатор с событиями из сервиса
    convenience init(withClubEvents: Bool = false) {
        if withClubEvents {
            let clubEvents = ClubEventsService.shared.allClubEvents
            self.init(clubEvents: clubEvents)
        } else {
            self.init()
        }
    }
    
    // Генерация тестовых событий
    private func generateSampleEvents() {
                    events = CalendarDataMock.generateSampleEvents()
    }
    
    // Обновление дней календаря
    func updateCalendarDays() {
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)?.start ?? startOfMonth
        
        var days: [CalendarDay] = []
        
        // Генерируем 42 дня (6 недель по 7 дней)
        for dayOffset in 0..<42 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) {
                let dayEvents = eventsForDate(date)
                let isCurrentMonth = calendar.isDate(date, equalTo: selectedDate, toGranularity: .month)
                let isToday = calendar.isDateInToday(date)
                let isCurrentWeek = calendar.isDate(date, equalTo: selectedDate, toGranularity: .weekOfYear)
                
                let day = CalendarDay(
                    date: date,
                    events: dayEvents,
                    isCurrentMonth: isCurrentMonth,
                    isToday: isToday,
                    isCurrentWeek: isCurrentWeek
                )
                days.append(day)
            }
        }
        
        calendarDays = days
    }
    
    // Обновление дней недели
    func updateWeekDays() {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        
        var days: [CalendarDay] = []
        
        // Генерируем 7 дней недели
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) {
                let dayEvents = eventsForDate(date)
                let isCurrentWeek = calendar.isDate(date, equalTo: selectedDate, toGranularity: .weekOfYear)
                let isToday = calendar.isDateInToday(date)
                
                let day = CalendarDay(
                    date: date,
                    events: dayEvents,
                    isCurrentMonth: isCurrentWeek,
                    isToday: isToday,
                    isCurrentWeek: isCurrentWeek
                )
                days.append(day)
            }
        }
        
        weekDays = days
    }
    
    // Получение событий для конкретной даты
    func eventsForDate(_ date: Date) -> [CalendarEvent] {
        return events.filter { event in
            calendar.isDate(event.startTime, inSameDayAs: date)
        }
    }
    
    // Навигация по месяцам
    func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
            updateCalendarDays()
        }
    }
    
    func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
            updateCalendarDays()
        }
    }
    
    // Навигация по неделям
    func previousWeek() {
        if let newDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) {
            selectedDate = newDate
            updateWeekDays()
        }
    }
    
    func nextWeek() {
        if let newDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) {
            selectedDate = newDate
            updateWeekDays()
        }
    }
    
    // Навигация по дням
    func previousDay() {
        if let newDate = calendar.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    func nextDay() {
        if let newDate = calendar.date(byAdding: .day, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    // Навигация по годам
    func previousYear() {
        if let newDate = calendar.date(byAdding: .year, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    func nextYear() {
        if let newDate = calendar.date(byAdding: .year, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    // Форматирование строк
    func monthYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: selectedDate).capitalized
    }
    
    func selectedDayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: selectedDate).capitalized
    }
    
    func selectedWeekString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.end ?? selectedDate
        
        let startString = formatter.string(from: startOfWeek)
        let endString = formatter.string(from: endOfWeek)
        
        return "\(startString) - \(endString)"
    }
    
    func weekdaySymbols() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.shortWeekdaySymbols
    }
    
    // Вычисляемые свойства
    var selectedYear: Int {
        calendar.component(.year, from: selectedDate)
    }
    
    // Добавление нового события
    func addEvent(_ event: CalendarEvent) {
        events.append(event)
        updateCalendarDays()
        updateWeekDays()
    }
    
    // Удаление события
    func removeEvent(_ event: CalendarEvent) {
        events.removeAll { $0.id == event.id }
        updateCalendarDays()
        updateWeekDays()
    }
    
    // Методы для загрузки разных типов моковых данных
    func loadWeekendEvents() {
                    events = CalendarDataMock.generateWeekendEvents()
        updateCalendarDays()
        updateWeekDays()
    }
    
    func loadWorkdayEvents() {
                    events = CalendarDataMock.generateWorkdayEvents()
        updateCalendarDays()
        updateWeekDays()
    }
    
    func loadEmptyEvents() {
                    events = CalendarDataMock.generateEmptyEvents()
        updateCalendarDays()
        updateWeekDays()
    }
    
    // Метод для обновления событий из ClubEvent
    func updateEvents(from clubEvents: [ClubEvent]) {
        events = ClubEventsService.shared.getAllCalendarEvents()
        print("DEBUG: CalendarViewModel обновлен, теперь содержит \(events.count) событий")
        updateCalendarDays()
        updateWeekDays()
    }
}
