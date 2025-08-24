import Foundation

// MARK: - Моковые данные для клубов
struct ClubMock {
    static let sampleClubs: [Club] = [
        Club(id: UUID(uuidString: "FA780649-27D7-4E81-95C6-8DE05DD53668")!, name: "Red Club", imageName: "sportscourt", isJoined: true, isCreator: true),
        Club(id: UUID(uuidString: "50457F4C-223A-4105-81CE-1C2410906187")!, name: "Blue Club", imageName: "figure.walk", isJoined: true, isCreator: false),
        Club(id: UUID(uuidString: "1F6CAD6A-F496-4BF2-A94F-0DD7A46207E1")!, name: "Green Club", imageName: "leaf", isJoined: false, isCreator: false)
    ]
    
    static let sampleClubEvents: [ClubEvent] = [
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
        ),
        ClubEvent(
            title: "Турнир",
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            location: "Спортивный зал",
            description: "Ежегодный турнир клуба"
        )
    ]
    
    static let availableTags: [String] = ["Спорт", "Музыка", "Туризм", "Книги", "IT", "Искусство"]
}
