import SwiftUI

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

#Preview {
    DateFilterSection(selectedFilter: .constant(.all))
}
