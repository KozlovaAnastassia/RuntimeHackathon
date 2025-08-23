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
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    // Header с аватаром СЛЕВА с градиентом
                    ProfileHeaderView(
                        user: viewModel.user,
                        isEditing: viewModel.isEditingProfile,
                        onEdit: { viewModel.isEditingProfile.toggle() },
                        onSave: { Task { await viewModel.saveProfileSection() } },
                        onCancel: { viewModel.cancelProfileEdit() }
                    )
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue.opacity(0.1), .clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

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

                    // Созданные клубы
                    if !viewModel.user.createdClubs.isEmpty {
                        CreatedClubsSection(clubs: viewModel.user.createdClubs)
                            .padding(.horizontal)
                    }

                    // Участник клубов
                    if !viewModel.user.joinedClubs.isEmpty {
                        JoinedClubsSection(clubs: viewModel.user.joinedClubs)
                            .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding(.bottom, 30)
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

// MARK: - Улучшенные компоненты
struct ProfileHeaderView: View {
    let user: User
    let isEditing: Bool
    let onEdit: () -> Void
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Аватар СЛЕВА
            AsyncImage(url: URL(string: user.avatarURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 3))
            .shadow(radius: 5)

            // Информация справа (с никнеймом в формате @username)
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    if let nickname = user.nickname, !nickname.isEmpty {
                        Text("@\(nickname)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                    }

                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Дополнительная информация
                VStack(alignment: .leading, spacing: 6) {
                    if let location = user.location, !location.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text(location)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text("С нами с \(formatDateFull(user.joinDate))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // Кнопка редактирования для секции профиля
            Button(action: isEditing ? onSave : onEdit) {
                Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                    .font(.title2)
                    .foregroundColor(isEditing ? .green : .blue)
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
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private func formatDateFull(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"
        // Делаем первую букву заглавной
        let dateString = formatter.string(from: date)
        return dateString.prefix(1).uppercased() + dateString.dropFirst()
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
                .foregroundColor(.blue)
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
                        .foregroundColor(isEditing ? .green : .blue)
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
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Button(action: isEditing ? onSave : onEdit) {
                    Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(isEditing ? .green : .blue)
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
                                .fill(Color.blue.opacity(0.1))
                        )
                        .foregroundColor(.primary)
                    }

                    // Кнопка "+" для добавления нового интереса (только в режиме редактирования)
                    if isEditing {
                        Button(action: onAddInterest) {
                            Image(systemName: "plus")
                                .font(.caption)
                                .foregroundColor(.blue)
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

// Отдельные секции для клубов
struct CreatedClubsSection: View {
    let clubs: [ClubPreview]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Созданные клубы")
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
                ClubRowView(club: club, isCreator: true)
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

struct JoinedClubsSection: View {
    let clubs: [ClubPreview]

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
                ClubRowView(club: club, isCreator: false)
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
    let club: ClubPreview
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

                Text(club.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                Text("\(club.membersCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
                                            .fill(selectedCategory == category ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedCategory == category ? Color.blue : Color.clear, lineWidth: 2)
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

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleUser = User(
            name: "Анна Петрова",
            nickname: "anna_dev",
            email: "anna.petrova@example.com",
            bio: "Люблю читать книги и изучать новые языки. Участник книжного клуба более 2 лет. Также увлекаюсь йогой и акварельной живописью.",
            avatarURL: "https://picsum.photos/200",
            interests: [
                Interest(name: "Научная фантастика", category: .book),
                Interest(name: "Английский язык", category: .language),
                Interest(name: "Йога", category: .sport),
                Interest(name: "Акварель", category: .art),
                Interest(name: "iOS разработка", category: .tech)
            ],
            joinedClubs: [
                ClubPreview(name: "Клуб любителей фантастики", category: .book, membersCount: 42),
                ClubPreview(name: "Изучаем английский", category: .language, membersCount: 28),
                ClubPreview(name: "Йога для начинающих", category: .sport, membersCount: 15)
            ],
            createdClubs: [
                ClubPreview(name: "Клуб Downtown", category: .book, membersCount: 15),
                ClubPreview(name: "Tech Meetup", category: .tech, membersCount: 32)
            ],
            location: "Москва",
            joinDate: Date().addingTimeInterval(-86400 * 30 * 12)
        )

        UserProfileView(user: sampleUser)
    }
}
