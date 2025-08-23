//
//  UserProfileView.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import SwiftUI

struct UserProfileView: View {
    @StateObject private var viewModel: UserProfileViewModel

    init(user: User) {
        _viewModel = StateObject(wrappedValue: UserProfileViewModel(user: user))
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Оранжевый градиент на весь экран
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.orange.opacity(0.3),
                        Color.orange.opacity(0.15),
                        Color.orange.opacity(0.05),
                        .clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        // Header с аватаром СЛЕВА
                        ProfileHeaderView(
                            user: viewModel.user,
                            isEditing: viewModel.isEditingProfile,
                            onEdit: {
                                viewModel.editedName = viewModel.user.name
                                viewModel.editedNickname = viewModel.user.nickname
                                viewModel.editedLocation = viewModel.user.location ?? ""
                                viewModel.isEditingProfile.toggle()
                            },
                            onSave: {
                                Task { await viewModel.saveProfileSection() }
                            },
                            onCancel: { viewModel.cancelProfileEdit() }
                        )
                        .padding(.horizontal)
                        .padding(.top, 20)

                        // Статистика интересов
                        InterestStatsView(user: viewModel.user)
                            .padding(.horizontal)

                        // Основная информация
                        ProfileInfoSection(
                            bio: viewModel.user.bio ?? "",
                            isEditing: viewModel.isEditingBio,
                            onEdit: { viewModel.isEditingBio.toggle() },
                            onSave: { Task { await viewModel.saveBio() } },
                            onCancel: { viewModel.cancelBioEdit() },
                            editedBio: $viewModel.editedBio
                        )
                        .padding(.horizontal)

                        // Интересы с кнопкой добавления
                        InterestsSection(
                            interests: viewModel.user.interests,
                            isEditing: viewModel.isEditingInterests,
                            onEdit: { viewModel.isEditingInterests.toggle() },
                            onAddInterest: {
                                viewModel.showingAddInterest = true
                            },
                            onRemoveInterest: { interest in
                                viewModel.removeInterest(interest)
                            },
                            onSave: { Task { await viewModel.saveInterests() } },
                            onCancel: { viewModel.cancelInterestsEdit() }
                        )
                        .padding(.horizontal)

                        // Участник клубов
                        let joinedClubs = viewModel.user.joinedClubs.filter { $0.isJoined }
                        // Созданные клубы
//                        let createdClubs = viewModel.user.createdClubs

//                        if !createdClubs.isEmpty {
//                            CreatedClubsSection(clubs: createdClubs)
//                                .padding(.horizontal)
//                        }

                        if !joinedClubs.isEmpty {
                            JoinedClubsSection(clubs: joinedClubs)
                                .padding(.horizontal)
                        }

                        Spacer()
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $viewModel.showingAddInterest) {
                AddInterestView(
                    newInterestName: $viewModel.newInterestName,
                    selectedCategory: $viewModel.selectedInterestCategory,
                    onAdd: viewModel.addInterest,
                    onCancel: { viewModel.showingAddInterest = false }
                )
            }
            .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "Неизвестная ошибка")
            }
        }
    }

}

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
        let monthCases: [String: String] = [
            "январь": "января",
            "февраль": "февраля",
            "март": "марта",
            "апрель": "апреля",
            "май": "мая",
            "июнь": "июня",
            "июль": "июля",
            "август": "августа",
            "сентябрь": "сентября",
            "октябрь": "октября",
            "ноябрь": "ноября",
            "декабрь": "декабря"
        ]

        let lowercased = month.lowercased()
        return monthCases[lowercased] ?? lowercased
    }

    private var randomAnimalIcon: String {
        let animals = ["dog.fill", "cat.fill", "bird.fill", "fish.fill", "hare.fill", "tortoise.fill"]
        let index = user.id.uuidString.prefix(1).first?.asciiValue ?? 65
        return animals[Int(index) % animals.count]
    }
}

struct InterestStatsView: View {
    let user: User

    var body: some View {
        HStack(spacing: 0) {
            StatItem(count: user.interests.count, label: "Интересов", icon: "heart.fill")
            Divider()
            StatItem(count: user.createdClubs.count, label: "Создано", icon: "plus.circle.fill")
            Divider()
            StatItem(count: user.joinedClubs.count, label: "Клубов", icon: "person.2.fill")
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct StatItem: View {
    let count: Int
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.orange)
            Text("\(count)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProfileInfoSection: View {
    let bio: String
    let isEditing: Bool
    let onEdit: () -> Void
    let onSave: () -> Void
    let onCancel: () -> Void
    @Binding var editedBio: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("О себе")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

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

            if isEditing {
                TextEditor(text: $editedBio)
                    .frame(height: 100)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            } else {
                if !bio.isEmpty {
                    Text(bio)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(4)
                } else {
                    Text("Добавьте информацию о себе")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .italic()
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

struct InterestsSection: View {
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
                            Text(interest.category.rawValue)
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

struct JoinedClubsSection: View {
    let clubs: [Club]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Участник клубов")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                if clubs.count > 3 {
                    Text("еще \(clubs.count - 3)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            ForEach(clubs.prefix(3), id: \.id) { club in
                ClubRowViewFull(club: club)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

struct ClubRowView: View {
    let club: Club
    let isCreator: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(club.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)

                    if isCreator {
                        Text("👑")
                            .font(.caption)
                    }
                }

//                Text(club.category.rawValue)
//                    .font(.caption)
//                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
//                Text("\(club.membersCount)")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
            )
        }
        .padding(.vertical, 6)
    }
}

// View для добавления нового интереса
struct AddInterestView: View {
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
                            ForEach(InterestCategory.allCases, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    VStack(spacing: 6) {
                                        Text(category.rawValue)
                                            .font(.title2)
                                        Text(getCategoryName(category))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(width: 80, height: 80)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                selectedCategory == category ? Color.orange
                                                    .opacity(0.2) : Color.gray
                                                    .opacity(0.1)
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                selectedCategory == category ? Color.orange : Color.clear,
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

    private func getCategoryName(_ category: InterestCategory) -> String {
        switch category {
        case .book: return "Книги"
        case .sport: return "Спорт"
        case .language: return "Языки"
        case .art: return "Искусство"
        case .tech: return "Технологии"
        case .music: return "Музыка"
        }
    }
}

// Улучшенный FlowLayout
struct FlowLayout: Layout {
    var spacing: CGFloat
    var lineSpacing: CGFloat

    init(spacing: CGFloat = 8, lineSpacing: CGFloat = 8) {
        self.spacing = spacing
        self.lineSpacing = lineSpacing
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let maxWidth = proposal.replacingUnspecifiedDimensions().width
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }

        var width: CGFloat = 0
        var height: CGFloat = 0
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0

        for size in sizes {
            if lineWidth + size.width > maxWidth && lineWidth > 0 {
                width = max(width, lineWidth)
                height += lineHeight + lineSpacing
                lineWidth = size.width
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
        }

        width = max(width, lineWidth)
        height += lineHeight

        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }

        let maxWidth = proposal.replacingUnspecifiedDimensions().width
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }

        var x = bounds.minX
        var y = bounds.minY
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0

        for (index, subview) in subviews.enumerated() {
            let size = sizes[index]

            if lineWidth + size.width > maxWidth && lineWidth > 0 {
                x = bounds.minX
                y += lineHeight + lineSpacing
                lineWidth = size.width
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            subview.place(
                at: CGPoint(x: x + size.width/2, y: y + size.height/2),
                anchor: .center,
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )

            x += size.width + spacing
        }
    }
}

struct ClubRowViewFull: View {
    let club: Club

    var body: some View {
        HStack {
            // Иконка клуба
            Image(systemName: club.imageName)
                .font(.title3)
                .foregroundColor(.orange)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(club.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

//                Text(club.category.rawValue)
//                    .font(.caption)
//                    .foregroundColor(.secondary)
            }

            Spacer()

            // Количество участников (если есть)
//            if let membersCount = club.membersCount {
//                HStack(spacing: 4) {
//                    Image(systemName: "person.2.fill")
//                        .font(.caption)
//                        .foregroundColor(.orange)
//                    Text("\(membersCount)")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                }
//                .padding(.horizontal, 8)
//                .padding(.vertical, 4)
//                .background(
//                    RoundedRectangle(cornerRadius: 8)
//                        .fill(Color.gray.opacity(0.1))
//                )
//            }
        }
        .padding(.vertical, 6)
    }

    private func getCategoryColor(_ category: ClubCategory) -> Color {
        switch category {
        case .book: return .orange
        case .sport: return .green
        case .language: return .blue
        case .art: return .pink
        case .tech: return .gray
        }
    }
}
