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
