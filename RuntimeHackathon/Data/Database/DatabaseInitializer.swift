import Foundation
import CoreData

class DatabaseInitializer {
    static let shared = DatabaseInitializer()
    
    private init() {}
    
    // MARK: - Инициализация базы данных
    func initializeDatabase() {
        print("DEBUG: Инициализация базы данных")
        // Инициализируем Core Data
        _ = DatabaseManager.shared.persistentContainer
        
        // Загружаем начальные данные если база пустая
        loadInitialDataIfNeeded()
        print("DEBUG: База данных инициализирована")
    }
    
    // MARK: - Загрузка начальных данных
    private func loadInitialDataIfNeeded() {
        print("DEBUG: Проверяем необходимость загрузки начальных данных")
        let clubDatabase = ClubDatabase.shared
        let userDatabase = UserDatabase.shared
        let calendarDatabase = CalendarDatabase.shared
        
        // Проверяем, есть ли данные в базе
        let existingClubs = clubDatabase.getAllClubs()
        let existingUsers = userDatabase.getAllUsers()
        
        print("DEBUG: Найдено клубов: \(existingClubs.count), пользователей: \(existingUsers.count)")
        
        if existingClubs.isEmpty {
            print("DEBUG: База пустая, загружаем моковые данные")
            loadMockData()
        } else {
            print("DEBUG: База не пустая, моковые данные уже загружены")
        }
    }
    
    // MARK: - Загрузка моковых данных
    private func loadMockData() {
        print("Загружаем моковые данные в базу...")
        
        // Загружаем клубы
        loadMockClubs()
        
        // Загружаем пользователей
        loadMockUsers()
        
        // Загружаем события
        loadMockEvents()
        
        print("Моковые данные загружены")
    }
    
    private func loadMockClubs() {
        let clubDatabase = ClubDatabase.shared
        
        // Загружаем клубы из моковых данных
        let mockClubs = ClubDataMock.sampleClubs
        for club in mockClubs {
            clubDatabase.saveClub(club)
        }
        
        // Загружаем события клубов
        let mockEvents = ClubDataMock.sampleClubEvents
        for event in mockEvents {
            let calendarEvent = CalendarEvent(
                id: UUID(),
                title: event.title,
                date: event.date,
                location: event.location,
                description: event.description,
                color: .blue,
                clubName: "Клуб программистов"
            )
            CalendarDatabase.shared.saveEvent(calendarEvent)
        }
    }
    
    private func loadMockUsers() {
        print("DEBUG: Загружаем моковых пользователей")
        let userDatabase = UserDatabase.shared
        
        // Загружаем пользователя из моковых данных
        let mockUser = ProfileDataMock.sampleUser
        print("DEBUG: Сохраняем пользователя: \(mockUser.name) с ID: \(mockUser.id)")
        userDatabase.saveUser(mockUser)
        
        // Загружаем интересы
        let mockInterests = ProfileDataMock.sampleManyInterests
        for interest in mockInterests {
            userDatabase.addInterest(interest, to: mockUser.id)
        }
        print("DEBUG: Моковые пользователи загружены")
    }
    
    private func loadMockEvents() {
        let calendarDatabase = CalendarDatabase.shared
        
        // Загружаем события из моковых данных
        let mockEvents = CalendarDataMock.generateSampleEvents()
        for event in mockEvents {
            calendarDatabase.saveEvent(event)
        }
        
        // Загружаем события на выходные
        let weekendEvents = CalendarDataMock.generateWeekendEvents()
        for event in weekendEvents {
            calendarDatabase.saveEvent(event)
        }
        
        // Загружаем рабочие события
        let workdayEvents = CalendarDataMock.generateWorkdayEvents()
        for event in workdayEvents {
            calendarDatabase.saveEvent(event)
        }
    }
    
    // MARK: - Очистка базы данных
    func clearDatabase() {
        DatabaseManager.shared.deleteAllData()
        print("База данных очищена")
    }
    
    // MARK: - Экспорт данных
    func exportDatabase() -> Data? {
        let context = DatabaseManager.shared.context
        
        do {
            let fetchRequest: NSFetchRequest<ClubEntity> = ClubEntity.fetchRequest()
            let clubEntities = try context.fetch(fetchRequest)
            
            // Конвертируем в модели Club
            let clubs = clubEntities.compactMap { entity -> Club? in
                // Здесь нужно создать Club из ClubEntity
                // Для простоты возвращаем nil
                return nil
            }
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            return try encoder.encode(clubs)
        } catch {
            print("Ошибка экспорта данных: \(error)")
            return nil
        }
    }
    
    // MARK: - Импорт данных
    func importDatabase(from data: Data) {
        do {
            let decoder = JSONDecoder()
            let clubs = try decoder.decode([Club].self, from: data)
            
            let clubDatabase = ClubDatabase.shared
            for club in clubs {
                clubDatabase.saveClub(club)
            }
            
            print("Данные импортированы: \(clubs.count) клубов")
        } catch {
            print("Ошибка импорта данных: \(error)")
        }
    }
    
    // MARK: - Статистика базы данных
    func getDatabaseStatistics() -> DatabaseStatistics {
        let context = DatabaseManager.shared.context
        
        var statistics = DatabaseStatistics()
        
        do {
            // Подсчет клубов
            let clubFetchRequest: NSFetchRequest<ClubEntity> = ClubEntity.fetchRequest()
            statistics.clubsCount = try context.count(for: clubFetchRequest)
            
            // Подсчет пользователей
            let userFetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            statistics.usersCount = try context.count(for: userFetchRequest)
            
            // Подсчет событий
            let eventFetchRequest: NSFetchRequest<CalendarEventEntity> = CalendarEventEntity.fetchRequest()
            statistics.eventsCount = try context.count(for: eventFetchRequest)
            
            // Подсчет чатов
            let chatFetchRequest: NSFetchRequest<ChatEntity> = ChatEntity.fetchRequest()
            statistics.chatsCount = try context.count(for: chatFetchRequest)
            
            // Подсчет сообщений
            let messageFetchRequest: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
            statistics.messagesCount = try context.count(for: messageFetchRequest)
            
        } catch {
            print("Ошибка получения статистики: \(error)")
        }
        
        return statistics
    }
}

// MARK: - Структура статистики
struct DatabaseStatistics {
    var clubsCount: Int = 0
    var usersCount: Int = 0
    var eventsCount: Int = 0
    var chatsCount: Int = 0
    var messagesCount: Int = 0
    
    var totalRecords: Int {
        return clubsCount + usersCount + eventsCount + chatsCount + messagesCount
    }
    
    var description: String {
        return """
        Статистика базы данных:
        - Клубов: \(clubsCount)
        - Пользователей: \(usersCount)
        - Событий: \(eventsCount)
        - Чатов: \(chatsCount)
        - Сообщений: \(messagesCount)
        - Всего записей: \(totalRecords)
        """
    }
}
