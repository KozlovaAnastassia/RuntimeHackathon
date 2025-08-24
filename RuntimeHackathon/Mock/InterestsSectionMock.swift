import Foundation

// MARK: - Моковые данные для InterestsSectionView
struct InterestsSectionMock {
    static let sampleInterests = [
        Interest(id: UUID(), name: "Swift", category: InterestCategoryMock.tech),
        Interest(id: UUID(), name: "Футбол", category: InterestCategoryMock.sport)
    ]
    
    static let sampleManyInterests = [
        Interest(id: UUID(), name: "Swift", category: InterestCategoryMock.tech),
        Interest(id: UUID(), name: "Футбол", category: InterestCategoryMock.sport),
        Interest(id: UUID(), name: "Фотография", category: InterestCategoryMock.art),
        Interest(id: UUID(), name: "Английский", category: InterestCategoryMock.language),
        Interest(id: UUID(), name: "Книги", category: InterestCategoryMock.book),
        Interest(id: UUID(), name: "Музыка", category: InterestCategoryMock.music)
    ]
    
    static let emptyInterests: [Interest] = []
}
