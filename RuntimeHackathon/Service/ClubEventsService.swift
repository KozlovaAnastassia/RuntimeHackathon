import Foundation
import SwiftUI

class ClubEventsService: ObservableObject {
    static let shared = ClubEventsService()
    
    @Published var allClubEvents: [ClubEvent] = []
    
    private init() {
        loadAllEvents()
        // Откладываем создание тестовых событий, чтобы избежать обновлений во время инициализации
        DispatchQueue.main.async {
            self.createSampleEventsIfNeeded()
        }
    }
    
    // Загружает все события из всех клубов
    func loadAllEvents() {
        var allEvents: [ClubEvent] = []
        
        // Получаем список всех клубов
        let clubs = ClubsListViewModel().clubs
        
        // Загружаем события для каждого клуба
        for club in clubs {
            let key = "ClubEvents_\(club.id.uuidString)"
            if let data = UserDefaults.standard.data(forKey: key),
               let decoded = try? JSONDecoder().decode([ClubEvent].self, from: data) {
                allEvents.append(contentsOf: decoded)
            }
        }
        
        allClubEvents = allEvents
    }
    
    // Добавляет новое событие в клуб и обновляет общий список
    func addEvent(_ event: ClubEvent, to clubId: UUID) {
        // Добавляем событие в клуб
        let key = "ClubEvents_\(clubId.uuidString)"
        var clubEvents = getEventsForClub(clubId)
        clubEvents.append(event)
        
        if let encoded = try? JSONEncoder().encode(clubEvents) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
        
        // Обновляем общий список асинхронно
        DispatchQueue.main.async {
            self.loadAllEvents()
        }
    }
    
    // Получает события для конкретного клуба
    func getEventsForClub(_ clubId: UUID) -> [ClubEvent] {
        let key = "ClubEvents_\(clubId.uuidString)"
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([ClubEvent].self, from: data) {
            return decoded
        }
        return []
    }
    
    // Удаляет событие из клуба
    func removeEvent(_ event: ClubEvent, from clubId: UUID) {
        let key = "ClubEvents_\(clubId.uuidString)"
        var clubEvents = getEventsForClub(clubId)
        clubEvents.removeAll { $0.id == event.id }
        
        if let encoded = try? JSONEncoder().encode(clubEvents) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
        
        // Обновляем общий список асинхронно
        DispatchQueue.main.async {
            self.loadAllEvents()
        }
    }
    
    // Получает все события в формате CalendarEvent для календаря
    func getAllCalendarEvents() -> [CalendarEvent] {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .yellow, .mint]
        
        return allClubEvents.enumerated().map { index, clubEvent in
            let color = colors[index % colors.count]
            // Извлекаем название клуба из заголовка события
            let clubName = extractClubName(from: clubEvent.title)
            return CalendarEvent(from: clubEvent, color: color, clubName: clubName)
        }
    }
    
    // Извлекает название клуба из заголовка события
    private func extractClubName(from title: String) -> String? {
        // Ищем паттерн "в [Название клуба]"
        if let range = title.range(of: "в ", options: .caseInsensitive) {
            let clubNameStart = title.index(range.upperBound, offsetBy: 0)
            let clubName = String(title[clubNameStart...])
            return clubName
        }
        return nil
    }
    
    // Обновляет события при изменении в клубе
    func refreshEvents() {
        DispatchQueue.main.async {
            self.loadAllEvents()
        }
    }
    
    // Создает тестовые события, если их нет
    private func createSampleEventsIfNeeded() {
        let clubs = ClubsListViewModel().clubs
        
        for club in clubs {
            let clubEvents = getEventsForClub(club.id)
            if clubEvents.isEmpty {
                // Создаем тестовые события для каждого клуба
                let sampleEvents = createSampleEventsForClub(club)
                for event in sampleEvents {
                    addEvent(event, to: club.id)
                }
            }
        }
    }
    
    // Создает тестовые события для конкретного клуба
    private func createSampleEventsForClub(_ club: Club) -> [ClubEvent] {
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
