//
//  NewsItem.swift
//  RuntimeHackathon
//
//  Created by KOZLOVA Anastasia on 23.08.2025.
//

import SwiftUI

// MARK: - Модель новости
struct NewsItem: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let imagesData: [Data]
    let createdAt: Date
    
    init(title: String, description: String, imagesData: [Data]) {
        self.title = title
        self.description = description
        self.imagesData = imagesData
        self.createdAt = Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, imagesData, createdAt
    }
}
