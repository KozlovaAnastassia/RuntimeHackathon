//
//  InterestsSection.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import SwiftUI

struct InterestsSectionView: View {
    let interests: [Interest]
    let isEditing: Bool
    let onEdit: () -> Void
    let onAddInterest: () -> Void
    let onRemoveInterest: (Interest) -> Void
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Интересы")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                if isEditing {
                    Button(action: onAddInterest) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.orange)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Button(action: isEditing ? onSave : onEdit) {
                    Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(isEditing ? .green : .orange)
                }
                .buttonStyle(PlainButtonStyle())

                if isEditing {
                    Button(action: onCancel) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.bottom, 4)

            // Теги как список с кнопкой добавления
            if interests.isEmpty && !isEditing {
                Text("Нет интересов")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                // Создаем массив всех элементов для FlowLayout
                FlowLayout(spacing: 8, lineSpacing: 8) {
                    // Существующие интересы
                    ForEach(interests, id: \.id) { interest in
                        HStack(spacing: 4) {
                            Text(interest.category.emoji)
                            Text(interest.name)
                                .lineLimit(1)

                            if isEditing {
                                Button(action: {
                                    onRemoveInterest(interest)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.orange.opacity(0.1))
                        )
                        .foregroundColor(.primary)
                    }

                    // Кнопка "+" для добавления нового интереса (только в режиме редактирования)
                    if isEditing {
                        Button(action: onAddInterest) {
                            Image(systemName: "plus")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .frame(width: 40, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.gray.opacity(0.1))
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    InterestsSectionView(
        interests: ProfileDataMock.sampleInterests,
        isEditing: false,
        onEdit: {},
        onAddInterest: {},
        onRemoveInterest: { _ in },
        onSave: {},
        onCancel: {}
    )
}
