import Foundation
import SwiftUI

// MARK: - API модели для календарных событий
struct CalendarEventApiResponse: Codable {
    let success: Bool
    let data: [CalendarEventApiModel]
    let message: String?
}

struct CalendarEventApiModel: Codable {
    let id: String
    let title: String
    let date: String
    let location: String
    let description: String
    let createdAt: String
    let colorHex: String
    let clubName: String?
    
    func toCalendarEvent() -> CalendarEvent {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = formatter.date(from: self.date) ?? Date()
        let createdAt = formatter.date(from: self.createdAt) ?? Date()
        let color = Color(hex: colorHex) ?? .blue
        
        return CalendarEvent(
            id: UUID(uuidString: id) ?? UUID(),
            title: title,
            date: date,
            location: location,
            description: description,
            color: color,
            clubName: clubName
        )
    }
}

struct CreateEventRequest: Codable {
    let title: String
    let date: String
    let location: String
    let description: String
    let colorHex: String
    let clubName: String?
}

struct UpdateEventRequest: Codable {
    let title: String?
    let date: String?
    let location: String?
    let description: String?
    let colorHex: String?
    let clubName: String?
}

// MARK: - API сервис для календарных событий
class CalendarApiService {
    static let shared = CalendarApiService()
    private let apiClient = ApiClient.shared
    
    private init() {}
    
    // MARK: - Получение всех событий
    func getAllEvents() async throws -> [CalendarEvent] {
        let response: CalendarEventApiResponse = try await apiClient.get("/events")
        return response.data.map { $0.toCalendarEvent() }
    }
    
    // MARK: - Получение события по ID
    func getEvent(by id: UUID) async throws -> CalendarEvent {
        let response: CalendarEventApiResponse = try await apiClient.get("/events/\(id.uuidString)")
        guard let eventData = response.data.first else {
            throw ApiError.notFound
        }
        return eventData.toCalendarEvent()
    }
    
    // MARK: - Создание события
    func createEvent(_ request: CreateEventRequest) async throws -> CalendarEvent {
        let response: CalendarEventApiResponse = try await apiClient.post("/events", body: request)
        guard let eventData = response.data.first else {
            throw ApiError.decodingError
        }
        return eventData.toCalendarEvent()
    }
    
    // MARK: - Обновление события
    func updateEvent(_ id: UUID, with request: UpdateEventRequest) async throws -> CalendarEvent {
        let response: CalendarEventApiResponse = try await apiClient.put("/events/\(id.uuidString)", body: request)
        guard let eventData = response.data.first else {
            throw ApiError.decodingError
        }
        return eventData.toCalendarEvent()
    }
    
    // MARK: - Удаление события
    func deleteEvent(_ id: UUID) async throws {
        try await apiClient.delete("/events/\(id.uuidString)")
    }
    
    // MARK: - Получение событий по дате
    func getEvents(for date: Date) async throws -> [CalendarEvent] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        let parameters = ["date": dateString]
        let response: CalendarEventApiResponse = try await apiClient.get("/events/date", parameters: parameters)
        return response.data.map { $0.toCalendarEvent() }
    }
    
    // MARK: - Получение событий по диапазону дат
    func getEvents(from startDate: Date, to endDate: Date) async throws -> [CalendarEvent] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startDateString = formatter.string(from: startDate)
        let endDateString = formatter.string(from: endDate)
        
        let parameters = [
            "start_date": startDateString,
            "end_date": endDateString
        ]
        let response: CalendarEventApiResponse = try await apiClient.get("/events/range", parameters: parameters)
        return response.data.map { $0.toCalendarEvent() }
    }
    
    // MARK: - Получение событий клуба
    func getClubEvents(for clubName: String) async throws -> [CalendarEvent] {
        let parameters = ["club_name": clubName]
        let response: CalendarEventApiResponse = try await apiClient.get("/events/club", parameters: parameters)
        return response.data.map { $0.toCalendarEvent() }
    }
    
    // MARK: - Получение событий пользователя
    func getUserEvents() async throws -> [CalendarEvent] {
        let response: CalendarEventApiResponse = try await apiClient.get("/user/events")
        return response.data.map { $0.toCalendarEvent() }
    }
    
    // MARK: - Поиск событий
    func searchEvents(query: String) async throws -> [CalendarEvent] {
        let parameters = ["q": query]
        let response: CalendarEventApiResponse = try await apiClient.get("/events/search", parameters: parameters)
        return response.data.map { $0.toCalendarEvent() }
    }
    
    // MARK: - Получение событий по категории
    func getEventsByCategory(_ category: String) async throws -> [CalendarEvent] {
        let parameters = ["category": category]
        let response: CalendarEventApiResponse = try await apiClient.get("/events/category", parameters: parameters)
        return response.data.map { $0.toCalendarEvent() }
    }
    
    // MARK: - Получение предстоящих событий
    func getUpcomingEvents(limit: Int = 10) async throws -> [CalendarEvent] {
        let parameters = ["limit": limit]
        let response: CalendarEventApiResponse = try await apiClient.get("/events/upcoming", parameters: parameters)
        return response.data.map { $0.toCalendarEvent() }
    }
    
    // MARK: - Получение событий за неделю
    func getWeekEvents() async throws -> [CalendarEvent] {
        let response: CalendarEventApiResponse = try await apiClient.get("/events/week")
        return response.data.map { $0.toCalendarEvent() }
    }
    
    // MARK: - Получение событий за месяц
    func getMonthEvents() async throws -> [CalendarEvent] {
        let response: CalendarEventApiResponse = try await apiClient.get("/events/month")
        return response.data.map { $0.toCalendarEvent() }
    }
}
