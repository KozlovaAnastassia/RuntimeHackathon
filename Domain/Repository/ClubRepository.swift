import Foundation

class ClubRepository: ClubRepositoryProtocol {
    private let database: ClubDatabase
    private let apiService: ClubApiService
    
    init(database: ClubDatabase = .shared, apiService: ClubApiService = .shared) {
        self.database = database
        self.apiService = apiService
    }
    
    // MARK: - Получение всех клубов
    func getAllClubs() async throws -> [Club] {
        // Сначала получаем данные из базы данных
        let localClubs = database.getAllClubs()
        
        // Асинхронно обновляем данные из API
        Task {
            do {
                let apiClubs = try await apiService.getAllClubs()
                // Сохраняем новые данные в базу
                for club in apiClubs {
                    database.saveClub(club)
                }
            } catch {
                print("Ошибка синхронизации клубов с API: \(error)")
            }
        }
        
        return localClubs
    }
    
    // MARK: - Получение клуба по ID
    func getClub(by id: UUID) async throws -> Club? {
        // Сначала проверяем локальную базу
        if let localClub = database.getClub(by: id) {
            // Асинхронно обновляем данные из API
            Task {
                do {
                    let apiClub = try await apiService.getClub(by: id)
                    database.saveClub(apiClub)
                } catch {
                    print("Ошибка синхронизации клуба с API: \(error)")
                }
            }
            return localClub
        }
        
        // Если нет в локальной базе, получаем из API
        do {
            let apiClub = try await apiService.getClub(by: id)
            database.saveClub(apiClub)
            return apiClub
        } catch {
            return nil
        }
    }
    
    // MARK: - Сохранение клуба
    func saveClub(_ club: Club) async throws {
        // Сохраняем в локальную базу
        database.saveClub(club)
        
        // Асинхронно отправляем в API
        Task {
            do {
                if let existingClub = database.getClub(by: club.id) {
                    // Обновляем существующий клуб
                    let request = UpdateClubRequest(
                        name: club.name,
                        imageName: club.imageName,
                        description: club.description,
                        tags: club.tags
                    )
                    _ = try await apiService.updateClub(club.id, with: request)
                } else {
                    // Создаем новый клуб
                    let request = CreateClubRequest(
                        name: club.name,
                        imageName: club.imageName,
                        description: club.description,
                        tags: club.tags
                    )
                    _ = try await apiService.createClub(request)
                }
            } catch {
                print("Ошибка синхронизации клуба с API: \(error)")
            }
        }
    }
    
    // MARK: - Удаление клуба
    func deleteClub(_ club: Club) async throws {
        // Удаляем из локальной базы
        database.deleteClub(club)
        
        // Асинхронно удаляем из API
        Task {
            do {
                try await apiService.deleteClub(club.id)
            } catch {
                print("Ошибка удаления клуба из API: \(error)")
            }
        }
    }
    
    // MARK: - Обновление статуса участия
    func updateJoinStatus(for clubId: UUID, isJoined: Bool) async throws {
        // Обновляем в локальной базе
        database.updateJoinStatus(for: clubId, isJoined: isJoined)
        
        // Асинхронно обновляем в API
        Task {
            do {
                if isJoined {
                    _ = try await apiService.joinClub(clubId)
                } else {
                    _ = try await apiService.leaveClub(clubId)
                }
            } catch {
                print("Ошибка обновления статуса участия в API: \(error)")
            }
        }
    }
    
    // MARK: - Присоединение к клубу
    func joinClub(_ id: UUID) async throws -> Club {
        // Обновляем локальную базу
        database.updateJoinStatus(for: id, isJoined: true)
        
        // Получаем обновленные данные из API
        do {
            let apiClub = try await apiService.joinClub(id)
            database.saveClub(apiClub)
            return apiClub
        } catch {
            // Если API недоступен, возвращаем локальные данные
            if let localClub = database.getClub(by: id) {
                return localClub
            }
            throw error
        }
    }
    
    // MARK: - Выход из клуба
    func leaveClub(_ id: UUID) async throws -> Club {
        // Обновляем локальную базу
        database.updateJoinStatus(for: id, isJoined: false)
        
        // Получаем обновленные данные из API
        do {
            let apiClub = try await apiService.leaveClub(id)
            database.saveClub(apiClub)
            return apiClub
        } catch {
            // Если API недоступен, возвращаем локальные данные
            if let localClub = database.getClub(by: id) {
                return localClub
            }
            throw error
        }
    }
    
    // MARK: - Поиск клубов
    func searchClubs(query: String) async throws -> [Club] {
        // Получаем результаты из API
        do {
            let apiClubs = try await apiService.searchClubs(query: query)
            // Сохраняем результаты в локальную базу
            for club in apiClubs {
                database.saveClub(club)
            }
            return apiClubs
        } catch {
            // Если API недоступен, ищем в локальной базе
            let localClubs = database.getAllClubs()
            return localClubs.filter { club in
                club.name.localizedCaseInsensitiveContains(query) ||
                club.description.localizedCaseInsensitiveContains(query) ||
                club.tags.contains { $0.localizedCaseInsensitiveContains(query) }
            }
        }
    }
    
    // MARK: - Получение клубов по категории
    func getClubsByCategory(_ category: String) async throws -> [Club] {
        // Получаем результаты из API
        do {
            let apiClubs = try await apiService.getClubsByCategory(category)
            // Сохраняем результаты в локальную базу
            for club in apiClubs {
                database.saveClub(club)
            }
            return apiClubs
        } catch {
            // Если API недоступен, фильтруем локальные данные
            let localClubs = database.getAllClubs()
            return localClubs.filter { club in
                club.tags.contains(category)
            }
        }
    }
    
    // MARK: - Получение клубов пользователя
    func getUserClubs() async throws -> [Club] {
        // Получаем результаты из API
        do {
            let apiClubs = try await apiService.getUserClubs()
            // Сохраняем результаты в локальную базу
            for club in apiClubs {
                database.saveClub(club)
            }
            return apiClubs
        } catch {
            // Если API недоступен, возвращаем локальные данные
            let localClubs = database.getAllClubs()
            return localClubs.filter { $0.isJoined }
        }
    }
    
    // MARK: - Получение созданных клубов
    func getCreatedClubs() async throws -> [Club] {
        // Получаем результаты из API
        do {
            let apiClubs = try await apiService.getCreatedClubs()
            // Сохраняем результаты в локальную базу
            for club in apiClubs {
                database.saveClub(club)
            }
            return apiClubs
        } catch {
            // Если API недоступен, возвращаем локальные данные
            let localClubs = database.getAllClubs()
            return localClubs.filter { $0.isCreator }
        }
    }
}
