import Foundation

// MARK: - Моковые данные для ClubHeaderSectionView
struct ClubHeaderMock {
    static let sampleClub = Club(
        id: UUID(),
        name: "Тестовый клуб",
        imageName: "sportscourt",
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
    
    static let sampleClubMember = Club(
        id: UUID(),
        name: "Клуб фотографов",
        imageName: "camera",
        isJoined: true,
        isCreator: false
    )
}
