import SwiftUI

// Простой тест для проверки компиляции
struct TestEventDetail: View {
    var body: some View {
        Text("EventDetail работает!")
    }
}

struct EventDetailScreen: View {
    @StateObject private var viewModel: EventDetailViewModel
    @State private var showingDeleteAlert = false
    @Environment(\.dismiss) private var dismiss
    
    init(event: CalendarEvent) {
        self._viewModel = StateObject(wrappedValue: EventDetailViewModel(event: event))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Цветовая полоса
                        Rectangle()
                            .fill(viewModel.event.color)
                            .frame(height: 4)
                        
                        // Основная информация
                        VStack(alignment: .leading, spacing: 16) {
                            // Заголовок
                            Text(viewModel.event.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            // Описание
                            Text(viewModel.event.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineLimit(nil)
                            
                            // Местоположение
                            EventInfoRowView(
                                icon: "location.fill",
                                iconColor: .red,
                                title: "Место проведения",
                                value: viewModel.event.location
                            )
                            
                            // Дата и время
                            EventInfoRowView(
                                icon: "calendar",
                                iconColor: .blue,
                                title: "Дата и время",
                                value: formatDateTime(viewModel.event.date)
                            )
                            
                            // Продолжительность
                            EventInfoRowView(
                                icon: "clock",
                                iconColor: .green,
                                title: "Продолжительность",
                                value: formatDuration(viewModel.event.durationInMinutes)
                            )
                            
                            // Дата создания
                            EventInfoRowView(
                                icon: "calendar.badge.plus",
                                iconColor: .purple,
                                title: "Создано",
                                value: formatDate(viewModel.event.createdAt)
                            )
                            
                            // Статус записи
                            if viewModel.isRegistered {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Вы записаны на это мероприятие")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                }
                
                // Индикатор загрузки
                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView("Загрузка...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .padding()
                }
            }
            .navigationTitle("Детали мероприятия")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Закрыть") {
                    dismiss()
                },
                trailing: Button("Удалить") {
                    showingDeleteAlert = true
                }
                .foregroundColor(.red)
            )
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    // Кнопки управления
                    HStack(spacing: 16) {
                        if !viewModel.isRegistered {
                            Button(action: registerForEvent) {
                                HStack {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "person.badge.plus")
                                    }
                                    Text("Записаться")
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.isLoading ? Color.gray : Color.blue)
                                .cornerRadius(12)
                            }
                            .disabled(viewModel.isLoading)
                        } else {
                            Button(action: unregisterFromEvent) {
                                HStack {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "person.badge.minus")
                                    }
                                    Text("Отменить запись")
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.isLoading ? Color.gray : Color.orange)
                                .cornerRadius(12)
                            }
                            .disabled(viewModel.isLoading)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
            }
            .alert("Удалить мероприятие", isPresented: $showingDeleteAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Удалить", role: .destructive) {
                    deleteEvent()
                }
            } message: {
                Text("Вы уверены, что хотите удалить это мероприятие? Это действие нельзя отменить.")
            }
            .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func registerForEvent() {
        Task {
            await viewModel.registerForEvent()
        }
    }
    
    private func unregisterFromEvent() {
        Task {
            await viewModel.unregisterFromEvent()
        }
    }
    
    private func deleteEvent() {
        Task {
            let success = await viewModel.deleteEvent()
            if success {
                dismiss()
            }
        }
    }
    
    // MARK: - Formatting
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return "\(hours) ч \(remainingMinutes) мин"
        } else {
            return "\(remainingMinutes) мин"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

#Preview {
    EventDetailScreen(
        event: CalendarEvent(
            id: UUID(),
            title: "Встреча клуба программистов",
            date: Date(),
            location: "Конференц-зал А, 3 этаж",
            description: "Еженедельная встреча участников клуба программистов. Обсудим новые технологии, поделимся опытом и спланируем будущие проекты. Приглашаются все желающие!",
            color: .blue
        )
    )
}
