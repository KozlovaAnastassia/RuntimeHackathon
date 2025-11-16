//
//  ProfileHeaderView.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import SwiftUI

struct ProfileHeaderView: View {
    @State private var editedName: String = ""
    @State private var editedNickname: String = ""
    @State private var editedLocation: String = ""

    let user: User
    let isEditing: Bool
    let onEdit: () -> Void
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Аватар СЛЕВА
            Image(systemName: "hare.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
                .frame(width: 80, height: 80)
                .background(Color.orange.opacity(0.1))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                .shadow(radius: 5)

            // Информация справа
            VStack(alignment: .leading, spacing: 12) {
                if isEditing {
                    // Поля ввода в режиме редактирования
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Имя", text: $editedName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title2)
                            .fontWeight(.bold)

                        TextField("Никнейм", text: $editedNickname)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.subheadline)
                    }
                } else {
                    // Обычное отображение
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Text("@\(user.nickname)")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                            .fontWeight(.medium)
                    }
                }

                // Контактная информация
                if isEditing {
                    // Поля ввода для контактов в режиме редактирования
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Email", text: .constant(user.email))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.caption)
                            .disabled(true)

                        TextField("Город", text: $editedLocation)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.caption)

                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .frame(width: 16)
                            Text("С нами с \(formatDateFull(user.joinDate))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    // Обычное отображение контактов
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "envelope")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .frame(width: 16)
                            Text(user.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        if let location = user.location, !location.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "location.fill")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .frame(width: 16)
                                Text(location)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .frame(width: 16)
                            Text("С нами с \(formatDateFull(user.joinDate))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Spacer()

            // Кнопка редактирования для секции профиля
            Button(action: isEditing ? saveAndClose : onEdit) {
                Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                    .font(.title2)
                    .foregroundColor(isEditing ? .green : .orange)
            }
            .buttonStyle(PlainButtonStyle())

            if isEditing {
                Button(action: cancelAndClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onAppear {
            // Инициализируем значения при появлении
            editedName = user.name
            editedNickname = user.nickname
            editedLocation = user.location ?? ""
        }
        .onChange(of: user) { newUser in
            // Обновляем значения при изменении пользователя
            editedName = newUser.name
            editedNickname = newUser.nickname
            editedLocation = newUser.location ?? ""
        }
    }

    private func saveAndClose() {
        // Передаем отредактированные значения в onSave closure
        onSave()
    }

    private func cancelAndClose() {
        // Сбрасываем значения при отмене
        editedName = user.name
        editedNickname = user.nickname
        editedLocation = user.location ?? ""
        onCancel()
    }

    private func formatDateFull(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL"

        let monthName = formatter.string(from: date)
        let prepositionalMonth = convertToPrepositionalCase(monthName)

        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)

        return "\(prepositionalMonth) \(year)"
    }

    private func convertToPrepositionalCase(_ month: String) -> String {
        let lowercased = month.lowercased()
        return ProfileDataMock.monthCasesDict[lowercased] ?? lowercased
    }

    private var randomAnimalIcon: String {
        let index = user.id.uuidString.prefix(1).first?.asciiValue ?? 65
        return ProfileDataMock.animals[Int(index) % ProfileDataMock.animals.count]
    }
}

#Preview {
    ProfileHeaderView(
        user: ProfileDataMock.sampleUser,
        isEditing: false,
        onEdit: {},
        onSave: {},
        onCancel: {}
    )
    .withDataLayer()
}
