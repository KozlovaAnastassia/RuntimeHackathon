//
//  ClubEvent.swift
//  RuntimeHackathon
//
//  Created by Sergey on 23.08.2025.
//

import Foundation

// Пример структуры ClubEvent (если не определена в другом месте)
struct ClubEvent: Identifiable, Codable {
    let id: UUID
    let title: String
    let date: Date
    let location: String
    let description: String
    let createdAt: Date
    
    init(title: String, date: Date, location: String, description: String) {
        self.id = UUID()
        self.title = title
        self.date = date
        self.location = location
        self.description = description
        self.createdAt = Date()
    }
}
