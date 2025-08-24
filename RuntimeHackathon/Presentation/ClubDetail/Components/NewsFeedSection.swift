import SwiftUI

// MARK: - Модель элемента ленты новостей
struct NewsFeedItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let imagesData: [Data]
    let date: Date // Дата события или публикации новости
    let publicationDate: Date? // Дата публикации (для событий - когда создали, для новостей - когда опубликовали)
    let type: NewsItemType
    let newsId: UUID? // Только для новостей
    
    enum NewsItemType {
        case event
        case news
    }
}

// MARK: - Лента новостей (события + новости)
struct NewsFeedSection: View {
    let events: [ClubEvent]
    let newsItems: [NewsItem]
    let isCreator: Bool
    let dateFilter: DateFilter
    let onDeleteNews: (UUID) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Новости клуба")
                .font(.title2)
                .fontWeight(.bold)
            
            let filteredItems = getFilteredNewsItems()
            
            if filteredItems.isEmpty {
                Text("Нет новостей и событий")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(filteredItems.sorted(by: { $0.date > $1.date })) { item in
                    NewsCardView(
                        item: item,
                        isCreator: isCreator,
                        onDelete: {
                            if let newsId = item.newsId {
                                onDeleteNews(newsId)
                            }
                        }
                    )
                    Divider()
                }
            }
        }
    }
    
    private func getFilteredNewsItems() -> [NewsFeedItem] {
        var items: [NewsFeedItem] = []
        let (startDate, endDate) = dateFilter.dateRange
        
        // Добавляем события
        for event in events {
            let item = NewsFeedItem(
                id: event.id.uuidString,
                title: event.title,
                description: event.description,
                imagesData: [],
                date: event.date,
                publicationDate: event.createdAt,
                type: .event,
                newsId: nil
            )
            
            // Применяем фильтр по дате
            if shouldIncludeItem(item, startDate: startDate, endDate: endDate) {
                items.append(item)
            }
        }
        
        // Добавляем новости
        for news in newsItems {
            let item = NewsFeedItem(
                id: news.id.uuidString,
                title: news.title,
                description: news.description,
                imagesData: news.imagesData,
                date: news.createdAt,
                publicationDate: news.createdAt,
                type: .news,
                newsId: news.id
            )
            
            // Применяем фильтр по дате
            if shouldIncludeItem(item, startDate: startDate, endDate: endDate) {
                items.append(item)
            }
        }
        
        return items
    }
    
    private func shouldIncludeItem(_ item: NewsFeedItem, startDate: Date?, endDate: Date?) -> Bool {
        guard let startDate = startDate else { return true }
        
        if let endDate = endDate {
            return item.date >= startDate && item.date <= endDate
        } else {
            return item.date >= startDate
        }
    }
}
