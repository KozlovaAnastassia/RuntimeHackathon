//
//  NewsItem.swift
//  RuntimeHackathon
//
//  Created by KOZLOVA Anastasia on 23.08.2025.
//

import SwiftUI

// MARK: - Модель данных для новостей
struct NewsItem: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let date: String
    let description: String
}
