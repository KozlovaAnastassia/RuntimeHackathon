import Foundation
import SwiftUI

// MARK: - Моковые данные для CalendarDayView
struct CalendarDayMock {
    static let sampleDayWithEvents = CalendarDay(
        date: Date(),
        events: [
            CalendarEvent(
                id: UUID(),
                title: "Утренняя встреча",
                date: Date(),
                location: "Конференц-зал А",
                description: "Ежедневная синхронизация команды",
                color: .blue
            ),
            CalendarEvent(
                id: UUID(),
                title: "Обед",
                date: Date().addingTimeInterval(3600),
                location: "Столовая",
                description: "Перерыв на обед",
                color: .orange
            ),
            CalendarEvent(
                id: UUID(),
                title: "Работа над проектом",
                date: Date().addingTimeInterval(7200),
                location: "Рабочее место",
                description: "Разработка новых функций",
                color: .green
            ),
            CalendarEvent(
                id: UUID(),
                title: "Вечерняя тренировка",
                date: Date().addingTimeInterval(18000),
                location: "Спортзал",
                description: "Кардио тренировка",
                color: .red
            )
        ],
        isCurrentMonth: true,
        isToday: true,
        isCurrentWeek: true
    )
    
    static let sampleDayWithFewEvents = CalendarDay(
        date: Date(),
        events: [
            CalendarEvent(
                id: UUID(),
                title: "Встреча",
                date: Date(),
                location: "Офис",
                description: "Короткая встреча",
                color: .blue
            )
        ],
        isCurrentMonth: true,
        isToday: false,
        isCurrentWeek: true
    )
    
    static let sampleDayWithoutEvents = CalendarDay(
        date: Date(),
        events: [],
        isCurrentMonth: true,
        isToday: false,
        isCurrentWeek: true
    )
    
    static let sampleDayNotCurrentMonth = CalendarDay(
        date: Date().addingTimeInterval(86400 * 30), // +30 дней
        events: [
            CalendarEvent(
                id: UUID(),
                title: "Будущее событие",
                date: Date().addingTimeInterval(86400 * 30),
                location: "Неизвестно",
                description: "Событие в следующем месяце",
                color: .purple
            )
        ],
        isCurrentMonth: false,
        isToday: false,
        isCurrentWeek: false
    )
}
