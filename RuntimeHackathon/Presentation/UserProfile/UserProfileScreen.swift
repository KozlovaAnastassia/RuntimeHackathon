//
//  UserProfileView.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import SwiftUI

struct UserProfileScreen: View {
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
                        ProfileInfoSectionView(
                            bio: viewModel.user.bio ?? "",
                            isEditing: viewModel.isEditingBio,
                            onEdit: { viewModel.isEditingBio.toggle() },
                            onSave: { Task { await viewModel.saveBio() } },
                            onCancel: { viewModel.cancelBioEdit() },
                            editedBio: $viewModel.editedBio
                        )
                        .padding(.horizontal)

                        // Интересы с кнопкой добавления
                        InterestsSectionView(
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
                        let createdClubs = viewModel.user.createdClubs.filter { $0.isCreator }

                        if !createdClubs.isEmpty {
                            CreatedClubsSectionView(clubs: createdClubs)
                                .padding(.horizontal)
                        }

                        if !joinedClubs.isEmpty {
                            JoinedClubsSectionView(clubs: joinedClubs)
                                .padding(.horizontal)
                        }

                        Spacer()
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $viewModel.showingAddInterest) {
                AddInterestScreen(
                    newInterestName: $viewModel.newInterestName,
                    selectedCategory: $viewModel.selectedInterestCategory,
                    onAdd: {
                        viewModel.addInterest()
                    },
                    onCancel: {
                        viewModel.newInterestName = ""
                        viewModel.selectedInterestCategory = .book
                    }
                )
            }
        }
    }
}

#Preview {
    UserProfileScreen(user: UserMock.sampleUser)
}
