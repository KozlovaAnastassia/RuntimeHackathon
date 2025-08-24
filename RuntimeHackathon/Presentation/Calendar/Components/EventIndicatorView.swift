import SwiftUI

struct EventIndicatorView: View {
    let event: CalendarEvent
    
    var body: some View {
        HStack(spacing: 2) {
            Circle()
                .fill(event.color)
                .frame(width: 6, height: 6)
            
            Text(event.title)
                .font(.caption2)
                .lineLimit(1)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(event.color.opacity(0.1))
        .cornerRadius(4)
    }
}

#Preview {
    EventIndicatorView(event: CalendarComponentsMock.sampleEventIndicator)
}
