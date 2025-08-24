//
//  AddInterestView.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import SwiftUI

struct AddInterestScreen: View {
    @Binding var newInterestName: String
    @Binding var selectedCategory: InterestCategory
    let onAdd: () -> Void
    let onCancel: () -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Название интереса", text: $newInterestName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Категория")
                        .font(.headline)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(CategoryMock.allInterestCategories, id: \.id) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    VStack(spacing: 6) {
                                        Text(category.emoji)
                                            .font(.title2)
                                        Text(category.displayName)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(width: 80, height: 80)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                selectedCategory.id == category.id ? Color.orange
                                                    .opacity(0.2) : Color.gray
                                                    .opacity(0.1)
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                selectedCategory.id == category.id ? Color.orange : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .navigationTitle("Новый интерес")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        onCancel()
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        if !newInterestName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            onAdd()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(newInterestName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddInterestScreen(
        newInterestName: .constant(""),
        selectedCategory: .constant(CategoryMock.bookInterest),
        onAdd: {},
        onCancel: {}
    )
    .withDataLayer()
}
