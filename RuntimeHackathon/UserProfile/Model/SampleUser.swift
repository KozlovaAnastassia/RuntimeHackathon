//
//  SampleUser.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import SwiftUI

var sampleUser: User {
    User(
        name: "Анна Петрова",
        nickname: "AnnaPetrova",
        email: "anna@example.com",
        bio: "Люблю читать книги и изучать новые языки.",
        avatarURL: "https://picsum.photos/200",
        interests: [
            Interest(name: "Научная фантастика", category: .book),
            Interest(name: "Английский язык", category: .language),
            Interest(name: "Йога", category: .sport),
            Interest(name: "Акварель", category: .art)
        ],
        joinedClubs: [
            ClubPreview(name: "Клуб любителей фантастики", category: .book, membersCount: 42),
            ClubPreview(name: "Изучаем английский", category: .language, membersCount: 28)
        ],
        createdClubs: [
            ClubPreview(name: "Книжный клуб Downtown", category: .book, membersCount: 15)
        ],
        location: "Москва",
        joinDate: Date().addingTimeInterval(-86400 * 30 * 6)
    )
}
