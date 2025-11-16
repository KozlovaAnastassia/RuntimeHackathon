import Foundation
import CoreData

class ChatRepository: ChatRepositoryProtocol {
    private let database: ChatDatabase
    private let apiService: ChatApiService
    
    init(database: ChatDatabase = .shared, apiService: ChatApiService = .shared) {
        self.database = database
        self.apiService = apiService
    }
    
    // MARK: - Получение чатов
    func getChats() async throws -> [ChatInfo] {
        // Сначала получаем данные из базы данных
        let localChats = database.getAllChats()
        
        // Асинхронно обновляем данные из API
        Task {
            do {
                let apiChats = try await apiService.getAllChats()
                // Сохраняем новые данные в базу
                for chat in apiChats {
                    database.saveChat(chat)
                }
            } catch {
                print("Ошибка синхронизации чатов с API: \(error)")
            }
        }
        
        return localChats
    }
    
    // MARK: - Получение чата по ID
    func getChat(by id: String) async throws -> ChatInfo? {
        // Сначала проверяем локальную базу
        if let localChat = database.getChat(by: id) {
            // Асинхронно обновляем данные из API
            Task {
                do {
                    let apiChat = try await apiService.getChat(by: id)
                    database.saveChat(apiChat)
                } catch {
                    print("Ошибка синхронизации чата с API: \(error)")
                }
            }
            return localChat
        }
        
        // Если нет в локальной базе, получаем из API
        do {
            let apiChat = try await apiService.getChat(by: id)
            database.saveChat(apiChat)
            return apiChat
        } catch {
            return nil
        }
    }
    
    // MARK: - Сохранение чата
    func saveChat(_ chat: ChatInfo) async throws {
        // Сохраняем в локальную базу
        database.saveChat(chat)
        
        // Асинхронно отправляем в API
        Task {
            do {
                if let existingChat = database.getChat(by: chat.chatId) {
                    // Обновляем существующий чат
                    _ = try await apiService.updateChat(chat.chatId, with: chat)
                } else {
                    // Создаем новый чат
                    _ = try await apiService.createChat(chat)
                }
            } catch {
                print("Ошибка синхронизации чата с API: \(error)")
            }
        }
    }
    
    // MARK: - Удаление чата
    func deleteChat(_ chat: ChatInfo) async throws {
        // Удаляем из локальной базы
        database.deleteChat(chat)
        
        // Асинхронно удаляем из API
        Task {
            do {
                try await apiService.deleteChat(chat.chatId)
            } catch {
                print("Ошибка удаления чата из API: \(error)")
            }
        }
    }
    
    // MARK: - Получение сообщений
    func getMessages(for chatId: String) async throws -> [ChatMessage] {
        // Получаем сообщения из локальной базы
        let localMessages = database.getMessages(for: chatId)
        
        // Асинхронно обновляем из API
        Task {
            do {
                let apiMessages = try await apiService.getMessages(for: chatId)
                // Сохраняем новые сообщения в базу
                for message in apiMessages {
                    database.saveMessage(message, to: chatId)
                }
            } catch {
                print("Ошибка синхронизации сообщений с API: \(error)")
            }
        }
        
        return localMessages
    }
    
    // MARK: - Отправка сообщения
    func sendMessage(_ message: ChatMessage, to chatId: String) async throws {
        // Сохраняем в локальную базу
        database.saveMessage(message, to: chatId)
        
        // Отправляем в API
        do {
            _ = try await apiService.sendMessage(message, to: chatId)
        } catch {
            print("Ошибка отправки сообщения в API: \(error)")
        }
    }
    
    // MARK: - Отметка как прочитанное
    func markAsRead(chatId: String) async throws {
        // Обновляем в локальной базе
        database.markAsRead(chatId: chatId)
        
        // Асинхронно обновляем в API
        Task {
            do {
                try await apiService.markAsRead(chatId: chatId)
            } catch {
                print("Ошибка отметки как прочитанное в API: \(error)")
            }
        }
    }
    
    // MARK: - Получение количества непрочитанных
    func getUnreadCount(for chatId: String) async throws -> Int {
        return database.getUnreadCount(for: chatId)
    }
    
    // MARK: - Поиск чатов
    func searchChats(query: String) async throws -> [ChatInfo] {
        // Получаем результаты из API
        do {
            let apiChats = try await apiService.searchChats(query: query)
            // Сохраняем результаты в локальную базу
            for chat in apiChats {
                database.saveChat(chat)
            }
            return apiChats
        } catch {
            // Если API недоступен, ищем в локальной базе
            let localChats = database.getAllChats()
            return localChats.filter { chat in
                chat.title.localizedCaseInsensitiveContains(query) ||
                (chat.lastMessage?.localizedCaseInsensitiveContains(query) ?? false)
            }
        }
    }
}

// MARK: - ChatDatabase (локальная база данных для чатов)
class ChatDatabase {
    static let shared = ChatDatabase()
    private let databaseManager = DatabaseManager.shared
    
    private init() {}
    
    // MARK: - Сохранение чата
    func saveChat(_ chat: ChatInfo) {
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
                _ = saveMessage(message, to: chatEntity.chatId ?? "")
            }
            
            databaseManager.saveContext()
        } catch {
            print("Ошибка сохранения чата: \(error)")
        }
    }
    
    // MARK: - Получение всех чатов
    func getAllChats() -> [ChatInfo] {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<ChatEntity> = ChatEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        
        do {
            let chatEntities = try context.fetch(fetchRequest)
            return chatEntities.compactMap { entity in
                guard let chatId = entity.chatId,
                      let title = entity.title else {
                    return nil
                }
                
                let messages: [ChatMessage] = entity.messages?.allObjects.compactMap { messageEntity in
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
                
                return ChatInfo(
                    chatId: chatId,
                    title: title,
                    unreadCount: Int(entity.unreadCount),
                    membersCount: Int(entity.membersCount),
                    isOnline: entity.isOnline,
                    avatarColor: entity.avatarColor ?? "blue",
                    messages: messages
                )
            }
        } catch {
            print("Ошибка получения чатов: \(error)")
            return []
        }
    }
    
    // MARK: - Получение чата по ID
    func getChat(by id: String) -> ChatInfo? {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<ChatEntity> = ChatEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "chatId == %@", id)
        fetchRequest.fetchLimit = 1
        
        do {
            let chatEntities = try context.fetch(fetchRequest)
            guard let entity = chatEntities.first,
                  let chatId = entity.chatId,
                  let title = entity.title else {
                return nil
            }
            
            let messages: [ChatMessage] = entity.messages?.allObjects.compactMap { messageEntity in
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
            
            return ChatInfo(
                chatId: chatId,
                title: title,
                unreadCount: Int(entity.unreadCount),
                membersCount: Int(entity.membersCount),
                isOnline: entity.isOnline,
                avatarColor: entity.avatarColor ?? "blue",
                messages: messages
            )
        } catch {
            print("Ошибка получения чата: \(error)")
            return nil
        }
    }
    
    // MARK: - Удаление чата
    func deleteChat(_ chat: ChatInfo) {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<ChatEntity> = ChatEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "chatId == %@", chat.chatId)
        
        do {
            let chatEntities = try context.fetch(fetchRequest)
            chatEntities.forEach { context.delete($0) }
            databaseManager.saveContext()
        } catch {
            print("Ошибка удаления чата: \(error)")
        }
    }
    
    // MARK: - Сохранение сообщения
    func saveMessage(_ message: ChatMessage, to chatId: String) {
        let context = databaseManager.context
        
        // Находим чат
        let chatFetchRequest: NSFetchRequest<ChatEntity> = ChatEntity.fetchRequest()
        chatFetchRequest.predicate = NSPredicate(format: "chatId == %@", chatId)
        
        do {
            let chatEntities = try context.fetch(chatFetchRequest)
            guard let chatEntity = chatEntities.first else {
                print("Чат не найден для сохранения сообщения")
                return
            }
            
            let messageEntity = MessageEntity(context: context)
            messageEntity.messageId = message.userId + "_" + message.timestamp.timeIntervalSince1970.description
            messageEntity.userId = message.userId
            messageEntity.userName = message.userName
            messageEntity.text = message.text
            messageEntity.timestamp = message.timestamp
            messageEntity.isCurrentUser = message.isCurrentUser
            messageEntity.chat = chatEntity
            
            databaseManager.saveContext()
        } catch {
            print("Ошибка сохранения сообщения: \(error)")
        }
    }
    
    // MARK: - Получение сообщений для чата
    func getMessages(for chatId: String) -> [ChatMessage] {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "chat.chatId == %@", chatId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        
        do {
            let messageEntities = try context.fetch(fetchRequest)
            return messageEntities.compactMap { entity in
                guard let userId = entity.userId,
                      let userName = entity.userName,
                      let text = entity.text,
                      let timestamp = entity.timestamp else {
                    return nil
                }
                
                return ChatMessage(
                    userId: userId,
                    userName: userName,
                    text: text,
                    timestamp: timestamp,
                    isCurrentUser: entity.isCurrentUser
                )
            }
        } catch {
            print("Ошибка получения сообщений: \(error)")
            return []
        }
    }
    
    // MARK: - Отметка как прочитанное
    func markAsRead(chatId: String) {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<ChatEntity> = ChatEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "chatId == %@", chatId)
        
        do {
            let chatEntities = try context.fetch(fetchRequest)
            if let chatEntity = chatEntities.first {
                chatEntity.unreadCount = 0
                databaseManager.saveContext()
            }
        } catch {
            print("Ошибка отметки как прочитанное: \(error)")
        }
    }
    
    // MARK: - Получение количества непрочитанных
    func getUnreadCount(for chatId: String) -> Int {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<ChatEntity> = ChatEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "chatId == %@", chatId)
        fetchRequest.fetchLimit = 1
        
        do {
            let chatEntities = try context.fetch(fetchRequest)
            return Int(chatEntities.first?.unreadCount ?? 0)
        } catch {
            print("Ошибка получения количества непрочитанных: \(error)")
            return 0
        }
    }
}

// MARK: - ChatApiService (заглушка для API)
class ChatApiService {
    static let shared = ChatApiService()
    
    private init() {}
    
    func getAllChats() async throws -> [ChatInfo] {
        // Возвращаем моковые данные
        return ChatDataMock.sampleChats
    }
    
    func getChat(by id: String) async throws -> ChatInfo {
        // Возвращаем моковый чат
        return ChatDataMock.testChat
    }
    
    func createChat(_ chat: ChatInfo) async throws -> ChatInfo {
        return chat
    }
    
    func updateChat(_ id: String, with chat: ChatInfo) async throws -> ChatInfo {
        return chat
    }
    
    func deleteChat(_ id: String) async throws {
        // Заглушка
    }
    
    func getMessages(for chatId: String) async throws -> [ChatMessage] {
        return ChatDataMock.sampleMessages
    }
    
    func sendMessage(_ message: ChatMessage, to chatId: String) async throws -> ChatMessage {
        return message
    }
    
    func markAsRead(chatId: String) async throws {
        // Заглушка
    }
    
    func searchChats(query: String) async throws -> [ChatInfo] {
        return ChatDataMock.sampleChats.filter { chat in
            chat.title.localizedCaseInsensitiveContains(query)
        }
    }
}
