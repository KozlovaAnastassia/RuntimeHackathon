import Foundation
import SwiftUI

// MARK: - Моковые данные для календаря
struct CalendarDataMock {
    // MARK: - События календаря
    static let sampleEvent = CalendarEvent(
        id: UUID(),
        title: "Встреча клуба",
        date: Date(),
        location: "Главный зал",
        description: "Еженедельная встреча участников клуба",
        color: .blue
    )
    
    static let sampleEventSimple = CalendarEvent(
        id: UUID(),
        title: "Мастер-класс",
        date: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date(),
        location: "Аудитория 3",
        description: "Мастер-класс по программированию",
        color: .green
    )
    
    // MARK: - Дни календаря
    static let sampleCalendarDays: [CalendarDay] = {
        var days: [CalendarDay] = []
        let calendar = Calendar.current
        let today = Date()
        
        for i in 0..<35 {
            if let date = calendar.date(byAdding: .day, value: i - 17, to: today) {
                let dayNumber = calendar.component(.day, from: date)
                let isCurrentMonth = calendar.isDate(date, equalTo: today, toGranularity: .month)
                let isToday = calendar.isDateInToday(date)
                
                let events = i % 3 == 0 ? [sampleEvent] : []
                
                days.append(CalendarDay(
                    date: date,
                    events: events,
                    isCurrentMonth: isCurrentMonth,
                    isToday: isToday
                ))
            }
        }
        return days
    }()
    
    static let sampleDayWithEvents = CalendarDay(
        date: Date(),
        events: [sampleEvent, sampleEventSimple],
        isCurrentMonth: true,
        isToday: true
    )
    
    static let sampleDayWithFewEvents = CalendarDay(
        date: Date(),
        events: [sampleEvent],
        isCurrentMonth: true,
        isToday: true
    )
    
    static let sampleDayWithoutEvents = CalendarDay(
        date: Date(),
        events: [],
        isCurrentMonth: true,
        isToday: true
    )
    
    static let sampleDayNotCurrentMonth = CalendarDay(
        date: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
        events: [],
        isCurrentMonth: false,
        isToday: false
    )
    
    // MARK: - Компоненты календаря
    static let sampleMonthYearString = "Декабрь 2024"
    static let sampleWeekdaySymbols = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    static let sampleEventIndicator = CalendarDay(
        date: Date(),
        events: [sampleEvent],
        isCurrentMonth: true,
        isToday: false
    )
    
    // MARK: - События для секций
    static let sampleClubEvents = [
        ClubEvent(
            title: "Встреча клуба",
            date: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date(),
            location: "Главный зал",
            description: "Еженедельная встреча участников клуба"
        ),
        ClubEvent(
            title: "Мастер-класс",
            date: Calendar.current.date(byAdding: .hour, value: 5, to: Date()) ?? Date(),
            location: "Аудитория 3",
            description: "Мастер-класс по программированию"
        )
    ]
    
    static let emptyClubEvents: [ClubEvent] = []
    static let sampleReloadTrigger = UUID()
    
    // MARK: - Генерация событий
    static func generateSampleEvents() -> [CalendarEvent] {
        return [
            CalendarEvent(id: UUID(), title: "Встреча клуба", date: Date(), location: "Главный зал", description: "Еженедельная встреча", color: .blue),
            CalendarEvent(id: UUID(), title: "Мастер-класс", date: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date(), location: "Аудитория 3", description: "Мастер-класс по программированию", color: .green),
            CalendarEvent(id: UUID(), title: "Турнир", date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(), location: "Спортивный зал", description: "Ежегодный турнир", color: .red)
        ]
    }
    
    static func generateWeekendEvents() -> [CalendarEvent] {
        return [
            CalendarEvent(id: UUID(), title: "Выходная встреча", date: Date(), location: "Парк", description: "Неформальная встреча", color: .orange)
        ]
    }
    
    static func generateWorkdayEvents() -> [CalendarEvent] {
        return [
            CalendarEvent(id: UUID(), title: "Рабочая встреча", date: Date(), location: "Офис", description: "Обсуждение проектов", color: .purple)
        ]
    }
    
    static func generateEmptyEvents() -> [CalendarEvent] {
        return []
    }
    
    // MARK: - Цвета календаря
    static let calendarColors: [String: Color] = [
        "red": .red,
        "blue": .blue,
        "green": .green,
        "yellow": .yellow,
        "orange": .orange,
        "purple": .purple,
        "pink": .pink,
        "brown": .brown,
        "gray": .gray,
        "black": .black,
        "white": .white
    ]
    
    // MARK: - Создание событий для клуба
    static func createSampleEventsForClub(_ clubId: UUID) -> [ClubEvent] {
        return [
            ClubEvent(
                title: "Встреча клуба \(clubId.uuidString.prefix(8))",
                date: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date(),
                location: "Главный зал",
                description: "Еженедельная встреча участников клуба"
            ),
            ClubEvent(
                title: "Мастер-класс \(clubId.uuidString.prefix(8))",
                date: Calendar.current.date(byAdding: .hour, value: 5, to: Date()) ?? Date(),
                location: "Аудитория 3",
                description: "Мастер-класс по программированию"
            )
        ]
    }
}
