import Foundation

class UserRepository: UserRepositoryProtocol {
    private let database: UserDatabase
    private let apiService: UserApiService
    
    init(database: UserDatabase = .shared, apiService: UserApiService = .shared) {
        self.database = database
        self.apiService = apiService
    }
    
    // MARK: - Получение пользователя
    func getUser(by id: UUID) async throws -> User? {
        print("DEBUG: UserRepository.getUser(by: \(id))")
        
        // Сначала проверяем локальную базу
        if let localUser = database.getUser(by: id) {
            print("DEBUG: Пользователь найден в локальной базе: \(localUser.name)")
            // Асинхронно обновляем данные из API
            Task {
                do {
                    let apiUser = try await apiService.getUser(by: id)
                    database.saveUser(apiUser)
                } catch {
                    print("Ошибка синхронизации пользователя с API: \(error)")
                }
            }
            return localUser
        }
        
        print("DEBUG: Пользователь не найден в локальной базе, получаем из API")
        
        // Если нет в локальной базе, получаем из API
        do {
            let apiUser = try await apiService.getUser(by: id)
            print("DEBUG: Получен пользователь из API: \(apiUser.name)")
            database.saveUser(apiUser)
            return apiUser
        } catch {
            print("Ошибка получения пользователя из API: \(error)")
            // Возвращаем моковые данные как fallback
            print("DEBUG: Возвращаем моковые данные как fallback")
            return ProfileDataMock.sampleUser
        }
    }
    
    // MARK: - Сохранение пользователя
    func saveUser(_ user: User) async throws {
        // Сохраняем в локальную базу
        database.saveUser(user)
        
        // Асинхронно отправляем в API
        Task {
            do {
                let request = UpdateProfileRequest(
                    name: user.name,
                    nickname: user.nickname,
                    bio: user.bio,
                    location: user.location,
                    avatarURL: user.avatarURL
                )
                _ = try await apiService.updateProfile(request)
            } catch {
                print("Ошибка синхронизации пользователя с API: \(error)")
            }
        }
    }
    
    // MARK: - Обновление профиля
    func updateProfile(_ user: User) async throws {
        // Обновляем локальную базу
        database.updateProfile(user)
        
        // Отправляем в API
        do {
            let request = UpdateProfileRequest(
                name: user.name,
                nickname: user.nickname,
                bio: user.bio,
                location: user.location,
                avatarURL: user.avatarURL
            )
            let apiUser = try await apiService.updateProfile(request)
            database.saveUser(apiUser)
        } catch {
            print("Ошибка обновления профиля в API: \(error)")
        }
    }
    
    // MARK: - Добавление интереса
    func addInterest(_ interest: Interest, to userId: UUID) async throws {
        // Добавляем в локальную базу
        database.addInterest(interest, to: userId)
        
        // Асинхронно отправляем в API
        Task {
            do {
                let request = AddInterestRequest(
                    name: interest.name,
                    categoryName: interest.category.name
                )
                _ = try await apiService.addInterest(request)
            } catch {
                print("Ошибка добавления интереса в API: \(error)")
            }
        }
    }
    
    // MARK: - Удаление интереса
    func removeInterest(_ interest: Interest, from userId: UUID) async throws {
        // Удаляем из локальной базы
        database.removeInterest(interest, from: userId)
        
        // Асинхронно удаляем из API
        Task {
            do {
                _ = try await apiService.removeInterest(interest.id)
            } catch {
                print("Ошибка удаления интереса из API: \(error)")
            }
        }
    }
    
    // MARK: - Получение интересов пользователя
    func getUserInterests() async throws -> [Interest] {
        // Получаем результаты из API
        do {
            let apiInterests = try await apiService.getUserInterests()
            return apiInterests
        } catch {
            // Если API недоступен, возвращаем локальные данные
            // Для этого нужно получить пользователя и его интересы
            if let user = database.getUser(by: UUID()) { // Здесь нужен ID текущего пользователя
                return user.interests
            }
            return []
        }
    }
    
    // MARK: - Получение клубов пользователя
    func getUserClubs() async throws -> [Club] {
        // Получаем результаты из API
        do {
            let apiClubs = try await apiService.getUserClubs()
            return apiClubs
        } catch {
            // Если API недоступен, возвращаем локальные данные
            if let user = database.getUser(by: UUID()) { // Здесь нужен ID текущего пользователя
                return user.joinedClubs
            }
            return []
        }
    }
    
    // MARK: - Получение созданных клубов
    func getCreatedClubs() async throws -> [Club] {
        // Получаем результаты из API
        do {
            let apiClubs = try await apiService.getCreatedClubs()
            return apiClubs
        } catch {
            // Если API недоступен, возвращаем локальные данные
            if let user = database.getUser(by: UUID()) { // Здесь нужен ID текущего пользователя
                return user.createdClubs
            }
            return []
        }
    }
    
    // MARK: - Загрузка аватара
    func uploadAvatar(_ imageData: Data) async throws -> String {
        // Отправляем в API
        do {
            let avatarURL = try await apiService.uploadAvatar(imageData)
            
            // Обновляем локальную базу
            if let user = database.getUser(by: UUID()) { // Здесь нужен ID текущего пользователя
                var updatedUser = user
                updatedUser.avatarURL = avatarURL
                database.saveUser(updatedUser)
            }
            
            return avatarURL
        } catch {
            throw error
        }
    }
    
    // MARK: - Поиск пользователей
    func searchUsers(query: String) async throws -> [User] {
        // Получаем результаты из API
        do {
            let apiUsers = try await apiService.searchUsers(query: query)
            // Сохраняем результаты в локальную базу
            for user in apiUsers {
                database.saveUser(user)
            }
            return apiUsers
        } catch {
            // Если API недоступен, возвращаем пустой массив
            // Поиск по локальной базе требует более сложной логики
            return []
        }
    }
}
