import Foundation

// MARK: - Моковые данные для MessageView
struct MessageMock {
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
}
