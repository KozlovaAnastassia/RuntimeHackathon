import SwiftUI

struct CalendarHeaderView: View {
    let monthYearString: String
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onPreviousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text(monthYearString)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: onNextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
}

#Preview {
    CalendarHeaderView(
        monthYearString: "Декабрь 2024",
        onPreviousMonth: {},
        onNextMonth: {}
    )
}
