import SwiftUI

struct CalendarMock {
    
    // Генерация тестовых событий
    static func generateSampleEvents() -> [CalendarEvent] {
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
        
        return [shortEvent, longEvent, veryLongEvent]
    }
    
    // Дополнительные моковые события для разных сценариев
    static func generateWeekendEvents() -> [CalendarEvent] {
        let today = Date()
        let calendar = Calendar.current
        
        let weekendEvent1 = CalendarEvent(
            title: "Отдых",
            description: "Время для себя",
            startTime: calendar.date(byAdding: .hour, value: 10, to: today) ?? today,
            endTime: calendar.date(byAdding: .hour, value: 12, to: today) ?? today,
            color: .purple
        )
        
        let weekendEvent2 = CalendarEvent(
            title: "Спорт",
            description: "Тренировка",
            startTime: calendar.date(byAdding: .hour, value: 16, to: today) ?? today,
            endTime: calendar.date(byAdding: .hour, value: 17, to: today) ?? today,
            color: .red
        )
        
        return [weekendEvent1, weekendEvent2]
    }
    
    static func generateWorkdayEvents() -> [CalendarEvent] {
        let today = Date()
        let calendar = Calendar.current
        
        let morningMeeting = CalendarEvent(
            title: "Утренняя встреча",
            description: "Планирование дня",
            startTime: calendar.date(byAdding: .hour, value: 9, to: today) ?? today,
            endTime: calendar.date(byAdding: .hour, value: 9, to: today) ?? today,
            color: .blue
        )
        
        let lunch = CalendarEvent(
            title: "Обед",
            description: "Перерыв на обед",
            startTime: calendar.date(byAdding: .hour, value: 13, to: today) ?? today,
            endTime: calendar.date(byAdding: .hour, value: 14, to: today) ?? today,
            color: .orange
        )
        
        let projectWork = CalendarEvent(
            title: "Работа над проектом",
            description: "Разработка новых функций",
            startTime: calendar.date(byAdding: .hour, value: 14, to: today) ?? today,
            endTime: calendar.date(byAdding: .hour, value: 18, to: today) ?? today,
            color: .green
        )
        
        return [morningMeeting, lunch, projectWork]
    }
    
    // Моковые данные для пустого календаря
    static func generateEmptyEvents() -> [CalendarEvent] {
        return []
    }
}
