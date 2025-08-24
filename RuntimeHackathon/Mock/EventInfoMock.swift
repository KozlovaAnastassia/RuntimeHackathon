import Foundation
import SwiftUI

// MARK: - Моковые данные для EventInfoRowView
struct EventInfoMock {
    static let sampleEventInfo = EventInfoData(
        icon: "location.fill",
        iconColor: .blue,
        title: "Место проведения",
        value: "Конференц-зал А, 3 этаж"
    )
    
    static let sampleTimeInfo = EventInfoData(
        icon: "clock.fill",
        iconColor: .green,
        title: "Время",
        value: "14:00 - 16:00"
    )
    
    static let sampleDescriptionInfo = EventInfoData(
        icon: "text.alignleft",
        iconColor: .orange,
        title: "Описание",
        value: "Еженедельная встреча участников клуба"
    )
}

// Вспомогательная структура для данных EventInfoRowView
struct EventInfoData {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
}
