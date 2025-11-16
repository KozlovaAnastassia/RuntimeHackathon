import Foundation
import SwiftUI

@MainActor
class ClubEventsService: ObservableObject {
    static let shared = ClubEventsService()
    
    @Published var allClubEvents: [ClubEvent] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let calendarRepository: CalendarRepository
    
    private init(calendarRepository: CalendarRepository = DataLayerIntegration.shared.calendarRepository) {
        self.calendarRepository = calendarRepository
    }
    
    // Загружает все события из всех клубов
    func loadAllEvents() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Получаем все события из календарного репозитория
            let calendarEvents = try await calendarRepository.getAllEvents()
            
            // Конвертируем CalendarEvent в ClubEvent
            allClubEvents = calendarEvents.map { calendarEvent in
                ClubEvent(
                    title: calendarEvent.title,
                    date: calendarEvent.date,
                    location: calendarEvent.location,
                    description: calendarEvent.description
                )
            }
            
            print("DEBUG: Загружено \(allClubEvents.count) событий из репозитория")
        } catch {
            errorMessage = error.localizedDescription
            print("DEBUG: Ошибка загрузки событий: \(error)")
        }
        
        isLoading = false
    }
    
    // Добавляет новое событие в клуб и обновляет общий список
    func addEvent(_ event: ClubEvent, to clubId: UUID) async {
        do {
            // Создаем CalendarEvent для сохранения в репозитории
            let calendarEvent = CalendarEvent(
                id: event.id,
                title: event.title,
                date: event.date,
                location: event.location,
                description: event.description,
                color: .blue,
                clubName: await getClubName(for: clubId)
            )
            
            try await calendarRepository.saveEvent(calendarEvent)
            
            // Обновляем общий список
            await loadAllEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // Получает события для конкретного клуба
    func getEventsForClub(_ clubId: UUID) async -> [ClubEvent] {
        do {
            let clubName = await getClubName(for: clubId)
            let calendarEvents = try await calendarRepository.getClubEvents(for: clubName)
            
            return calendarEvents.map { calendarEvent in
                ClubEvent(
                    title: calendarEvent.title,
                    date: calendarEvent.date,
                    location: calendarEvent.location,
                    description: calendarEvent.description
                )
            }
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
    }
    
    // Удаляет событие из клуба
    func removeEvent(_ event: ClubEvent, from clubId: UUID) async {
        do {
            let calendarEvent = CalendarEvent(
                id: event.id,
                title: event.title,
                date: event.date,
                location: event.location,
                description: event.description,
                color: .blue,
                clubName: await getClubName(for: clubId)
            )
            
            try await calendarRepository.deleteEvent(calendarEvent)
            
            // Обновляем общий список
            await loadAllEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // Получает название клуба по ID
    private func getClubName(for clubId: UUID) async -> String {
        do {
            if let club = try await DataLayerIntegration.shared.clubRepository.getClub(by: clubId) {
                return club.name
            }
        } catch {
            print("Ошибка получения названия клуба: \(error)")
        }
        return "Неизвестный клуб"
    }
    
    // Получает все события в формате CalendarEvent для календаря
    func getAllCalendarEvents() async -> [CalendarEvent] {
        do {
            let calendarEvents = try await calendarRepository.getAllEvents()
            print("DEBUG: getAllCalendarEvents() вызван, всего событий: \(calendarEvents.count)")
            return calendarEvents
        } catch {
            errorMessage = error.localizedDescription
            print("DEBUG: Ошибка получения событий для календаря: \(error)")
            return []
        }
    }
    
    // Обновляет события при изменении в клубе
    func refreshEvents() async {
        await loadAllEvents()
    }
}
