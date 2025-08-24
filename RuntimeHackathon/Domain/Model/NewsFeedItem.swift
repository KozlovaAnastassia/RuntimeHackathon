import Foundation

// MARK: - Модель элемента ленты новостей
struct NewsFeedItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let imagesData: [Data]
    let date: Date // Дата события или публикации новости
    let publicationDate: Date? // Дата публикации (для событий - когда создали, для новостей - когда опубликовали)
    let type: NewsItemType
    let newsId: UUID? // Только для новостей
    
    enum NewsItemType {
        case event
        case news
    }
}
