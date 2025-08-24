import Foundation
import SwiftUI

// MARK: - Моковые данные для ChatRowView
struct ChatRowMock {
    static let sampleChat = ChatInfo(
        chatId: "test-chat-id",
        title: "Тестовый чат",
        unreadCount: 2,
        membersCount: 5,
        isOnline: true,
        avatarColor: "blue",
        messages: []
    )
    
    static let sampleChatWithManyMessages = ChatInfo(
        chatId: "chat-many-messages",
        title: "Клуб программистов",
        unreadCount: 15,
        membersCount: 25,
        isOnline: false,
        avatarColor: "green",
        messages: []
    )
    
    static let sampleChatNoUnread = ChatInfo(
        chatId: "chat-no-unread",
        title: "Клуб фотографов",
        unreadCount: 0,
        membersCount: 12,
        isOnline: true,
        avatarColor: "purple",
        messages: []
    )
    
    static let sampleChatListViewModel = ChatListViewModel(chats: [])
}
