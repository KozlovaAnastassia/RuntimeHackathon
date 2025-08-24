import Foundation
import CoreData

class UserDatabase {
    static let shared = UserDatabase()
    private let databaseManager = DatabaseManager.shared
    
    private init() {}
    
    // MARK: - Сохранение пользователя
    func saveUser(_ user: User) {
        let context = databaseManager.context
        
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", user.id.uuidString)
        
        do {
            let existingUsers = try context.fetch(fetchRequest)
            let userEntity: UserEntity
            
            if let existingUser = existingUsers.first {
                userEntity = existingUser
            } else {
                userEntity = UserEntity(context: context)
                userEntity.id = user.id.uuidString
            }
            
            userEntity.name = user.name
            userEntity.nickname = user.nickname
            userEntity.email = user.email
            userEntity.bio = user.bio
            userEntity.avatarURL = user.avatarURL
            userEntity.location = user.location
            userEntity.joinDate = user.joinDate
            userEntity.updatedAt = Date()
            
            // Сохраняем интересы
            user.interests.forEach { interest in
                _ = saveInterest(interest, to: userEntity)
            }
            
            // Сохраняем связанные клубы
            user.joinedClubs.forEach { club in
                _ = saveJoinedClub(club, to: userEntity)
            }
            
            user.createdClubs.forEach { club in
                _ = saveCreatedClub(club, to: userEntity)
            }
            
            databaseManager.saveContext()
        } catch {
            print("Ошибка сохранения пользователя: \(error)")
        }
    }
    
    // MARK: - Получение пользователя
    func getUser(by id: UUID) -> User? {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id.uuidString)
        fetchRequest.fetchLimit = 1
        
        do {
            let userEntities = try context.fetch(fetchRequest)
            guard let entity = userEntities.first,
                  let idString = entity.id,
                  let userId = UUID(uuidString: idString),
                  let name = entity.name,
                  let nickname = entity.nickname,
                  let email = entity.email,
                  let joinDate = entity.joinDate else {
                return nil
            }
            
            let interests: [Interest] = entity.interests?.allObjects.compactMap { interestEntity in
                guard let interestEntity = interestEntity as? InterestEntity else { return nil }
                return Interest(from: interestEntity)
            } ?? []
            
            let joinedClubs: [Club] = entity.joinedClubs?.allObjects.compactMap { clubEntity in
                guard let clubEntity = clubEntity as? UserClubEntity else { return nil }
                return Club(from: clubEntity)
            } ?? []
            
            let createdClubs: [Club] = entity.createdClubs?.allObjects.compactMap { clubEntity in
                guard let clubEntity = clubEntity as? UserClubEntity else { return nil }
                return Club(from: clubEntity)
            } ?? []
            
            return User(
                id: userId,
                name: name,
                nickname: nickname,
                email: email,
                bio: entity.bio,
                avatarURL: entity.avatarURL,
                interests: interests,
                joinedClubs: joinedClubs,
                createdClubs: createdClubs,
                location: entity.location,
                joinDate: joinDate
            )
        } catch {
            print("Ошибка получения пользователя: \(error)")
            return nil
        }
    }
    
    // MARK: - Обновление профиля
    func updateProfile(_ user: User) {
        saveUser(user)
    }
    
    // MARK: - Добавление интереса
    func addInterest(_ interest: Interest, to userId: UUID) {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", userId.uuidString)
        
        do {
            let userEntities = try context.fetch(fetchRequest)
            if let userEntity = userEntities.first {
                _ = saveInterest(interest, to: userEntity)
                databaseManager.saveContext()
            }
        } catch {
            print("Ошибка добавления интереса: \(error)")
        }
    }
    
    // MARK: - Удаление интереса
    func removeInterest(_ interest: Interest, from userId: UUID) {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<InterestEntity> = InterestEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user.id == %@ AND name == %@", userId.uuidString, interest.name)
        
        do {
            let interestEntities = try context.fetch(fetchRequest)
            interestEntities.forEach { context.delete($0) }
            databaseManager.saveContext()
        } catch {
            print("Ошибка удаления интереса: \(error)")
        }
    }
    
    // MARK: - Вспомогательные методы
    private func saveInterest(_ interest: Interest, to userEntity: UserEntity) -> InterestEntity? {
        let context = databaseManager.context
        
        let interestEntity = InterestEntity(context: context)
        interestEntity.id = interest.id.uuidString
        interestEntity.name = interest.name
        interestEntity.categoryName = interest.category.name
        interestEntity.categoryEmoji = interest.category.emoji
        interestEntity.categoryDisplayName = interest.category.displayName
        interestEntity.user = userEntity
        
        return interestEntity
    }
    
    private func saveJoinedClub(_ club: Club, to userEntity: UserEntity) -> UserClubEntity? {
        let context = databaseManager.context
        
        let clubEntity = UserClubEntity(context: context)
        clubEntity.id = club.id.uuidString
        clubEntity.name = club.name
        clubEntity.imageName = club.imageName
        clubEntity.isJoined = club.isJoined
        clubEntity.localImagePath = club.localImagePath
        clubEntity.clubDescription = club.description
        clubEntity.tags = club.tags
        clubEntity.isCreator = club.isCreator
        clubEntity.user = userEntity
        clubEntity.relationshipType = "joined"
        
        return clubEntity
    }
    
    private func saveCreatedClub(_ club: Club, to userEntity: UserEntity) -> UserClubEntity? {
        let context = databaseManager.context
        
        let clubEntity = UserClubEntity(context: context)
        clubEntity.id = club.id.uuidString
        clubEntity.name = club.name
        clubEntity.imageName = club.imageName
        clubEntity.isJoined = club.isJoined
        clubEntity.localImagePath = club.localImagePath
        clubEntity.clubDescription = club.description
        clubEntity.tags = club.tags
        clubEntity.isCreator = club.isCreator
        clubEntity.user = userEntity
        clubEntity.relationshipType = "created"
        
        return clubEntity
    }
}
