import Foundation

// MARK: - Моковые данные для профиля и интересов
struct ProfileDataMock {
    // MARK: - Пользователь
    static let sampleUser: User = {
        // Создаем пустые массивы для избежания циклических зависимостей
        let joinedClubs: [Club] = []
        let createdClubs: [Club] = []
        
        return User(
            name: "Анна Петрова",
            nickname: "anna_dev",
            email: "anna.petrova@example.com",
            bio: "Люблю читать книги и изучать новые языки...",
            avatarURL: nil,
            interests: [
                Interest(name: "Научная фантастика", category: CategoryMock.bookInterest),
                Interest(name: "Английский язык", category: CategoryMock.languageInterest),
                Interest(name: "Йога", category: CategoryMock.sportInterest)
            ],
            joinedClubs: joinedClubs,
            createdClubs: createdClubs,
            location: "Москва",
            joinDate: Date().addingTimeInterval(-86400 * 30 * 12)
        )
    }()
    
    // MARK: - Интересы
    static let sampleInterests = [
        Interest(id: UUID(), name: "Swift", category: CategoryMock.techInterest),
        Interest(id: UUID(), name: "Футбол", category: CategoryMock.sportInterest)
    ]
    
    static let sampleManyInterests = [
        Interest(id: UUID(), name: "Swift", category: CategoryMock.techInterest),
        Interest(id: UUID(), name: "Футбол", category: CategoryMock.sportInterest),
        Interest(id: UUID(), name: "Фотография", category: CategoryMock.artInterest),
        Interest(id: UUID(), name: "Английский", category: CategoryMock.languageInterest),
        Interest(id: UUID(), name: "Книги", category: CategoryMock.bookInterest),
        Interest(id: UUID(), name: "Музыка", category: CategoryMock.musicInterest)
    ]
    
    static let emptyInterests: [Interest] = []
    
    // MARK: - Секции профиля
    static let sampleBio = "Люблю читать книги и изучать новые языки..."
    static let sampleLongBio = "Очень длинная биография пользователя, которая может занимать несколько строк и показывать, как выглядит текст в профиле при большом количестве символов. Здесь может быть много информации о пользователе, его интересах, достижениях и планах."
    static let emptyBio = ""
    
    // MARK: - Клубы для секций профиля
    static let sampleClubs = [
        Club(id: UUID(), name: "Клуб программистов", imageName: "laptopcomputer", isJoined: true, isCreator: false),
        Club(id: UUID(), name: "Клуб фотографов", imageName: "camera", isJoined: true, isCreator: false)
    ]
    
    static let sampleMultipleClubs = [
        Club(id: UUID(), name: "Клуб программистов", imageName: "laptopcomputer", isJoined: true, isCreator: false),
        Club(id: UUID(), name: "Клуб фотографов", imageName: "camera", isJoined: true, isCreator: false),
        Club(id: UUID(), name: "Книжный клуб", imageName: "book", isJoined: true, isCreator: false),
        Club(id: UUID(), name: "Спортивный клуб", imageName: "sportscourt", isJoined: true, isCreator: false)
    ]
    
    static let sampleManyClubs = [
        Club(id: UUID(), name: "Клуб программистов", imageName: "laptopcomputer", isJoined: true, isCreator: false),
        Club(id: UUID(), name: "Клуб фотографов", imageName: "camera", isJoined: true, isCreator: false),
        Club(id: UUID(), name: "Книжный клуб", imageName: "book", isJoined: true, isCreator: false),
        Club(id: UUID(), name: "Спортивный клуб", imageName: "sportscourt", isJoined: true, isCreator: false),
        Club(id: UUID(), name: "Музыкальный клуб", imageName: "music.note", isJoined: true, isCreator: false),
        Club(id: UUID(), name: "Клуб путешественников", imageName: "airplane", isJoined: true, isCreator: false)
    ]
    
    // MARK: - Цвета и данные для профиля
    static let monthCases = ["январь", "февраль", "март", "апрель", "май", "июнь", "июль", "август", "сентябрь", "октябрь", "ноябрь", "декабрь"]
    static let monthCasesDict = [
        "январь": "январе",
        "февраль": "феврале",
        "март": "марте",
        "апрель": "апреле",
        "май": "мае",
        "июнь": "июне",
        "июль": "июле",
        "август": "августе",
        "сентябрь": "сентябре",
        "октябрь": "октябре",
        "ноябрь": "ноябре",
        "декабрь": "декабре"
    ]
    static let animals = ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔", "🐧", "🐦", "🐤", "🦆", "🦅", "🦉", "🦇", "🐺", "🐗", "🐴", "🦋", "🐛", "🐌", "🐞", "🐜", "🦗", "🕷", "🕸", "🦂", "🐢", "🐍", "🦎", "🦖", "🦕", "🐙", "🦑", "🦐", "🦞", "🦀", "🐡", "🐠", "🐟", "🐬", "🐳", "🐋", "🦈", "🐊", "🐅", "🐆", "🦓", "🦍", "🐘", "🦏", "🐪", "🐫", "🦙", "🦒", "🐃", "🐂", "🐄", "🐎", "🐖", "🐏", "🐑", "🐐", "🦌", "🐕", "🐩", "🐈", "🐓", "🦃", "🦚", "🦜", "🦢", "🦩", "🕊", "🐇", "🦝", "🦨", "🦡", "🦫", "🦦", "🦥", "🐁", "🐀", "🐿", "🦔"]
    static let colors = ["red", "blue", "green", "yellow", "orange", "purple", "pink", "brown", "gray", "black", "white"]
}
