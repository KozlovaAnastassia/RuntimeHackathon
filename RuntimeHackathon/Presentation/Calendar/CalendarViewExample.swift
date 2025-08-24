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
        clubEvents = ClubMock.sampleClubEvents
    }
}

#Preview {
    CalendarViewExample()
}
