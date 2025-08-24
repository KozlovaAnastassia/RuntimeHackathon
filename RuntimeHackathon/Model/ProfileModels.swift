//
//  Models.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import Foundation

struct User: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var nickname: String
    var email: String
    var bio: String?
    var avatarURL: String?
    var interests: [Interest]
    var joinedClubs: [Club]
    var createdClubs: [Club]
    var location: String?
    var joinDate: Date
}

struct Interest: Identifiable, Codable, Hashable {
    var id = UUID()
    let name: String
    let category: InterestCategory
}

enum InterestCategory: String, CaseIterable, Codable, Hashable {
    case book = "📚"
    case sport = "⚽"
    case language = "🗣"
    case art = "🎨"
    case tech = "💻"
    case music = "🎵"
}

enum ClubCategory: String, CaseIterable, Codable, Hashable {
    case book = "Книжный"
    case sport = "Спортивный"
    case language = "Изучение языков"
    case art = "Творческий"
    case tech = "Технологии"
}
