//
//  ChipsView.swift
//  RuntimeHackathon
//
//  Created by Анастасия Кузнецова on 23.08.2025.
//

import SwiftUI

// Вью для отображения тегов в виде чипсов с выбором
struct ChipsView: View {
    let items: [String]
    @Binding var selectedItems: Set<String>

    var body: some View {
        FlexibleView(data: items, spacing: 8, alignment: .leading) { tag in
            let isSelected = selectedItems.contains(tag)
            Text(tag)
                .font(.subheadline)
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue.opacity(0.7) : randomColor(for: tag).opacity(0.5))
                .cornerRadius(12)
                .onTapGesture {
                    if isSelected {
                        selectedItems.remove(tag)
                    } else {
                        selectedItems.insert(tag)
                    }
                }
        }
    }

    func randomColor(for text: String) -> Color {
        let colors: [Color] = ProfileMock.colors.map { Color($0) }
        let hash = abs(text.hashValue)
        return colors[hash % colors.count]
    }
}

// MARK: - FlexibleView (Flow Layout)
struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content

    init(data: Data, spacing: CGFloat = 8, alignment: HorizontalAlignment = .leading, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    var body: some View {
        var width: CGFloat = 0
        var rows: [[Data.Element]] = [[]]
        
        // Разбиваем данные на строки
        for element in data {
            let elementWidth: CGFloat = CGFloat((element as? String)?.count ?? 1) * 10 + 40 // приблизительно под текст
            if width + elementWidth + spacing > UIScreen.main.bounds.width - 32 {
                rows.append([element])
                width = elementWidth + spacing
            } else {
                rows[rows.count - 1].append(element)
                width += elementWidth + spacing
            }
        }
        
        return VStack(alignment: alignment, spacing: spacing) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: spacing) {
                    ForEach(rows[rowIndex], id: \.self) { element in
                        content(element)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ChipsView(
        items: ["Программирование", "Спорт", "Музыка", "Искусство", "Технологии"],
        selectedItems: .constant(["Программирование", "Спорт"])
    )
}
