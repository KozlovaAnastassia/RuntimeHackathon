import Foundation

// MARK: - Примеры использования архитектуры данных

class DataLayerExamples {
    
    // MARK: - Инициализация Repository
    static func setupRepositories() {
        let clubRepository = ClubRepository()
        let userRepository = UserRepository()
        let calendarRepository = CalendarRepository()
        
        // Использование в ViewModels
        // ClubsListViewModel(repository: clubRepository)
        // UserProfileViewModel(repository: userRepository)
        // CalendarViewModel(repository: calendarRepository)
    }
    
    // MARK: - Примеры работы с клубами
    static func clubExamples() async {
        let repository = ClubRepository()
        
        do {
            // Получение всех клубов (с синхронизацией)
            let clubs = try await repository.getAllClubs()
            print("Найдено клубов: \(clubs.count)")
            
            // Поиск клубов
            let searchResults = try await repository.searchClubs(query: "программирование")
            print("Результаты поиска: \(searchResults.count)")
            
            // Получение конкретного клуба
            if let clubId = clubs.first?.id {
                if let club = try await repository.getClub(by: clubId) {
                    print("Клуб: \(club.name)")
                }
            }
            
            // Присоединение к клубу
            if let clubId = clubs.first?.id {
                let updatedClub = try await repository.joinClub(clubId)
                print("Присоединились к клубу: \(updatedClub.name)")
            }
            
            // Получение клубов пользователя
            let userClubs = try await repository.getUserClubs()
            print("Клубы пользователя: \(userClubs.count)")
            
        } catch {
            print("Ошибка: \(error)")
        }
    }
    
    // MARK: - Примеры работы с пользователями
    static func userExamples() async {
        let repository = UserRepository()
        
        do {
            // Получение профиля пользователя
            if let userId = UUID(uuidString: "12345678-1234-1234-1234-123456789012") {
                if let user = try await repository.getUser(by: userId) {
                    print("Пользователь: \(user.name)")
                    
                    // Добавление интереса
                    let newInterest = Interest(
                        name: "SwiftUI",
                        category: InterestCategory(
                            name: "tech",
                            emoji: "💻",
                            displayName: "Технологии"
                        )
                    )
                    try await repository.addInterest(newInterest, to: userId)
                    print("Добавлен интерес: \(newInterest.name)")
                }
            }
            
            // Получение интересов пользователя
            let interests = try await repository.getUserInterests()
            print("Интересы пользователя: \(interests.count)")
            
            // Поиск пользователей
            let searchResults = try await repository.searchUsers(query: "Анна")
            print("Найдено пользователей: \(searchResults.count)")
            
        } catch {
            print("Ошибка: \(error)")
        }
    }
    
    // MARK: - Примеры работы с календарем
    static func calendarExamples() async {
        let repository = CalendarRepository()
        
        do {
            // Получение всех событий
            let events = try await repository.getAllEvents()
            print("Всего событий: \(events.count)")
            
            // Получение событий на сегодня
            let todayEvents = try await repository.getEvents(for: Date())
            print("Событий сегодня: \(todayEvents.count)")
            
            // Получение событий за неделю
            let weekEvents = try await repository.getWeekEvents()
            print("Событий за неделю: \(weekEvents.count)")
            
            // Создание нового события
            let newEvent = CalendarEvent(
                id: UUID(),
                title: "Новая встреча",
                date: Date().addingTimeInterval(3600), // Через час
                location: "Главный зал",
                description: "Важная встреча команды",
                color: .blue,
                clubName: "Клуб программистов"
            )
            try await repository.saveEvent(newEvent)
            print("Создано новое событие: \(newEvent.title)")
            
            // Поиск событий
            let searchResults = try await repository.searchEvents(query: "встреча")
            print("Найдено событий: \(searchResults.count)")
            
            // Получение предстоящих событий
            let upcomingEvents = try await repository.getUpcomingEvents(limit: 5)
            print("Предстоящих событий: \(upcomingEvents.count)")
            
        } catch {
            print("Ошибка: \(error)")
        }
    }
    
    // MARK: - Примеры интеграции с ViewModels
    static func viewModelIntegrationExamples() {
        // Пример для ClubsListViewModel
        class ClubsListViewModel: ObservableObject {
            @Published var clubs: [Club] = []
            @Published var isLoading = false
            @Published var errorMessage: String?
            
            private let repository: ClubRepository
            
            init(repository: ClubRepository = ClubRepository()) {
                self.repository = repository
            }
            
            @MainActor
            func loadClubs() async {
                isLoading = true
                errorMessage = nil
                
                do {
                    clubs = try await repository.getAllClubs()
                } catch {
                    errorMessage = error.localizedDescription
                }
                
                isLoading = false
            }
            
            @MainActor
            func joinClub(_ club: Club) async {
                do {
                    let updatedClub = try await repository.joinClub(club.id)
                    // Обновляем UI
                    if let index = clubs.firstIndex(where: { $0.id == club.id }) {
                        clubs[index] = updatedClub
                    }
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
        
        // Пример для UserProfileViewModel
        class UserProfileViewModel: ObservableObject {
            @Published var user: User?
            @Published var isLoading = false
            @Published var errorMessage: String?
            
            private let repository: UserRepository
            
            init(repository: UserRepository = UserRepository()) {
                self.repository = repository
            }
            
            @MainActor
            func loadProfile(userId: UUID) async {
                isLoading = true
                errorMessage = nil
                
                do {
                    user = try await repository.getUser(by: userId)
                } catch {
                    errorMessage = error.localizedDescription
                }
                
                isLoading = false
            }
            
            @MainActor
            func addInterest(_ interest: Interest) async {
                guard let userId = user?.id else { return }
                
                do {
                    try await repository.addInterest(interest, to: userId)
                    // Перезагружаем профиль для получения обновленных данных
                    await loadProfile(userId: userId)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
        
        // Пример для CalendarViewModel
        class CalendarViewModel: ObservableObject {
            @Published var events: [CalendarEvent] = []
            @Published var isLoading = false
            @Published var errorMessage: String?
            
            private let repository: CalendarRepository
            
            init(repository: CalendarRepository = CalendarRepository()) {
                self.repository = repository
            }
            
            @MainActor
            func loadEvents(for date: Date) async {
                isLoading = true
                errorMessage = nil
                
                do {
                    events = try await repository.getEvents(for: date)
                } catch {
                    errorMessage = error.localizedDescription
                }
                
                isLoading = false
            }
            
            @MainActor
            func createEvent(_ event: CalendarEvent) async {
                do {
                    try await repository.saveEvent(event)
                    // Перезагружаем события для текущей даты
                    await loadEvents(for: event.date)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Примеры обработки ошибок
    static func errorHandlingExamples() {
        // Создание кастомного обработчика ошибок
        class ErrorHandler {
            static func handle(_ error: Error, context: String) {
                switch error {
                case ApiError.networkError(let underlyingError):
                    print("Ошибка сети в \(context): \(underlyingError.localizedDescription)")
                case ApiError.unauthorized:
                    print("Пользователь не авторизован в \(context)")
                    // Показать экран авторизации
                case ApiError.serverError(let code):
                    print("Ошибка сервера \(code) в \(context)")
                case ApiError.decodingError:
                    print("Ошибка декодирования данных в \(context)")
                default:
                    print("Неизвестная ошибка в \(context): \(error.localizedDescription)")
                }
            }
        }
        
        // Использование в Repository
        func safeApiCall<T>(_ apiCall: () async throws -> T, context: String) async -> T? {
            do {
                return try await apiCall()
            } catch {
                ErrorHandler.handle(error, context: context)
                return nil
            }
        }
    }
    
    // MARK: - Примеры кэширования
    static func cachingExamples() {
        // Простой кэш для часто используемых данных
        class DataCache {
            static let shared = DataCache()
            private var cache: [String: Any] = [:]
            private let queue = DispatchQueue(label: "com.runtimehackathon.cache")
            
            func set<T>(_ value: T, for key: String) {
                queue.async {
                    self.cache[key] = value
                }
            }
            
            func get<T>(for key: String) -> T? {
                queue.sync {
                    return cache[key] as? T
                }
            }
            
            func clear() {
                queue.async {
                    self.cache.removeAll()
                }
            }
        }
        
        // Использование кэша в Repository
        class CachedClubRepository: ClubRepository {
            private let cache = DataCache.shared
            private let cacheKey = "clubs"
            
            override func getAllClubs() async throws -> [Club] {
                // Проверяем кэш
                if let cachedClubs: [Club] = cache.get(for: cacheKey) {
                    print("Возвращаем кэшированные клубы")
                    return cachedClubs
                }
                
                // Получаем из базы данных
                let clubs = try await super.getAllClubs()
                
                // Сохраняем в кэш
                cache.set(clubs, for: cacheKey)
                
                return clubs
            }
        }
    }
}

// MARK: - Запуск примеров
extension DataLayerExamples {
    static func runAllExamples() async {
        print("=== Примеры работы с архитектурой данных ===")
        
        await clubExamples()
        await userExamples()
        await calendarExamples()
        
        viewModelIntegrationExamples()
        errorHandlingExamples()
        cachingExamples()
        
        print("=== Примеры завершены ===")
    }
}
