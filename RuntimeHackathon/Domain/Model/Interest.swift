//
//  Models.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import Foundation
import CoreData

struct Interest: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let category: InterestCategory
    
    init(id: UUID = UUID(), name: String, category: InterestCategory) {
        self.id = id
        self.name = name
        self.category = category
    }
    
    // Инициализатор для создания из Core Data сущности
    init(from entity: InterestEntity) {
        let category = InterestCategory(
            name: entity.categoryName ?? "",
            emoji: entity.categoryEmoji ?? "",
            displayName: entity.categoryDisplayName ?? ""
        )
        
        self.init(
            id: UUID(uuidString: entity.id ?? "") ?? UUID(),
            name: entity.name ?? "",
            category: category
        )
    }
}
