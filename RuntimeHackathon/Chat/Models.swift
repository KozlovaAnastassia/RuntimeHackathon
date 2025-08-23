//
//  Models.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//

import Foundation

class Message: Identifiable, Codable {

  let id = UUID()
  let userId: String
  let userName: String
  let text: String
  let timestamp: Date
  let isCurrentUser: Bool

  init(userId: String, userName: String, text: String, timestamp: Date, isCurrentUser: Bool) {
    self.userId = userId
    self.userName = userName
    self.text = text
    self.timestamp = timestamp
    self.isCurrentUser = isCurrentUser
  }
}

struct ChatRoom {
  let id: String
  let name: String
  let membersCount: Int
  let lastMessage: String?
  let lastMessageTime: Date?
}
