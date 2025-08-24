import Foundation
import SwiftUI

// MARK: - Моковые данные для календарных компонентов
struct CalendarComponentsMock {
    static let sampleMonthYearString = "Декабрь 2024"
    
    static let sampleWeekdaySymbols = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    static let sampleEventIndicator = CalendarEvent(
        id: UUID(),
        title: "Тестовое событие",
        date: Date(),
        location: "Тестовое место",
        description: "Описание события",
        color: .blue
    )
    
    static let sampleShortEventIndicator = CalendarEvent(
        id: UUID(),
        title: "Короткое",
        date: Date(),
        location: "Место",
        description: "Краткое описание",
        color: .green
    )
    
    static let sampleLongEventIndicator = CalendarEvent(
        id: UUID(),
        title: "Очень длинное название события",
        date: Date(),
        location: "Длинное место проведения",
        description: "Подробное описание события с множеством деталей",
        color: .orange
    )
}
