import Foundation

// MARK: - Моковые данные для пользователей
struct UserMock {
    static let sampleUser: User = {
        // Создаем экземпляр ClubsListViewModel
        let clubsViewModel = ClubsListViewModel()
        
        // Фильтруем клубы где пользователь участник
        let joinedClubs = clubsViewModel.clubs.filter { $0.isJoined && !$0.isCreator }
        
        // Фильтруем клубы где пользователь создатель
        let createdClubs = clubsViewModel.clubs.filter { $0.isCreator }
        
        return User(
            name: "Анна Петрова",
            nickname: "anna_dev",
            email: "anna.petrova@example.com",
            bio: "Люблю читать книги и изучать новые языки...",
            avatarURL: nil,
            interests: [
                Interest(name: "Научная фантастика", category: InterestCategoryMock.book),
                Interest(name: "Английский язык", category: InterestCategoryMock.language),
                Interest(name: "Йога", category: InterestCategoryMock.sport)
            ],
            joinedClubs: joinedClubs,
            createdClubs: createdClubs,
            location: "Москва",
            joinDate: Date().addingTimeInterval(-86400 * 30 * 12)
        )
    }()
}
