import SwiftUI

// MARK: - Карточка новости в ленте
struct NewsCardView: View {
    let item: NewsFeedItem
    let isCreator: Bool
    let onDelete: () -> Void
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок с иконкой типа и кнопкой удаления
            HStack {
                HStack {
                    switch item.type {
                    case .event:
                        Image(systemName: "calendar.badge.plus")
                            .foregroundColor(.orange) // Оранжевый цвет
                    case .news:
                        Image(systemName: "newspaper")
                            .foregroundColor(.orange) // Оранжевый цвет
                    }
                    
                    Text(item.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                // Кнопка удаления для создателя (только для новостей)
                if isCreator && item.type == .news {
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                        .foregroundColor(.gray)
                    }
                    .alert("Удалить новость?", isPresented: $showingDeleteAlert) {
                        Button("Отмена", role: .cancel) { }
                        Button("Удалить", role: .destructive, action: onDelete)
                    } message: {
                        Text("Вы уверены, что хотите удалить эту новость?")
                    }
                }
            }
            
            // Даты
            VStack(alignment: .leading, spacing: 4) {
                switch item.type {
                case .event:
                    // Для событий показываем обе даты
                    Text("Опубликовано: \(formatDate(item.publicationDate ?? item.date))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Событие: \(formatEventDate(item.date))")
                        .font(.caption)
                        .foregroundColor(.orange) // Оранжевый цвет
                case .news:
                    // Для новостей показываем дату публикации
                    Text("Опубликовано: \(formatDate(item.date))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Карусель изображений (только для новостей)
            if item.type == .news && !item.imagesData.isEmpty {
                ImageCarouselView(images: item.imagesData)
            }
            
            // Описание
            Text(item.description)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func formatEventDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

#Preview {
    NewsCardView(
        item: NewsMock.sampleNewsItem,
        isCreator: true,
        onDelete: {}
    )
}
