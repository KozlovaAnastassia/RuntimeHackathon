import Foundation

// MARK: - API модели для клубов
struct ClubApiResponse: Codable {
    let success: Bool
    let data: [ClubApiModel]
    let message: String?
}

struct ClubApiModel: Codable {
    let id: String
    let name: String
    let imageName: String
    let isJoined: Bool
    let localImagePath: String?
    let description: String
    let tags: [String]
    let isCreator: Bool
    let chat: ChatInfoApiModel
    let createdAt: String
    let updatedAt: String
    
    func toClub() -> Club {
        return Club(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            imageName: imageName,
            isJoined: isJoined,
            localImagePath: localImagePath,
            description: description,
            tags: tags,
            isCreator: isCreator,
            chat: chat.toChatInfo()
        )
    }
}

struct ChatInfoApiModel: Codable {
    let chatId: String
    let title: String
    let unreadCount: Int
    let membersCount: Int
    let isOnline: Bool
    let avatarColor: String
    let messages: [ChatMessageApiModel]
    
    func toChatInfo() -> ChatInfo {
        return ChatInfo(
            chatId: chatId,
            title: title,
            unreadCount: unreadCount,
            membersCount: membersCount,
            isOnline: isOnline,
            avatarColor: avatarColor,
            messages: messages.map { $0.toChatMessage() }
        )
    }
}

struct ChatMessageApiModel: Codable {
    let userId: String
    let userName: String
    let text: String
    let timestamp: String
    let isCurrentUser: Bool
    
    func toChatMessage() -> ChatMessage {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = formatter.date(from: timestamp) ?? Date()
        
        return ChatMessage(
            userId: userId,
            userName: userName,
            text: text,
            timestamp: date,
            isCurrentUser: isCurrentUser
        )
    }
}

struct CreateClubRequest: Codable {
    let name: String
    let imageName: String
    let description: String
    let tags: [String]
}

struct UpdateClubRequest: Codable {
    let name: String?
    let imageName: String?
    let description: String?
    let tags: [String]?
}

struct JoinClubRequest: Codable {
    let clubId: String
}

// MARK: - API сервис для клубов
class ClubApiService {
    static let shared = ClubApiService()
    private let apiClient = ApiClient.shared
    
    private init() {}
    
    // MARK: - Получение всех клубов
    func getAllClubs() async throws -> [Club] {
        let response: ClubApiResponse = try await apiClient.get("/clubs")
        return response.data.map { $0.toClub() }
    }
    
    // MARK: - Получение клуба по ID
    func getClub(by id: UUID) async throws -> Club {
        let response: ClubApiResponse = try await apiClient.get("/clubs/\(id.uuidString)")
        guard let clubData = response.data.first else {
            throw ApiError.notFound
        }
        return clubData.toClub()
    }
    
    // MARK: - Создание клуба
    func createClub(_ request: CreateClubRequest) async throws -> Club {
        let response: ClubApiResponse = try await apiClient.post("/clubs", body: request)
        guard let clubData = response.data.first else {
            throw ApiError.decodingError
        }
        return clubData.toClub()
    }
    
    // MARK: - Обновление клуба
    func updateClub(_ id: UUID, with request: UpdateClubRequest) async throws -> Club {
        let response: ClubApiResponse = try await apiClient.put("/clubs/\(id.uuidString)", body: request)
        guard let clubData = response.data.first else {
            throw ApiError.decodingError
        }
        return clubData.toClub()
    }
    
    // MARK: - Удаление клуба
    func deleteClub(_ id: UUID) async throws {
        try await apiClient.delete("/clubs/\(id.uuidString)")
    }
    
    // MARK: - Присоединение к клубу
    func joinClub(_ id: UUID) async throws -> Club {
        let request = JoinClubRequest(clubId: id.uuidString)
        let response: ClubApiResponse = try await apiClient.post("/clubs/\(id.uuidString)/join", body: request)
        guard let clubData = response.data.first else {
            throw ApiError.decodingError
        }
        return clubData.toClub()
    }
    
    // MARK: - Выход из клуба
    func leaveClub(_ id: UUID) async throws -> Club {
        let response: ClubApiResponse = try await apiClient.post("/clubs/\(id.uuidString)/leave", body: EmptyRequest())
        guard let clubData = response.data.first else {
            throw ApiError.decodingError
        }
        return clubData.toClub()
    }
    
    // MARK: - Получение клубов пользователя
    func getUserClubs() async throws -> [Club] {
        let response: ClubApiResponse = try await apiClient.get("/user/clubs")
        return response.data.map { $0.toClub() }
    }
    
    // MARK: - Получение созданных клубов
    func getCreatedClubs() async throws -> [Club] {
        let response: ClubApiResponse = try await apiClient.get("/user/clubs/created")
        return response.data.map { $0.toClub() }
    }
    
    // MARK: - Поиск клубов
    func searchClubs(query: String) async throws -> [Club] {
        let parameters = ["q": query]
        let response: ClubApiResponse = try await apiClient.get("/clubs/search", parameters: parameters)
        return response.data.map { $0.toClub() }
    }
    
    // MARK: - Получение клубов по категории
    func getClubsByCategory(_ category: String) async throws -> [Club] {
        let parameters = ["category": category]
        let response: ClubApiResponse = try await apiClient.get("/clubs/category", parameters: parameters)
        return response.data.map { $0.toClub() }
    }
}

// MARK: - Вспомогательные структуры
struct EmptyRequest: Codable {}
