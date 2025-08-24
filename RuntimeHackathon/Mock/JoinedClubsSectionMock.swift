import Foundation

// MARK: - Моковые данные для JoinedClubsSectionView
struct JoinedClubsSectionMock {
    static let sampleClubs = [
        Club(id: UUID(), name: "Клуб программистов", imageName: "laptopcomputer", isJoined: true, isCreator: false),
        Club(id: UUID(), name: "Клуб фотографов", imageName: "camera", isJoined: true, isCreator: false)
    ]
    
    static let sampleManyClubs = [
        Club(id: UUID(), name: "Клуб программистов", imageName: "laptopcomputer", isJoined: true, isCreator: false),
        Club(id: UUID(), name: "Клуб фотографов", imageName: "camera", isJoined: true, isCreator: false),
        Club(id: UUID(), name: "Клуб путешественников", imageName: "airplane", isJoined: true, isCreator: false),
        Club(id: UUID(), name: "Клуб читателей", imageName: "book", isJoined: true, isCreator: false),
        Club(id: UUID(), name: "Клуб музыкантов", imageName: "music.note", isJoined: true, isCreator: false)
    ]
}
