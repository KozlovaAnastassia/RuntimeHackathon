//
//  ClubDetailViewModel.swift
//  RuntimeHackathon
//
//  Created by KOZLOVA Anastasia on 23.08.2025.
//

import SwiftUI

// MARK: - Обновленный ViewModel
class ClubViewModel: ObservableObject {
    @Published var events: [ClubEvent] = []
    @Published var newsItems: [NewsItem] = []
    private let clubId: UUID
    private let isCreator: Bool
    
  init(clubId: UUID, isCreator: Bool) {
        self.clubId = clubId
        self.isCreator = isCreator
        loadEvents()
        loadNews()
        
        // Откладываем загрузку событий из сервиса
        DispatchQueue.main.async {
            ClubEventsService.shared.loadAllEvents()
        }
    }
    
    func createEvent(title: String, date: Date, location: String, description: String) {
        // Добавляем название клуба в заголовок события для идентификации в календаре
        let clubName = getClubName()
        let eventTitle = "\(title) в \(clubName)"
        let newEvent = ClubEvent(title: eventTitle, date: date, location: location, description: description)
        events.append(newEvent)
        print("DEBUG: Создано новое событие: \(eventTitle) для клуба \(clubId)")
        saveEvents()
    }
    
    // Получает название клуба по ID
    private func getClubName() -> String {
        let clubs = ClubsListViewModel().clubs
        if let club = clubs.first(where: { $0.id == clubId }) {
            return club.name
        }
        return "Неизвестный клуб"
    }
    
    func createNews(title: String, description: String, imagesData: [Data]) {
        let newNews = NewsItem(
            title: title,
            description: description,
            imagesData: imagesData
        )
        newsItems.append(newNews)
        saveNews()
    }
    
    func deleteNews(id: UUID) {
        newsItems.removeAll { $0.id == id }
        saveNews()
    }
    
    private func saveEvents() {
        let key = "ClubEvents_\(clubId.uuidString)"
        if let encoded = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(encoded, forKey: key)
            print("DEBUG: Сохранено \(events.count) событий в UserDefaults для клуба \(clubId)")
        }
        
        // Обновляем сервис асинхронно
        DispatchQueue.main.async {
            print("DEBUG: Обновляем ClubEventsService...")
            ClubEventsService.shared.loadAllEvents()
        }
    }
    
    private func loadEvents() {
        // Загружаем события из сервиса
        events = ClubEventsService.shared.getEventsForClub(clubId)
    }
    
    private func saveNews() {
        let key = "ClubNews_\(clubId.uuidString)"
        do {
            let newsData = try JSONEncoder().encode(newsItems)
            UserDefaults.standard.set(newsData, forKey: key)
        } catch {
            print("Ошибка сохранения новостей: \(error)")
        }
    }
    
    private func loadNews() {
        let key = "ClubNews_\(clubId.uuidString)"
        do {
            if let data = UserDefaults.standard.data(forKey: key) {
                let decoded = try JSONDecoder().decode([NewsItem].self, from: data)
                newsItems = decoded
            }
        } catch {
            print("Ошибка загрузки новостей: \(error)")
        }
    }
}
