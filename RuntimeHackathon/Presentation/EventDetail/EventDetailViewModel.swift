import SwiftUI

@MainActor
class EventDetailViewModel: ObservableObject {
    @Published var event: CalendarEvent
    @Published var isRegistered = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: CalendarRepository
    
    init(event: CalendarEvent, repository: CalendarRepository = DataLayerIntegration.shared.calendarRepository) {
        self.event = event
        self.repository = repository
        checkRegistrationStatus()
    }
    
    // Проверка статуса записи пользователя
    private func checkRegistrationStatus() {
        // Здесь будет логика проверки записи пользователя
        // Пока используем моковые данные
        isRegistered = false
    }
    
    // Запись на мероприятие
    func registerForEvent() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Здесь будет API вызов для записи на мероприятие
            try await Task.sleep(nanoseconds: 1_000_000_000) // Имитация задержки
            
            isRegistered = true
        } catch {
            errorMessage = "Ошибка при записи на мероприятие: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // Отмена записи на мероприятие
    func unregisterFromEvent() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Здесь будет API вызов для отмены записи
            try await Task.sleep(nanoseconds: 1_000_000_000) // Имитация задержки
            
            isRegistered = false
        } catch {
            errorMessage = "Ошибка при отмене записи: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // Удаление мероприятия
    func deleteEvent() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await repository.deleteEvent(event)
            return true
        } catch {
            errorMessage = "Ошибка при удалении мероприятия: \(error.localizedDescription)"
            return false
        }
    }
    
    // Обновление информации о мероприятии
    func refreshEvent() async {
        isLoading = true
        errorMessage = nil
        
        do {
            if let updatedEvent = try await repository.getEvent(by: event.id) {
                event = updatedEvent
            }
        } catch {
            errorMessage = "Ошибка при обновлении информации: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
