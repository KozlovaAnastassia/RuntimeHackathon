//
//  Models.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import Foundation

struct ClubCategory: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let displayName: String
}
