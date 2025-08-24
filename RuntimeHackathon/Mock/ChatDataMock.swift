import Foundation
import SwiftUI

// MARK: - Моковые данные для чатов
struct ChatDataMock {
    // MARK: - Сообщения
    static let sampleMessages: [ChatMessage] = [
        ChatMessage(userId: "1", userName: "Анна", text: "Привет всем!", timestamp: Date().addingTimeInterval(-300), isCurrentUser: false),
        ChatMessage(userId: "2", userName: "Иван", text: "Добро пожаловать в наш клуб!", timestamp: Date().addingTimeInterval(-240), isCurrentUser: false),
        ChatMessage(userId: "3", userName: "Мария", text: "Какие интересные темы обсудим сегодня?", timestamp: Date().addingTimeInterval(-180), isCurrentUser: false)
    ]
    
    static let sampleMessage = ChatMessage(
        userId: "user-1",
        userName: "Анна",
        text: "Привет! Как дела?",
        timestamp: Date(),
        isCurrentUser: false
    )
    
    static let sampleCurrentUserMessage = ChatMessage(
        userId: "current-user",
        userName: "Я",
        text: "Привет! Все хорошо, спасибо!",
        timestamp: Date().addingTimeInterval(-300),
        isCurrentUser: true
    )
    
    static let sampleLongMessage = ChatMessage(
        userId: "user-2",
        userName: "Иван",
        text: "Это очень длинное сообщение, которое может занимать несколько строк и показывать, как выглядит текст в чате при большом количестве символов.",
        timestamp: Date().addingTimeInterval(-600),
        isCurrentUser: false
    )
    
    // MARK: - Чаты
    static let sampleChats: [ChatInfo] = [
        ChatInfo(
            chatId: "1",
            title: "Фотография и искусство",
            unreadCount: 3,
            membersCount: 24,
            isOnline: true,
            avatarColor: "blue",
            messages: sampleMessages
        ),
        ChatInfo(
            chatId: "2",
            title: "Книжный клуб",
            unreadCount: 0,
            membersCount: 18,
            isOnline: false,
            avatarColor: "green",
            messages: sampleMessages
        ),
        ChatInfo(
            chatId: "3",
            title: "Путешествия по Европе",
            unreadCount: 5,
            membersCount: 32,
            isOnline: true,
            avatarColor: "orange",
            messages: sampleMessages
        ),
        ChatInfo(
            chatId: "4",
            title: "Кулинарные эксперименты",
            unreadCount: 0,
            membersCount: 15,
            isOnline: false,
            avatarColor: "purple",
            messages: sampleMessages
        ),
        ChatInfo(
            chatId: "5",
            title: "Технологии и программирование",
            unreadCount: 12,
            membersCount: 45,
            isOnline: true,
            avatarColor: "red",
            messages: sampleMessages
        )
    ]
    
    static let emptyChats: [ChatInfo] = []
    
    static let simpleChats: [ChatInfo] = [
        ChatInfo(
            chatId: "1",
            title: "Фотография и искусство",
            unreadCount: 3,
            membersCount: 24,
            isOnline: true,
            avatarColor: "blue",
            messages: []
        ),
        ChatInfo(
            chatId: "2",
            title: "Программирование",
            unreadCount: 0,
            membersCount: 15,
            isOnline: false,
            avatarColor: "green",
            messages: []
        )
    ]
    
    // MARK: - Чаты для разных представлений
    static let testChat = ChatInfo(
        chatId: "test-chat-id",
        title: "Тестовый чат",
        unreadCount: 2,
        membersCount: 5,
        isOnline: true,
        avatarColor: "blue",
        messages: []
    )
    
    static let chatWithManyMessages = ChatInfo(
        chatId: "chat-many-messages",
        title: "Клуб программистов",
        unreadCount: 15,
        membersCount: 25,
        isOnline: false,
        avatarColor: "green",
        messages: []
    )
    
    static let chatNoUnread = ChatInfo(
        chatId: "chat-no-unread",
        title: "Клуб фотографов",
        unreadCount: 0,
        membersCount: 12,
        isOnline: true,
        avatarColor: "purple",
        messages: []
    )
    
    // MARK: - ViewModel
    static let sampleChatListViewModel = ChatListViewModel(chats: [])
    
    // MARK: - Сообщения для ChatSummary
    static let summaryMessages: [ChatMessage] = [
        ChatMessage(
            userId: "1", 
            userName: "Анна", 
            text: "Привет всем! Как дела?", 
            timestamp: Date().addingTimeInterval(-3600), 
            isCurrentUser: false
        ),
        ChatMessage(
            userId: "2", 
            userName: "Иван", 
            text: "Привет! Все хорошо, спасибо. Как у тебя?", 
            timestamp: Date().addingTimeInterval(-3500), 
            isCurrentUser: false
        ),
        ChatMessage(
            userId: "3", 
            userName: "Мария", 
            text: "Отлично! Готовлюсь к завтрашней встрече", 
            timestamp: Date().addingTimeInterval(-3400), 
            isCurrentUser: false
        ),
        ChatMessage(
            userId: "1", 
            userName: "Анна", 
            text: "О чем будет встреча?", 
            timestamp: Date().addingTimeInterval(-3300), 
            isCurrentUser: false
        ),
        ChatMessage(
            userId: "3", 
            userName: "Мария", 
            text: "Будем обсуждать новый проект и распределять задачи", 
            timestamp: Date().addingTimeInterval(-3200), 
            isCurrentUser: false
        ),
        ChatMessage(
            userId: "2", 
            userName: "Иван", 
            text: "Звучит интересно! Я подготовлю презентацию", 
            timestamp: Date().addingTimeInterval(-3100), 
            isCurrentUser: false
        )
    ]
}
