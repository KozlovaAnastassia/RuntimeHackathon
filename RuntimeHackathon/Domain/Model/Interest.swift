//
//  Models.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import Foundation

struct Interest: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let category: InterestCategory
    
    init(id: UUID = UUID(), name: String, category: InterestCategory) {
        self.id = id
        self.name = name
        self.category = category
    }
}
