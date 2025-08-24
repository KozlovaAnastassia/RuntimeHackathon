import Foundation

// MARK: - Моковые данные для NewsFeedSectionView
struct NewsFeedSectionMock {
    static let sampleEvents = [
        ClubEvent(
            title: "Встреча клуба",
            date: Date(),
            location: "Главный зал",
            description: "Еженедельная встреча участников клуба"
        ),
        ClubEvent(
            title: "Мастер-класс",
            date: Date().addingTimeInterval(86400),
            location: "Конференц-зал А",
            description: "Мастер-класс по фотографии"
        )
    ]
    
    static let sampleNewsItems = [
        NewsItem(
            title: "Новая выставка",
            description: "Открывается новая выставка фотографий",
            imagesData: []
        ),
        NewsItem(
            title: "Конкурс фотографий",
            description: "Объявляем конкурс на лучшую фотографию месяца",
            imagesData: []
        )
    ]
    
    static let emptyEvents: [ClubEvent] = []
    static let emptyNewsItems: [NewsItem] = []
}
