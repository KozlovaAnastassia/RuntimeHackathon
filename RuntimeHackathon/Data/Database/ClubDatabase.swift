import Foundation
import CoreData

class ClubDatabase {
    static let shared = ClubDatabase()
    private let databaseManager = DatabaseManager.shared
    
    private init() {}
    
    // MARK: - Сохранение клуба
    func saveClub(_ club: Club) {
        let context = databaseManager.context
        
        let fetchRequest: NSFetchRequest<ClubEntity> = ClubEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", club.id.uuidString)
        
        do {
            let existingClubs = try context.fetch(fetchRequest)
            let clubEntity: ClubEntity
            
            if let existingClub = existingClubs.first {
                clubEntity = existingClub
            } else {
                clubEntity = ClubEntity(context: context)
                clubEntity.id = club.id.uuidString
            }
            
            clubEntity.name = club.name
            clubEntity.imageName = club.imageName
            clubEntity.isJoined = club.isJoined
            clubEntity.localImagePath = club.localImagePath
            clubEntity.clubDescription = club.description
            clubEntity.tags = club.tags
            clubEntity.isCreator = club.isCreator
            clubEntity.updatedAt = Date()
            
            // Сохраняем связанный чат
            if let chatEntity = saveChat(club.chat) {
                clubEntity.chat = chatEntity
            }
            
            databaseManager.saveContext()
        } catch {
            print("Ошибка сохранения клуба: \(error)")
        }
    }
    
    // MARK: - Получение всех клубов
    func getAllClubs() -> [Club] {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<ClubEntity> = ClubEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        
        do {
            let clubEntities = try context.fetch(fetchRequest)
            return clubEntities.compactMap { entity in
                guard let idString = entity.id,
                      let id = UUID(uuidString: idString),
                      let name = entity.name,
                      let imageName = entity.imageName else {
                    return nil
                }
                
                let chat = entity.chat != nil ? ChatInfo(from: entity.chat!) : ChatInfo()
                
                return Club(
                    id: id,
                    name: name,
                    imageName: imageName,
                    isJoined: entity.isJoined,
                    localImagePath: entity.localImagePath,
                    description: entity.clubDescription ?? "",
                    tags: entity.tags ?? [],
                    isCreator: entity.isCreator,
                    chat: chat
                )
            }
        } catch {
            print("Ошибка получения клубов: \(error)")
            return []
        }
    }
    
    // MARK: - Получение клуба по ID
    func getClub(by id: UUID) -> Club? {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<ClubEntity> = ClubEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id.uuidString)
        fetchRequest.fetchLimit = 1
        
        do {
            let clubEntities = try context.fetch(fetchRequest)
            guard let entity = clubEntities.first,
                  let idString = entity.id,
                  let clubId = UUID(uuidString: idString),
                  let name = entity.name,
                  let imageName = entity.imageName else {
                return nil
            }
            
            let chat = entity.chat != nil ? ChatInfo(from: entity.chat!) : ChatInfo()
            
            return Club(
                id: clubId,
                name: name,
                imageName: imageName,
                isJoined: entity.isJoined,
                localImagePath: entity.localImagePath,
                description: entity.clubDescription ?? "",
                tags: entity.tags ?? [],
                isCreator: entity.isCreator,
                chat: chat
            )
        } catch {
            print("Ошибка получения клуба: \(error)")
            return nil
        }
    }
    
    // MARK: - Удаление клуба
    func deleteClub(_ club: Club) {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<ClubEntity> = ClubEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", club.id.uuidString)
        
        do {
            let clubEntities = try context.fetch(fetchRequest)
            clubEntities.forEach { context.delete($0) }
            databaseManager.saveContext()
        } catch {
            print("Ошибка удаления клуба: \(error)")
        }
    }
    
    // MARK: - Обновление статуса участия
    func updateJoinStatus(for clubId: UUID, isJoined: Bool) {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<ClubEntity> = ClubEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", clubId.uuidString)
        
        do {
            let clubEntities = try context.fetch(fetchRequest)
            if let clubEntity = clubEntities.first {
                clubEntity.isJoined = isJoined
                clubEntity.updatedAt = Date()
                databaseManager.saveContext()
            }
        } catch {
            print("Ошибка обновления статуса участия: \(error)")
        }
    }
    
    // MARK: - Вспомогательные методы для чатов
    private func saveChat(_ chat: ChatInfo) -> ChatEntity? {
        let context = databaseManager.context
        
        let fetchRequest: NSFetchRequest<ChatEntity> = ChatEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "chatId == %@", chat.chatId)
        
        do {
            let existingChats = try context.fetch(fetchRequest)
            let chatEntity: ChatEntity
            
            if let existingChat = existingChats.first {
                chatEntity = existingChat
            } else {
                chatEntity = ChatEntity(context: context)
                chatEntity.chatId = chat.chatId
            }
            
            chatEntity.title = chat.title
            chatEntity.unreadCount = Int32(chat.unreadCount)
            chatEntity.membersCount = Int32(chat.membersCount)
            chatEntity.isOnline = chat.isOnline
            chatEntity.avatarColor = chat.avatarColor
            chatEntity.updatedAt = Date()
            
            // Сохраняем сообщения
            chat.messages.forEach { message in
                _ = saveMessage(message, to: chatEntity)
            }
            
            return chatEntity
        } catch {
            print("Ошибка сохранения чата: \(error)")
            return nil
        }
    }
    
    private func saveMessage(_ message: ChatMessage, to chatEntity: ChatEntity) -> MessageEntity? {
        let context = databaseManager.context
        
        let messageEntity = MessageEntity(context: context)
        messageEntity.messageId = message.userId + "_" + message.timestamp.timeIntervalSince1970.description
        messageEntity.userId = message.userId
        messageEntity.userName = message.userName
        messageEntity.text = message.text
        messageEntity.timestamp = message.timestamp
        messageEntity.isCurrentUser = message.isCurrentUser
        messageEntity.chat = chatEntity
        
        return messageEntity
    }
}

// MARK: - Расширения для преобразования
extension ChatInfo {
    init(from entity: ChatEntity) {
        let messages = entity.messages?.allObjects.compactMap { messageEntity in
            guard let messageEntity = messageEntity as? MessageEntity,
                  let userId = messageEntity.userId,
                  let userName = messageEntity.userName,
                  let text = messageEntity.text,
                  let timestamp = messageEntity.timestamp else {
                return nil
            }
            
            return ChatMessage(
                userId: userId,
                userName: userName,
                text: text,
                timestamp: timestamp,
                isCurrentUser: messageEntity.isCurrentUser
            )
        } ?? []
        
        self.init(
            chatId: entity.chatId ?? "",
            title: entity.title ?? "",
            unreadCount: Int(entity.unreadCount),
            membersCount: Int(entity.membersCount),
            isOnline: entity.isOnline,
            avatarColor: entity.avatarColor ?? "blue",
            messages: messages
        )
    }
}
