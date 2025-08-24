import Foundation

// MARK: - Моковые данные для ClubCategory
struct ClubCategoryMock {
    static let book = ClubCategory(name: "book", displayName: "Книжный")
    static let sport = ClubCategory(name: "sport", displayName: "Спортивный")
    static let language = ClubCategory(name: "language", displayName: "Изучение языков")
    static let art = ClubCategory(name: "art", displayName: "Творческий")
    static let tech = ClubCategory(name: "tech", displayName: "Технологии")
    
    static let allCategories = [book, sport, language, art, tech]
}
