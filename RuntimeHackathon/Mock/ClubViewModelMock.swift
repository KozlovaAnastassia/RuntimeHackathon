import Foundation

// MARK: - Моковые данные для ClubViewModel
struct ClubViewModelMock {
    static let sampleClubViewModel = ClubViewModel(
        clubId: UUID(),
        isCreator: true
    )
    
    static let sampleMemberClubViewModel = ClubViewModel(
        clubId: UUID(),
        isCreator: false
    )
    
    static let sampleClubId = UUID()
}
