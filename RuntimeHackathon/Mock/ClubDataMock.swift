import Foundation

// MARK: - Моковые данные для клубов
struct ClubDataMock {
    // MARK: - Основные клубы
    static let sampleClubs: [Club] = [
        Club(id: UUID(uuidString: "FA780649-27D7-4E81-95C6-8DE05DD53668")!, name: "Red Club", imageName: "sportscourt", isJoined: true, isCreator: true),
        Club(id: UUID(uuidString: "50457F4C-223A-4105-81CE-1C2410906187")!, name: "Blue Club", imageName: "figure.walk", isJoined: true, isCreator: false),
        Club(id: UUID(uuidString: "1F6CAD6A-F496-4BF2-A94F-0DD7A46207E1")!, name: "Green Club", imageName: "leaf", isJoined: false, isCreator: false)
    ]
    
    // MARK: - Клубы для разных представлений
    static let testClub = Club(
        id: UUID(),
        name: "Тестовый клуб",
        imageName: "sportscourt",
        isJoined: true,
        isCreator: true
    )
    
    static let myClub = Club(
        id: UUID(),
        name: "Мой клуб",
        imageName: "star",
        isJoined: true,
        isCreator: true
    )
    
    static let programmerClub = Club(
        id: UUID(),
        name: "Клуб программистов",
        imageName: "laptopcomputer",
        isJoined: true,
        isCreator: false
    )
    
    static let photographerClub = Club(
        id: UUID(),
        name: "Клуб фотографов",
        imageName: "camera",
        isJoined: true,
        isCreator: false
    )
    
    static let notJoinedClub = Club(
        id: UUID(),
        name: "Клуб фотографии",
        imageName: "camera",
        isJoined: false,
        isCreator: false
    )
    
    // MARK: - События клубов
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
    
    // MARK: - Теги
    static let availableTags: [String] = ["Спорт", "Музыка", "Туризм", "Книги", "IT", "Искусство"]
    
    // MARK: - ViewModel для клубов
    static let sampleClubId = testClub.id
}
