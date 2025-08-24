import Foundation

// MARK: - Моковые данные для ClubDetailScreen
struct ClubDetailMock {
    static let sampleClub = Club(
        id: UUID(),
        name: "Тестовый клуб",
        imageName: "sportscourt",
        isJoined: true,
        isCreator: true
    )
    
    static let sampleMemberClub = Club(
        id: UUID(),
        name: "Клуб программистов",
        imageName: "laptopcomputer",
        isJoined: true,
        isCreator: false
    )
    
    static let sampleNotJoinedClub = Club(
        id: UUID(),
        name: "Клуб фотографии",
        imageName: "camera",
        isJoined: false,
        isCreator: false
    )
}
