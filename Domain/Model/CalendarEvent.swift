import SwiftUI

struct CalendarEvent: Identifiable, Codable {
    let id = UUID()
    let title: String
    let date: Date
    let location: String
    let description: String
    let createdAt: Date
    let color: Color
    let clubName: String? // Название клуба, если событие из клуба
    
    init(id: UUID, title: String, date: Date, location: String, description: String, color: Color = .blue, clubName: String? = nil) {
        self.title = title
        self.date = date
        self.location = location
        self.description = description
        self.createdAt = Date()
        self.color = color
        self.clubName = clubName
    }
    
    // Вычисляемые свойства для совместимости с существующим кодом
    var startTime: Date {
        return date
    }
    
    var endTime: Date {
        // По умолчанию событие длится 1 час
        return Calendar.current.date(byAdding: .hour, value: 1, to: date) ?? date
    }
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var durationInMinutes: Int {
        Int(duration / 60)
    }
    
    // Кодирование/декодирование для Color
    enum CodingKeys: String, CodingKey {
        case id, title, date, location, description, createdAt, colorHex, clubName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        date = try container.decode(Date.self, forKey: .date)
        location = try container.decode(String.self, forKey: .location)
        description = try container.decode(String.self, forKey: .description)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        
        // Декодирование цвета из hex строки
        let colorHex = try container.decode(String.self, forKey: .colorHex)
        color = Color(hex: colorHex) ?? .blue
        
        // Декодирование названия клуба
        clubName = try container.decodeIfPresent(String.self, forKey: .clubName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(date, forKey: .date)
        try container.encode(location, forKey: .location)
        try container.encode(description, forKey: .description)
        try container.encode(createdAt, forKey: .createdAt)
        
        // Кодирование цвета в hex строку
        try container.encode(color.toHex(), forKey: .colorHex)
        
        // Кодирование названия клуба
        try container.encodeIfPresent(clubName, forKey: .clubName)
    }
}

// Расширение для работы с цветами
extension Color {
    func toHex() -> String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return String(format: "#%02X%02X%02X",
                     Int(red * 255),
                     Int(green * 255),
                     Int(blue * 255))
    }
    
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Расширение для преобразования ClubEvent в CalendarEvent
extension CalendarEvent {
    init(from clubEvent: ClubEvent, color: Color = .blue, clubName: String? = nil) {
        self.init(
            id: clubEvent.id,
            title: clubEvent.title,
            date: clubEvent.date,
            location: clubEvent.location,
            description: clubEvent.description,
            color: color,
            clubName: clubName
        )
    }
    
    static func fromClubEvents(_ clubEvents: [ClubEvent]) -> [CalendarEvent] {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .yellow, .mint]
        
        return clubEvents.enumerated().map { index, clubEvent in
            let color = colors[index % colors.count]
            // Извлекаем название клуба из заголовка события
            let clubName = extractClubName(from: clubEvent.title)
            return CalendarEvent(from: clubEvent, color: color, clubName: clubName)
        }
    }
    
    // Извлекает название клуба из заголовка события
    private static func extractClubName(from title: String) -> String? {
        // Ищем паттерн "в [Название клуба]"
        if let range = title.range(of: "в ", options: .caseInsensitive) {
            let clubNameStart = title.index(range.upperBound, offsetBy: 0)
            let clubName = String(title[clubNameStart...])
            return clubName
        }
        return nil
    }
}
