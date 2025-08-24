import Foundation

// MARK: - Основные протоколы для Repository
protocol RepositoryProtocol {
    associatedtype Entity
    associatedtype ApiService
    
    var database: Any { get }
    var apiService: ApiService { get }
}

// MARK: - Протокол для клубов
protocol ClubRepositoryProtocol {
    func getAllClubs() async throws -> [Club]
    func getClub(by id: UUID) async throws -> Club?
    func saveClub(_ club: Club) async throws
    func deleteClub(_ club: Club) async throws
    func updateJoinStatus(for clubId: UUID, isJoined: Bool) async throws
    func joinClub(_ id: UUID) async throws -> Club
    func leaveClub(_ id: UUID) async throws -> Club
    func searchClubs(query: String) async throws -> [Club]
    func getClubsByCategory(_ category: String) async throws -> [Club]
    func getUserClubs() async throws -> [Club]
    func getCreatedClubs() async throws -> [Club]
}

// MARK: - Протокол для пользователей
protocol UserRepositoryProtocol {
    func getUser(by id: UUID) async throws -> User?
    func saveUser(_ user: User) async throws
    func updateProfile(_ user: User) async throws
    func addInterest(_ interest: Interest, to userId: UUID) async throws
    func removeInterest(_ interest: Interest, from userId: UUID) async throws
    func getUserInterests() async throws -> [Interest]
    func getUserClubs() async throws -> [Club]
    func getCreatedClubs() async throws -> [Club]
    func uploadAvatar(_ imageData: Data) async throws -> String
    func searchUsers(query: String) async throws -> [User]
}

// MARK: - Протокол для календарных событий
protocol CalendarRepositoryProtocol {
    func getAllEvents() async throws -> [CalendarEvent]
    func getEvent(by id: UUID) async throws -> CalendarEvent?
    func saveEvent(_ event: CalendarEvent) async throws
    func deleteEvent(_ event: CalendarEvent) async throws
    func getEvents(for date: Date) async throws -> [CalendarEvent]
    func getEvents(from startDate: Date, to endDate: Date) async throws -> [CalendarEvent]
    func getClubEvents(for clubName: String) async throws -> [CalendarEvent]
    func getUserEvents() async throws -> [CalendarEvent]
    func searchEvents(query: String) async throws -> [CalendarEvent]
    func getEventsByCategory(_ category: String) async throws -> [CalendarEvent]
    func getUpcomingEvents(limit: Int) async throws -> [CalendarEvent]
    func getWeekEvents() async throws -> [CalendarEvent]
    func getMonthEvents() async throws -> [CalendarEvent]
}

// MARK: - Протокол для чатов
protocol ChatRepositoryProtocol {
    func getChats() async throws -> [ChatInfo]
    func getChat(by id: String) async throws -> ChatInfo?
    func saveChat(_ chat: ChatInfo) async throws
    func deleteChat(_ chat: ChatInfo) async throws
    func getMessages(for chatId: String) async throws -> [ChatMessage]
    func sendMessage(_ message: ChatMessage, to chatId: String) async throws
    func markAsRead(chatId: String) async throws
    func getUnreadCount(for chatId: String) async throws -> Int
}
