import SwiftUI

// Пример экрана, который использует CalendarView с ClubEvent
struct CalendarViewExample: View {
    @State private var clubEvents: [ClubEvent] = []
    
    var body: some View {
        VStack {
            // Кнопки для демонстрации разных сценариев
            HStack {
                Button("Загрузить события") {
                    loadSampleClubEvents()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Очистить") {
                    clubEvents = []
                }
                .buttonStyle(.bordered)
            }
            .padding()
            
            // CalendarView с ClubEvent
            if clubEvents.isEmpty {
                CalendarView() // Использует моковые данные
            } else {
                CalendarView(clubEvents: clubEvents)
            }
        }
    }
    
    private func loadSampleClubEvents() {
        let today = Date()
        let calendar = Calendar.current
        
        clubEvents = [
            ClubEvent(
                title: "Встреча клуба",
                date: calendar.date(byAdding: .hour, value: 2, to: today) ?? today,
                location: "Главный зал",
                description: "Еженедельная встреча участников клуба"
            ),
            ClubEvent(
                title: "Мастер-класс",
                date: calendar.date(byAdding: .hour, value: 5, to: today) ?? today,
                location: "Аудитория 3",
                description: "Мастер-класс по программированию"
            ),
            ClubEvent(
                title: "Турнир",
                date: calendar.date(byAdding: .day, value: 1, to: today) ?? today,
                location: "Спортивный зал",
                description: "Ежегодный турнир клуба"
            )
        ]
    }
}

#Preview {
    CalendarViewExample()
}
