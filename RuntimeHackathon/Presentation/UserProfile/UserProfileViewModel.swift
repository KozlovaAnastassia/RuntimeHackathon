//
//  UserProfileViewModel.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import SwiftUI

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var user: User?
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
    @Published var selectedInterestCategory: InterestCategory = CategoryMock.bookInterest
    
    private let repository: UserRepository
    
    init(repository: UserRepository = DataLayerIntegration.shared.userRepository) {
        self.repository = repository
    }
    
    func loadProfile(userId: UUID) async {
        print("DEBUG: Начинаем загрузку профиля для пользователя \(userId)")
        isLoading = true
        errorMessage = nil
        
        do {
            user = try await repository.getUser(by: userId)
            print("DEBUG: Получен пользователь: \(user?.name ?? "nil")")
            if let user = user {
                editedName = user.name
                editedNickname = user.nickname
                editedLocation = user.location ?? ""
                editedBio = user.bio ?? ""
                editedInterests = user.interests
                print("DEBUG: Профиль загружен успешно")
            } else {
                print("DEBUG: Пользователь не найден")
                errorMessage = "Пользователь не найден"
            }
        } catch {
            print("DEBUG: Ошибка загрузки профиля: \(error)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        print("DEBUG: Загрузка профиля завершена")
    }

    func saveProfileSection() async {
        guard var currentUser = user else { return }
        
        isLoading = true
        defer { isLoading = false }

        do {
            // Обновляем значения пользователя
            currentUser.name = editedName
            currentUser.nickname = editedNickname
            currentUser.location = editedLocation.isEmpty ? nil : editedLocation
            
            try await repository.updateProfile(currentUser)
            user = currentUser
            isEditingProfile = false
        } catch {
            errorMessage = "Ошибка сохранения профиля: \(error.localizedDescription)"
        }
    }

    func saveBio() async {
        guard var currentUser = user else { return }
        
        isLoading = true
        defer { isLoading = false }

        do {
            currentUser.bio = editedBio.isEmpty ? nil : editedBio
            try await repository.updateProfile(currentUser)
            user = currentUser
            isEditingBio = false
        } catch {
            errorMessage = "Ошибка сохранения информации: \(error.localizedDescription)"
        }
    }

    func saveInterests() async {
        guard var currentUser = user else { return }
        
        isLoading = true
        defer { isLoading = false }

        do {
            currentUser.interests = editedInterests
            try await repository.updateProfile(currentUser)
            user = currentUser
            isEditingInterests = false
        } catch {
            errorMessage = "Ошибка сохранения интересов: \(error.localizedDescription)"
        }
    }

    func cancelProfileEdit() {
        guard let currentUser = user else { return }
        editedName = currentUser.name
        editedNickname = currentUser.nickname
        editedLocation = currentUser.location ?? ""
        isEditingProfile = false
    }

    func cancelBioEdit() {
        guard let currentUser = user else { return }
        editedBio = currentUser.bio ?? ""
        isEditingBio = false
    }

    func cancelInterestsEdit() {
        guard let currentUser = user else { return }
        editedInterests = currentUser.interests
        isEditingInterests = false
    }

    // Добавление нового интереса
    func addInterest() async {
        guard let currentUser = user else { return }
        
        let newInterest = Interest(
            name: newInterestName.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedInterestCategory
        )
        
        do {
            try await repository.addInterest(newInterest, to: currentUser.id)
            editedInterests.append(newInterest)
            newInterestName = ""
            showingAddInterest = false
            
            // Перезагружаем профиль для получения обновленных данных
            await loadProfile(userId: currentUser.id)
        } catch {
            errorMessage = "Ошибка добавления интереса: \(error.localizedDescription)"
        }
    }

    // Удаление интереса
    func removeInterest(_ interest: Interest) async {
        guard let currentUser = user else { return }
        
        do {
            try await repository.removeInterest(interest, from: currentUser.id)
            editedInterests.removeAll { $0.id == interest.id }
            
            // Перезагружаем профиль для получения обновленных данных
            await loadProfile(userId: currentUser.id)
        } catch {
            errorMessage = "Ошибка удаления интереса: \(error.localizedDescription)"
        }
    }
}
