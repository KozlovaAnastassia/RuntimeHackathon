//
//  UserProfileViewModel.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import SwiftUI

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Отдельные состояния редактирования для каждой секции
    @Published var isEditingProfile = false
    @Published var isEditingBio = false
    @Published var isEditingInterests = false

    // Для редактирования
    @Published var editedName: String = ""
    @Published var editedNickname: String = ""
    @Published var editedLocation: String = ""
    @Published var editedBio: String = ""
    @Published var editedInterests: [Interest] = []

    // Для добавления интересов
    @Published var showingAddInterest = false
    @Published var newInterestName = ""
    @Published var selectedInterestCategory: InterestCategory = .book

    init(user: User) {
        self.user = user
        self.editedName = user.name
        self.editedNickname = user.nickname ?? ""
        self.editedLocation = user.location ?? ""
        self.editedBio = user.bio ?? ""
        self.editedInterests = user.interests
    }

    func saveProfileSection() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await Task.sleep(nanoseconds: 500_000_000)
            user.name = editedName
            user.nickname = editedNickname.isEmpty ? nil : editedNickname
            user.location = editedLocation.isEmpty ? nil : editedLocation
            isEditingProfile = false
        } catch {
            errorMessage = "Ошибка сохранения профиля"
        }
    }

    func saveBio() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await Task.sleep(nanoseconds: 500_000_000)
            user.bio = editedBio.isEmpty ? nil : editedBio
            isEditingBio = false
        } catch {
            errorMessage = "Ошибка сохранения информации"
        }
    }

    func saveInterests() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await Task.sleep(nanoseconds: 500_000_000)
            user.interests = editedInterests
            isEditingInterests = false
        } catch {
            errorMessage = "Ошибка сохранения интересов"
        }
    }

    func cancelProfileEdit() {
        editedName = user.name
        editedNickname = user.nickname ?? ""
        editedLocation = user.location ?? ""
        isEditingProfile = false
    }

    func cancelBioEdit() {
        editedBio = user.bio ?? ""
        isEditingBio = false
    }

    func cancelInterestsEdit() {
        editedInterests = user.interests
        isEditingInterests = false
    }

    // Добавление нового интереса
    func addInterest() {
        let newInterest = Interest(
            name: newInterestName.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedInterestCategory
        )
        editedInterests.append(newInterest)
        newInterestName = ""
        showingAddInterest = false
    }

    // Удаление интереса
    func removeInterest(_ interest: Interest) {
        editedInterests.removeAll { $0.id == interest.id }
    }
}
