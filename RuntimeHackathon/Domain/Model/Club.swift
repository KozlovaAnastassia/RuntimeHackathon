//
//  Club.swift
//  RuntimeHackathon
//
//  Created by Анастасия Кузнецова on 23.08.2025.
//

import SwiftUI
import CoreData

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
    
    // Инициализатор для создания из Core Data сущности
    init(from entity: UserClubEntity) {
        self.init(
            id: UUID(uuidString: entity.id ?? "") ?? UUID(),
            name: entity.name ?? "",
            imageName: entity.imageName ?? "",
            isJoined: entity.isJoined,
            localImagePath: entity.localImagePath,
            description: entity.clubDescription ?? "",
            tags: entity.tags ?? [],
            isCreator: entity.isCreator
        )
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
