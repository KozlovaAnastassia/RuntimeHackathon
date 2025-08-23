//
//  Club.swift
//  RuntimeHackathon
//
//  Created by Анастасия Кузнецова on 23.08.2025.
//

import SwiftUI

struct Club: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let imageName: String
    var isJoined: Bool
    var localImagePath: String?
    var description: String
    var tags: [String]
    var isCreator: Bool
  var chat: ChatInfo

    init(
        id: UUID = UUID(),
        name: String,
        imageName: String,
        isJoined: Bool = false,
        localImagePath: String? = nil,
        description: String = "",
        tags: [String] = [],
        isCreator: Bool = false,
        chat: ChatInfo = ChatInfo()
    ) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.isJoined = isJoined
        self.localImagePath = localImagePath
        self.description = description
        self.tags = tags
        self.isCreator = isCreator
      self.chat = chat
    }

    // Загружает UIImage из локального пути
    var localImage: UIImage? {
        guard let path = localImagePath else { return nil }
        return UIImage(contentsOfFile: path)
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, name, imageName, isJoined, localImagePath, description, tags, isCreator, chat
    }
}

//struct Club: Identifiable, Codable {
//    let id: UUID
//    let name: String
//    let imageName: String
//    var isJoined: Bool
//    var localImagePath: String? // путь к локальной картинке
//    
//    // Конструктор
//    init(id: UUID = UUID(), name: String, imageName: String, isJoined: Bool, localImagePath: String? = nil) {
//        self.id = id
//        self.name = name
//        self.imageName = imageName
//        self.isJoined = isJoined
//        self.localImagePath = localImagePath
//    }
//    
//    // Загружает UIImage из локального пути
//    var localImage: UIImage? {
//        guard let path = localImagePath else { return nil }
//        return UIImage(contentsOfFile: path)
//    }
//    
//    // MARK: - Codable
//    enum CodingKeys: String, CodingKey {
//        case id, name, imageName, isJoined, localImagePath
//    }
//}
