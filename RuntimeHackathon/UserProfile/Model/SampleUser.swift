//
//  SampleUser.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import SwiftUI

// Создаем экземпляр ClubsListViewModel
let clubsViewModel = ClubsListViewModel()

// Фильтруем клубы где пользователь участник
let joinedClubs = clubsViewModel.clubs.filter { $0.isJoined && !$0.isCreator }

// Фильтруем клубы где пользователь создатель
let createdClubs = clubsViewModel.clubs.filter { $0.isCreator }

let sampleUser = User(
    name: "Анна Петрова",
    nickname: "anna_dev",
    email: "anna.petrova@example.com",
    bio: "Люблю читать книги и изучать новые языки...",
    avatarURL: nil,
    interests: [
        Interest(name: "Научная фантастика", category: .book),
        Interest(name: "Английский язык", category: .language),
        Interest(name: "Йога", category: .sport)
    ],
    joinedClubs: joinedClubs,
    createdClubs: createdClubs,
    location: "Москва",
    joinDate: Date().addingTimeInterval(-86400 * 30 * 12)
)
