import SwiftUI

struct EventDetailView: View {
    let event: CalendarEvent
    let viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Цветовая полоса
                Rectangle()
                    .fill(event.color)
                    .frame(height: 4)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Заголовок
                    Text(event.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    // Описание
                    Text(event.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    // Время
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.blue)
                            Text("Время")
                                .fontWeight(.medium)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(timeString(from: event.startTime))
                            Text(timeString(from: event.endTime))
                        }
                        .font(.body)
                        .foregroundColor(.secondary)
                    }
                    
                    // Продолжительность
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(.green)
                            Text("Продолжительность")
                                .fontWeight(.medium)
                        }
                        
                        Text(durationString)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Кнопка удаления
                Button(action: {
                    viewModel.removeEvent(event)
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Удалить событие")
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Детали события")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Закрыть") {
                dismiss()
            })
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private var durationString: String {
        let hours = event.durationInMinutes / 60
        let minutes = event.durationInMinutes % 60
        
        if hours > 0 {
            return "\(hours) ч \(minutes) мин"
        } else {
            return "\(minutes) мин"
        }
    }
}

#Preview {
    EventDetailView(
        event: CalendarEvent(
            title: "Тестовое событие",
            description: "Описание события",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            color: .blue
        ),
        viewModel: CalendarViewModel()
    )
}
