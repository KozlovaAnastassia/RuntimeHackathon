import Foundation

// MARK: - Моковые данные для CreatedClubsSectionView
struct CreatedClubsSectionMock {
    static let sampleClubs = [
        Club(id: UUID(), name: "Мой клуб", imageName: "star", isJoined: true, isCreator: true)
    ]
    
    static let sampleMultipleClubs = [
        Club(id: UUID(), name: "Мой клуб", imageName: "star", isJoined: true, isCreator: true),
        Club(id: UUID(), name: "Клуб программистов", imageName: "laptopcomputer", isJoined: true, isCreator: true),
        Club(id: UUID(), name: "Клуб фотографов", imageName: "camera", isJoined: true, isCreator: true),
        Club(id: UUID(), name: "Клуб путешественников", imageName: "airplane", isJoined: true, isCreator: true)
    ]
}
