import SwiftUI

// MARK: - Фильтр по дате
enum DateFilter: String, CaseIterable {
    case all = "Все"
    case today = "Сегодня"
    case week = "Неделя"
    case month = "Месяц"
    
    var dateRange: (Date?, Date?) {
        let now = Date()
        let calendar = Calendar.current
        
        switch self {
        case .all:
            return (nil, nil)
        case .today:
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)
            return (startOfDay, endOfDay)
        case .week:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))
            let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek ?? now)
            return (startOfWeek, endOfWeek)
        case .month:
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth ?? now)
            return (startOfMonth, endOfMonth)
        }
    }
}

// MARK: - Секция фильтра
struct DateFilterSection: View {
    @Binding var selectedFilter: DateFilter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Фильтр новостей")
                .font(.headline)
            
            HStack {
                ForEach(DateFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                    }) {
                        Text(filter.rawValue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedFilter == filter ? Color.orange : Color.gray.opacity(0.2)) // Оранжевый цвет
                            .foregroundColor(selectedFilter == filter ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
                
                Spacer()
            }
        }
    }
}
