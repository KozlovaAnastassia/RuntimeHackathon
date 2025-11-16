import SwiftUI

struct WeekdayHeaderView: View {
    let weekdaySymbols: [String]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
        }
        .background(Color(.systemGray6))
    }
}

#Preview {
    WeekdayHeaderView(weekdaySymbols: CalendarDataMock.sampleWeekdaySymbols)
}
