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
    
    init(clubId: UUID) {
        self.clubId = clubId
        loadEvents()
        loadNews()
        
        // Откладываем загрузку событий из сервиса
        DispatchQueue.main.async {
            ClubEventsService.shared.loadAllEvents()
        }
    }
    
    func createEvent(title: String, date: Date, location: String, description: String) {
        let newEvent = ClubEvent(title: title, date: date, location: location, description: description)
        events.append(newEvent)
        saveEvents()
        
        // Уведомляем сервис о новом событии
        ClubEventsService.shared.addEvent(newEvent, to: clubId)
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
        }
        
        // Обновляем сервис асинхронно
        DispatchQueue.main.async {
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
