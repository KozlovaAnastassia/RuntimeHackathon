import Foundation
import SwiftUI
import UIKit

// MARK: - Моковые данные для контента (новости, события, изображения)
struct ContentDataMock {
    // MARK: - Новости
    static let sampleNewsItem = NewsItem(
        title: "Новое событие в клубе",
        description: "Приглашаем всех участников на новое мероприятие, которое состоится в ближайшее время.",
        imagesData: []
    )
    
    static let sampleEventItem = NewsItem(
        title: "Мастер-класс по фотографии",
        description: "Узнайте секреты профессиональной фотографии от опытного фотографа.",
        imagesData: []
    )
    
    // MARK: - NewsFeedItem
    static let sampleNewsFeedItem = NewsFeedItem(
        id: "news-1",
        title: "Новое событие в клубе",
        description: "Приглашаем всех участников на новое мероприятие, которое состоится в ближайшее время.",
        imagesData: [],
        date: Date(),
        publicationDate: nil,
        type: .news,
        newsId: UUID()
    )
    
    static let sampleEventFeedItem = NewsFeedItem(
        id: "event-1",
        title: "Мастер-класс по фотографии",
        description: "Узнайте секреты профессиональной фотографии от опытного фотографа.",
        imagesData: [],
        date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
        publicationDate: Date(),
        type: .event,
        newsId: nil
    )
    
    // MARK: - События для секций
    static let sampleEvents = [
        ClubEvent(
            title: "Встреча клуба",
            date: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date(),
            location: "Главный зал",
            description: "Еженедельная встреча участников клуба"
        ),
        ClubEvent(
            title: "Мастер-класс",
            date: Calendar.current.date(byAdding: .hour, value: 5, to: Date()) ?? Date(),
            location: "Аудитория 3",
            description: "Мастер-класс по программированию"
        )
    ]
    
    static let emptyEvents: [ClubEvent] = []
    
    static let sampleNewsItems = [
        NewsItem(
            title: "Новое событие в клубе",
            description: "Приглашаем всех участников на новое мероприятие.",
            imagesData: []
        ),
        NewsItem(
            title: "Мастер-класс по фотографии",
            description: "Узнайте секреты профессиональной фотографии.",
            imagesData: []
        )
    ]
    
    static let emptyNewsItems: [NewsItem] = []
    
    // MARK: - Информация о событиях
    struct EventInfoData {
        let title: String
        let value: String
        let icon: String
        let iconColor: Color = .blue
    }
    
    static let sampleEventInfo = EventInfoData(
        title: "Встреча клуба",
        value: "Главный зал",
        icon: "location"
    )
    
    // MARK: - Изображения
    static let sampleImages: [Data] = {
        var images: [Data] = []
        let colors: [UIColor] = [.red, .blue, .green, .yellow, .orange, .purple]
        
        for color in colors {
            let size = CGSize(width: 300, height: 200)
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            color.setFill()
            UIRectFill(CGRect(origin: .zero, size: size))
            
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    images.append(imageData)
                }
            }
            UIGraphicsEndImageContext()
        }
        
        return images
    }()
    
    // MARK: - Информация о клубе
    static let clubInfoStrings = [
        "О клубе": "Мы - сообщество единомышленников, объединенных общей страстью к технологиям и инновациям.",
        "Участники": "В нашем клубе более 150 активных участников, каждый из которых вносит свой вклад в развитие сообщества.",
        "Мероприятия": "Регулярно проводим встречи, мастер-классы, хакатоны и другие интересные события.",
        "Достижения": "Наши участники успешно реализовали более 50 проектов и получили признание в различных конкурсах."
    ]
}
