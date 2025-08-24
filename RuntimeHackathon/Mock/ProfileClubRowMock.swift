import Foundation

// MARK: - Моковые данные для ProfileClubRowView
struct ProfileClubRowMock {
    static let sampleClub = Club(
        id: UUID(),
        name: "Тестовый клуб",
        imageName: "star",
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
    
    static let sampleClubProgrammer = Club(
        id: UUID(),
        name: "Клуб программистов",
        imageName: "laptopcomputer",
        isJoined: true,
        isCreator: false
    )
    
    static let sampleClubPhotographer = Club(
        id: UUID(),
        name: "Клуб фотографов",
        imageName: "camera",
        isJoined: true,
        isCreator: false
    )
}
