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
        // Моковая реализация - возвращаем данные из ProfileDataMock
        return ProfileDataMock.sampleUser
    }
    
    // MARK: - Обновление профиля
    func updateProfile(_ request: UpdateProfileRequest) async throws -> User {
        // Моковая реализация - возвращаем обновленные данные
        var user = ProfileDataMock.sampleUser
        if let name = request.name {
            user.name = name
        }
        if let nickname = request.nickname {
            user.nickname = nickname
        }
        if let bio = request.bio {
            user.bio = bio
        }
        if let location = request.location {
            user.location = location
        }
        return user
    }
    
    // MARK: - Добавление интереса
    func addInterest(_ request: AddInterestRequest) async throws -> User {
        // Моковая реализация - добавляем интерес к пользователю
        var user = ProfileDataMock.sampleUser
        let newInterest = Interest(
            name: request.name,
            category: InterestCategory(name: request.categoryName, emoji: "📚", displayName: request.categoryName)
        )
        user.interests.append(newInterest)
        return user
    }
    
    // MARK: - Удаление интереса
    func removeInterest(_ interestId: UUID) async throws -> User {
        // Моковая реализация - удаляем интерес из пользователя
        var user = ProfileDataMock.sampleUser
        user.interests.removeAll { $0.id == interestId }
        return user
    }
    
    // MARK: - Получение интересов пользователя
    func getUserInterests() async throws -> [Interest] {
        // Моковая реализация - возвращаем интересы из ProfileDataMock
        return ProfileDataMock.sampleUser.interests
    }
    
    // MARK: - Получение клубов пользователя
    func getUserClubs() async throws -> [Club] {
        // Моковая реализация - возвращаем клубы из ProfileDataMock
        return ProfileDataMock.sampleUser.joinedClubs
    }
    
    // MARK: - Получение созданных клубов
    func getCreatedClubs() async throws -> [Club] {
        // Моковая реализация - возвращаем созданные клубы из ProfileDataMock
        return ProfileDataMock.sampleUser.createdClubs
    }
    
    // MARK: - Загрузка аватара
    func uploadAvatar(_ imageData: Data) async throws -> String {
        // Здесь должна быть реализация загрузки файла
        // Для простоты возвращаем заглушку
        return "https://api.runtimehackathon.com/avatars/user_\(UUID().uuidString).jpg"
    }
    
    // MARK: - Получение пользователя по ID
    func getUser(by id: UUID) async throws -> User {
        // Моковая реализация - возвращаем данные из ProfileDataMock
        var user = ProfileDataMock.sampleUser
        user.id = id // Используем переданный ID
        return user
    }
    
    // MARK: - Поиск пользователей
    func searchUsers(query: String) async throws -> [User] {
        // Моковая реализация - возвращаем пустой массив
        return []
    }
}

// MARK: - Дополнительные структуры
struct UsersApiResponse: Codable {
    let success: Bool
    let data: [UserApiModel]
    let message: String?
}
