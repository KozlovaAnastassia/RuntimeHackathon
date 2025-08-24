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
        print("DEBUG: Найдено \(clubs.count) клубов для загрузки событий")
        
        // Загружаем события для каждого клуба
        for club in clubs {
            let key = "ClubEvents_\(club.id.uuidString)"
            print("DEBUG: Проверяем ключ: \(key) для клуба \(club.name)")
            
            if let data = UserDefaults.standard.data(forKey: key) {
                print("DEBUG: Найдены данные в UserDefaults для клуба \(club.name)")
                if let decoded = try? JSONDecoder().decode([ClubEvent].self, from: data) {
                    allEvents.append(contentsOf: decoded)
                    print("DEBUG: Загружено \(decoded.count) событий для клуба \(club.name)")
                } else {
                    print("DEBUG: ОШИБКА декодирования данных для клуба \(club.name)")
                }
            } else {
                print("DEBUG: Нет данных в UserDefaults для клуба \(club.name)")
            }
        }
        
        // Также проверим все ключи в UserDefaults, которые начинаются с "ClubEvents_"
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        let clubEventKeys = allKeys.filter { $0.hasPrefix("ClubEvents_") }
        print("DEBUG: Найдено \(clubEventKeys.count) ключей ClubEvents_ в UserDefaults:")
        for key in clubEventKeys {
            print("DEBUG: Ключ: \(key)")
        }
        
        print("DEBUG: Всего загружено \(allEvents.count) событий из всех клубов")
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
        print("DEBUG: getAllCalendarEvents() вызван, всего событий: \(allClubEvents.count)")
        
        let calendarEvents = allClubEvents.enumerated().map { index, clubEvent in
            let color = ClubEventsMock.calendarColors[index % ClubEventsMock.calendarColors.count]
            // Извлекаем название клуба из заголовка события
            let clubName = extractClubName(from: clubEvent.title)
            print("DEBUG: Преобразуем событие: \(clubEvent.title) -> CalendarEvent")
            return CalendarEvent(from: clubEvent, color: color, clubName: clubName)
        }
        
        print("DEBUG: Возвращаем \(calendarEvents.count) событий для календаря")
        return calendarEvents
    }
    
    // Извлекает название клуба из заголовка события
    private func extractClubName(from title: String) -> String? {
        // Ищем паттерн "в [Название клуба]"
        if let range = title.range(of: "в ", options: .caseInsensitive) {
            let clubNameStart = title.index(range.upperBound, offsetBy: 0)
            let clubName = String(title[clubNameStart...])
            print("DEBUG: Извлечено название клуба: \(clubName) из заголовка: \(title)")
            return clubName
        }
        print("DEBUG: Не удалось извлечь название клуба из заголовка: \(title)")
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
        return ClubEventsMock.createSampleEventsForClub(club)
    }
}
