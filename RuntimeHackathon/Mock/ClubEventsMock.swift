import Foundation
import SwiftUI

// MARK: - Моковые данные для событий клубов
struct ClubEventsMock {
    static let calendarColors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .yellow, .mint]
    
    // Создает тестовые события для конкретного клуба
    static func createSampleEventsForClub(_ club: Club) -> [ClubEvent] {
        let calendar = Calendar.current
        let today = Date()
        
        var events: [ClubEvent] = []
        
        // Событие на сегодня
        if let todayEvent = calendar.date(byAdding: .hour, value: 2, to: today) {
            events.append(ClubEvent(
                title: "Встреча в \(club.name)",
                date: todayEvent,
                location: "Главный зал",
                description: "Еженедельная встреча участников клуба"
            ))
        }
        
        // Событие на завтра
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: today),
           let tomorrowEvent = calendar.date(byAdding: .hour, value: 14, to: tomorrow) {
            events.append(ClubEvent(
                title: "Тренировка в \(club.name)",
                date: tomorrowEvent,
                location: "Спортивный зал",
                description: "Интенсивная тренировка для всех участников"
            ))
        }
        
        // Событие через неделю
        if let nextWeek = calendar.date(byAdding: .day, value: 7, to: today),
           let nextWeekEvent = calendar.date(byAdding: .hour, value: 18, to: nextWeek) {
            events.append(ClubEvent(
                title: "Соревнования в \(club.name)",
                date: nextWeekEvent,
                location: "Стадион",
                description: "Ежемесячные соревнования между участниками"
            ))
        }
        
        return events
    }
}
