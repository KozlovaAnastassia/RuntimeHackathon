import Foundation

// MARK: - API модели для пользователей
struct UserApiResponse: Codable {
    let success: Bool
    let data: UserApiModel
    let message: String?
}

struct UserApiModel: Codable {
    let id: String
    let name: String
    let nickname: String
    let email: String
    let bio: String?
    let avatarURL: String?
    let interests: [InterestApiModel]
    let joinedClubs: [ClubApiModel]
    let createdClubs: [ClubApiModel]
    let location: String?
    let joinDate: String
    let createdAt: String
    let updatedAt: String
    
    func toUser() -> User {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let joinDate = formatter.date(from: self.joinDate) ?? Date()
        
        return User(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            nickname: nickname,
            email: email,
            bio: bio,
            avatarURL: avatarURL,
            interests: interests.map { $0.toInterest() },
            joinedClubs: joinedClubs.map { $0.toClub() },
            createdClubs: createdClubs.map { $0.toClub() },
            location: location,
            joinDate: joinDate
        )
    }
}

struct InterestApiModel: Codable {
    let id: String
    let name: String
    let category: InterestCategoryApiModel
    
    func toInterest() -> Interest {
        return Interest(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            category: category.toInterestCategory()
        )
    }
}

struct InterestCategoryApiModel: Codable {
    let name: String
    let emoji: String
    let displayName: String
    
    func toInterestCategory() -> InterestCategory {
        return InterestCategory(
            name: name,
            emoji: emoji,
            displayName: displayName
        )
    }
}

struct UpdateProfileRequest: Codable {
    let name: String?
    let nickname: String?
    let bio: String?
    let location: String?
    let avatarURL: String?
}

struct AddInterestRequest: Codable {
    let name: String
    let categoryName: String
}

struct RemoveInterestRequest: Codable {
    let interestId: String
}

// MARK: - API сервис для пользователей
class UserApiService {
    static let shared = UserApiService()
    private let apiClient = ApiClient.shared
    
    private init() {}
    
    // MARK: - Получение профиля пользователя
    func getProfile() async throws -> User {
        let response: UserApiResponse = try await apiClient.get("/user/profile")
        return response.data.toUser()
    }
    
    // MARK: - Обновление профиля
    func updateProfile(_ request: UpdateProfileRequest) async throws -> User {
        let response: UserApiResponse = try await apiClient.put("/user/profile", body: request)
        return response.data.toUser()
    }
    
    // MARK: - Добавление интереса
    func addInterest(_ request: AddInterestRequest) async throws -> User {
        let response: UserApiResponse = try await apiClient.post("/user/interests", body: request)
        return response.data.toUser()
    }
    
    // MARK: - Удаление интереса
    func removeInterest(_ interestId: UUID) async throws -> User {
        let request = RemoveInterestRequest(interestId: interestId.uuidString)
        _ = try await apiClient.delete("/user/interests/\(interestId.uuidString)")
        // После удаления получаем обновленный профиль
        return try await getProfile()
    }
    
    // MARK: - Получение интересов пользователя
    func getUserInterests() async throws -> [Interest] {
        let response: UserApiResponse = try await apiClient.get("/user/interests")
        return response.data.interests.map { $0.toInterest() }
    }
    
    // MARK: - Получение клубов пользователя
    func getUserClubs() async throws -> [Club] {
        let response: UserApiResponse = try await apiClient.get("/user/clubs")
        return response.data.joinedClubs.map { $0.toClub() }
    }
    
    // MARK: - Получение созданных клубов
    func getCreatedClubs() async throws -> [Club] {
        let response: UserApiResponse = try await apiClient.get("/user/clubs/created")
        return response.data.createdClubs.map { $0.toClub() }
    }
    
    // MARK: - Загрузка аватара
    func uploadAvatar(_ imageData: Data) async throws -> String {
        // Здесь должна быть реализация загрузки файла
        // Для простоты возвращаем заглушку
        return "https://api.runtimehackathon.com/avatars/user_\(UUID().uuidString).jpg"
    }
    
    // MARK: - Получение пользователя по ID
    func getUser(by id: UUID) async throws -> User {
        let response: UserApiResponse = try await apiClient.get("/users/\(id.uuidString)")
        return response.data.toUser()
    }
    
    // MARK: - Поиск пользователей
    func searchUsers(query: String) async throws -> [User] {
        let parameters = ["q": query]
        let response: UsersApiResponse = try await apiClient.get("/users/search", parameters: parameters)
        return response.data.map { $0.toUser() }
    }
}

// MARK: - Дополнительные структуры
struct UsersApiResponse: Codable {
    let success: Bool
    let data: [UserApiModel]
    let message: String?
}
