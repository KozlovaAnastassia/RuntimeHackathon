import Foundation
import SwiftUI

// MARK: - Моковые данные для UI компонентов
struct UIComponentsMock {
    // MARK: - TabBar
    struct TabBarData {
        let title: String
        let icon: String
        let isSelected: Bool
    }
    
    static let sampleTabBarData = TabBarData(
        title: "Главная",
        icon: "house",
        isSelected: true
    )
    
    static let sampleSelectedTab = 0
    
    // MARK: - Теги
    static let sampleTags = ["Спорт", "Музыка", "Туризм", "Книги", "IT", "Искусство"]
    static let selectedTags = ["Спорт", "IT"]
}
