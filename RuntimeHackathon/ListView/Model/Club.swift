//
//  Club.swift
//  RuntimeHackathon
//
//  Created by Анастасия Кузнецова on 23.08.2025.
//

import SwiftUI

import SwiftUI

struct Club: Identifiable, Codable {
    let id: UUID
    let name: String
    let imageName: String
    var isJoined: Bool
    var localImagePath: String? // путь к локальной картинке
    
    // Конструктор
    init(id: UUID = UUID(), name: String, imageName: String, isJoined: Bool, localImagePath: String? = nil) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.isJoined = isJoined
        self.localImagePath = localImagePath
    }
    
    // Загружает UIImage из локального пути
    var localImage: UIImage? {
        guard let path = localImagePath else { return nil }
        return UIImage(contentsOfFile: path)
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, name, imageName, isJoined, localImagePath
    }
}
