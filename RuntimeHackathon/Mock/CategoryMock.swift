import Foundation

// MARK: - Моковые данные для категорий
struct CategoryMock {
    // MARK: - ClubCategory
    static let bookClub = ClubCategory(name: "book", displayName: "Книжный")
    static let sportClub = ClubCategory(name: "sport", displayName: "Спортивный")
    static let languageClub = ClubCategory(name: "language", displayName: "Изучение языков")
    static let artClub = ClubCategory(name: "art", displayName: "Творческий")
    static let techClub = ClubCategory(name: "tech", displayName: "Технологии")
    
    static let allClubCategories = [bookClub, sportClub, languageClub, artClub, techClub]
    
    // MARK: - InterestCategory
    static let bookInterest = InterestCategory(name: "book", emoji: "📚", displayName: "Книги")
    static let sportInterest = InterestCategory(name: "sport", emoji: "⚽", displayName: "Спорт")
    static let languageInterest = InterestCategory(name: "language", emoji: "🗣", displayName: "Языки")
    static let artInterest = InterestCategory(name: "art", emoji: "🎨", displayName: "Искусство")
    static let techInterest = InterestCategory(name: "tech", emoji: "💻", displayName: "Технологии")
    static let musicInterest = InterestCategory(name: "music", emoji: "🎵", displayName: "Музыка")
    
    static let allInterestCategories = [bookInterest, sportInterest, languageInterest, artInterest, techInterest, musicInterest]
    
    static func findInterestByName(_ name: String) -> InterestCategory? {
        return allInterestCategories.first { $0.name == name }
    }
}
