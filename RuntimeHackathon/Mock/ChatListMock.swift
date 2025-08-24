import Foundation

// MARK: - Моковые данные для списка чатов
struct ChatListMock {
    static let emptyChats: [ChatInfo] = []
    
    static let sampleChats: [ChatInfo] = [
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
}
