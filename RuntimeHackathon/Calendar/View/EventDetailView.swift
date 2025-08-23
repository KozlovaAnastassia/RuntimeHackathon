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
                    
                    // Местоположение
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.red)
                            Text("Место")
                                .fontWeight(.medium)
                        }
                        
                        Text(event.location)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
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
                    
                    // Дата создания
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                                .foregroundColor(.purple)
                            Text("Создано")
                                .fontWeight(.medium)
                        }
                        
                        Text(dateString(from: event.createdAt))
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
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
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
            id: UUID(),
            title: "Тестовое событие",
            date: Date(),
            location: "Тестовое место",
            description: "Описание события",
            color: .blue
        ),
        viewModel: CalendarViewModel()
    )
}
