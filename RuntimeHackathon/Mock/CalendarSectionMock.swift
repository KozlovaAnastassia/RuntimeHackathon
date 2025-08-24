import Foundation

// MARK: - Моковые данные для CalendarSectionView
struct CalendarSectionMock {
    static let sampleClubEvents = [
        ClubEvent(
            title: "Встреча клуба",
            date: Date(),
            location: "Главный зал",
            description: "Еженедельная встреча участников клуба"
        ),
        ClubEvent(
            title: "Мастер-класс",
            date: Date().addingTimeInterval(86400), // Завтра
            location: "Конференц-зал А",
            description: "Мастер-класс по фотографии"
        ),
        ClubEvent(
            title: "Экскурсия",
            date: Date().addingTimeInterval(172800), // Послезавтра
            location: "Музей",
            description: "Экскурсия в музей современного искусства"
        )
    ]
    
    static let emptyClubEvents: [ClubEvent] = []
    
    static let sampleReloadTrigger = UUID()
}
