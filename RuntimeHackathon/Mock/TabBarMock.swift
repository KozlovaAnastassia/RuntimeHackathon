import Foundation

// MARK: - Моковые данные для TabBarButtonView
struct TabBarMock {
    static let sampleTabBarData = TabBarData(
        index: 0,
        systemImage: "list.bullet.circle",
        textKey: "Клубы"
    )
    
    static let sampleSelectedTab: Int = 0
    
    static let sampleTabBarDataList = [
        TabBarData(index: 0, systemImage: "list.bullet.circle", textKey: "Клубы"),
        TabBarData(index: 1, systemImage: "calendar", textKey: "Календарь"),
        TabBarData(index: 2, systemImage: "message", textKey: "Чаты"),
        TabBarData(index: 3, systemImage: "person.circle", textKey: "Профиль")
    ]
}

// Вспомогательная структура для данных TabBarButtonView
struct TabBarData {
    let index: Int
    let systemImage: String?
    let assetImage: String?
    let textKey: String
    
    init(index: Int, systemImage: String? = nil, assetImage: String? = nil, textKey: String) {
        self.index = index
        self.systemImage = systemImage
        self.assetImage = assetImage
        self.textKey = textKey
    }
}
