import Foundation

// MARK: - Моковые данные для ChatSummaryView
struct ChatSummaryMock {
    static let sampleMessages: [ChatMessage] = [
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
