import SwiftUI

struct CalendarSectionView: View {
    let clubEvents: [ClubEvent]
    let reloadTrigger: UUID
    @EnvironmentObject var clubEventsService: ClubEventsService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Календарь событий")
                .font(.title2)
                .fontWeight(.bold)
            
            CalendarScreen()
                .frame(height: 400)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
                .id(reloadTrigger)
        }
    }
}

#Preview {
    CalendarSectionView(
        clubEvents: [],
        reloadTrigger: UUID()
    )
    .environmentObject(ClubEventsService.shared)
}
