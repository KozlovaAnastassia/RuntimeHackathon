import Foundation

// MARK: - Моковые данные для InterestCategory
struct InterestCategoryMock {
    static let book = InterestCategory(name: "book", emoji: "📚", displayName: "Книги")
    static let sport = InterestCategory(name: "sport", emoji: "⚽", displayName: "Спорт")
    static let language = InterestCategory(name: "language", emoji: "🗣", displayName: "Языки")
    static let art = InterestCategory(name: "art", emoji: "🎨", displayName: "Искусство")
    static let tech = InterestCategory(name: "tech", emoji: "💻", displayName: "Технологии")
    static let music = InterestCategory(name: "music", emoji: "🎵", displayName: "Музыка")
    
    static let allCategories = [book, sport, language, art, tech, music]
    
    static func findByName(_ name: String) -> InterestCategory? {
        return allCategories.first { $0.name == name }
    }
}
