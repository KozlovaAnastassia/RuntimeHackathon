import Foundation

// MARK: - Моковые данные для InterestsSectionView
struct InterestsSectionMock {
    static let sampleInterests = [
        Interest(id: UUID(), name: "Swift", category: .tech),
        Interest(id: UUID(), name: "Футбол", category: .sport)
    ]
    
    static let sampleManyInterests = [
        Interest(id: UUID(), name: "Swift", category: .tech),
        Interest(id: UUID(), name: "Футбол", category: .sport),
        Interest(id: UUID(), name: "Фотография", category: .art),
        Interest(id: UUID(), name: "Английский", category: .language),
        Interest(id: UUID(), name: "Книги", category: .book),
        Interest(id: UUID(), name: "Музыка", category: .music)
    ]
    
    static let emptyInterests: [Interest] = []
}
