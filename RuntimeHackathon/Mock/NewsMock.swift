import Foundation

// MARK: - Моковые данные для новостей
struct NewsMock {
    static let sampleNewsItem = NewsFeedItem(
        id: "1",
        title: "Тестовая новость",
        description: "Описание тестовой новости",
        imagesData: [],
        date: Date(),
        publicationDate: Date(),
        type: .news,
        newsId: UUID()
    )
    
    static let sampleEventItem = NewsFeedItem(
        id: "2",
        title: "Тестовое событие",
        description: "Описание тестового события",
        imagesData: [],
        date: Date().addingTimeInterval(86400), // Завтра
        publicationDate: Date(),
        type: .event,
        newsId: nil
    )
}
