//
//  ClubDetailViewModel.swift
//  RuntimeHackathon
//
//  Created by KOZLOVA Anastasia on 23.08.2025.
//

import SwiftUI

// MARK: - Обновленный ViewModel
@MainActor
class ClubViewModel: ObservableObject {
    @Published var events: [ClubEvent] = []
    @Published var newsItems: [NewsItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let clubId: UUID
    private let isCreator: Bool
    private let clubRepository: ClubRepository
    private let newsRepository: NewsRepository
    
    init(clubId: UUID, isCreator: Bool, 
         clubRepository: ClubRepository = DataLayerIntegration.shared.clubRepository,
         newsRepository: NewsRepository = NewsRepository()) {
        self.clubId = clubId
        self.isCreator = isCreator
        self.clubRepository = clubRepository
        self.newsRepository = newsRepository
    }
    
    func loadData() async {
        await loadEvents()
        await loadNews()
    }
    
    func createEvent(title: String, date: Date, location: String, description: String) async {
        // Добавляем название клуба в заголовок события для идентификации в календаре
        let clubName = await getClubName()
        let eventTitle = "\(title) в \(clubName)"
        let newEvent = ClubEvent(title: eventTitle, date: date, location: location, description: description)
        
        // Создаем CalendarEvent для сохранения в репозитории
        let calendarEvent = CalendarEvent(
            id: UUID(),
            title: eventTitle,
            date: date,
            location: location,
            description: description,
            color: .blue,
            clubName: clubName
        )
        
        do {
            try await DataLayerIntegration.shared.calendarRepository.saveEvent(calendarEvent)
            events.append(newEvent)
            print("DEBUG: Создано новое событие: \(eventTitle) для клуба \(clubId)")
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // Получает название клуба по ID
    private func getClubName() async -> String {
        do {
            if let club = try await clubRepository.getClub(by: clubId) {
                return club.name
            }
        } catch {
            print("Ошибка получения названия клуба: \(error)")
        }
        return "Неизвестный клуб"
    }
    
    func createNews(title: String, description: String, imagesData: [Data]) async {
        let newNews = NewsItem(
            title: title,
            description: description,
            imagesData: imagesData
        )
        
        do {
            try await newsRepository.saveNews(newNews, for: clubId)
            newsItems.append(newNews)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteNews(id: UUID) async {
        if let newsToDelete = newsItems.first(where: { $0.id == id }) {
            do {
                try await newsRepository.deleteNews(newsToDelete, from: clubId)
                newsItems.removeAll { $0.id == id }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func loadEvents() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Загружаем события из календарного репозитория
            let calendarEvents = try await DataLayerIntegration.shared.calendarRepository.getClubEvents(for: await getClubName())
            
            // Конвертируем CalendarEvent в ClubEvent
            events = calendarEvents.map { calendarEvent in
                ClubEvent(
                    title: calendarEvent.title,
                    date: calendarEvent.date,
                    location: calendarEvent.location,
                    description: calendarEvent.description
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func loadNews() async {
        isLoading = true
        errorMessage = nil
        
        do {
            newsItems = try await newsRepository.getNews(for: clubId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
