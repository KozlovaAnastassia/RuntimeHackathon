import SwiftUI

struct CalendarMock {
    
    // Генерация тестовых событий
    static func generateSampleEvents() -> [CalendarEvent] {
        let today = Date()
        let calendar = Calendar.current
        
        // Событие на 15 минут
        let shortEvent = CalendarEvent(
            id: UUID(),
            title: "Короткая встреча",
            date: calendar.date(byAdding: .hour, value: 1, to: today) ?? today,
            location: "Конференц-зал А",
            description: "Быстрая синхронизация",
            color: .blue
        )
        
        // Событие на 2 часа
        let longEvent = CalendarEvent(
            id: UUID(),
            title: "Длинная презентация",
            date: calendar.date(byAdding: .hour, value: 3, to: today) ?? today,
            location: "Аудитория 101",
            description: "Подробный обзор проекта",
            color: .green
        )
        
        // Событие на 4 часа
        let veryLongEvent = CalendarEvent(
            id: UUID(),
            title: "Рабочий день",
            date: calendar.date(byAdding: .hour, value: 9, to: today) ?? today,
            location: "Офис",
            description: "Основная работа над проектом",
            color: .orange
        )
        
        return [shortEvent, longEvent, veryLongEvent]
    }
    
    // Дополнительные моковые события для разных сценариев
    static func generateWeekendEvents() -> [CalendarEvent] {
        let today = Date()
        let calendar = Calendar.current
        
        let weekendEvent1 = CalendarEvent(
            id: UUID(),
            title: "Отдых",
            date: calendar.date(byAdding: .hour, value: 10, to: today) ?? today,
            location: "Дом",
            description: "Время для себя",
            color: .purple
        )
        
        let weekendEvent2 = CalendarEvent(
            id: UUID(),
            title: "Спорт",
            date: calendar.date(byAdding: .hour, value: 16, to: today) ?? today,
            location: "Спортзал",
            description: "Тренировка",
            color: .red
        )
        
        return [weekendEvent1, weekendEvent2]
    }
    
    static func generateWorkdayEvents() -> [CalendarEvent] {
        let today = Date()
        let calendar = Calendar.current
        
        let morningMeeting = CalendarEvent(
            id: UUID(),
            title: "Утренняя встреча",
            date: calendar.date(byAdding: .hour, value: 9, to: today) ?? today,
            location: "Переговорная 1",
            description: "Планирование дня",
            color: .blue
        )
        
        let lunch = CalendarEvent(
            id: UUID(),
            title: "Обед",
            date: calendar.date(byAdding: .hour, value: 13, to: today) ?? today,
            location: "Столовая",
            description: "Перерыв на обед",
            color: .orange
        )
        
        let projectWork = CalendarEvent(
            id: UUID(),
            title: "Работа над проектом",
            date: calendar.date(byAdding: .hour, value: 14, to: today) ?? today,
            location: "Рабочее место",
            description: "Разработка новых функций",
            color: .green
        )
        
        return [morningMeeting, lunch, projectWork]
    }
    
    // Моковые данные для пустого календаря
    static func generateEmptyEvents() -> [CalendarEvent] {
        return []
    }
}

#Preview {
    CalendarDayView(
        day: CalendarDay(
            date: Date(),
            events: [],
            isCurrentMonth: true,
            isToday: true,
            isCurrentWeek: true
        )
    ) { _ in }
}
