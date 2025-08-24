import Foundation

// MARK: - Моковые данные для ClubRowView
struct ClubRowMock {
    static let sampleClub = Club(
        id: UUID(),
        name: "Тестовый клуб",
        imageName: "sportscourt",
        isJoined: true,
        isCreator: false
    )
    
    static let sampleClubCreator = Club(
        id: UUID(),
        name: "Мой клуб",
        imageName: "star",
        isJoined: true,
        isCreator: true
    )
    
    static let sampleClubNotJoined = Club(
        id: UUID(),
        name: "Клуб программистов",
        imageName: "laptopcomputer",
        isJoined: false,
        isCreator: false
    )
}
