//
//  ChatPreview.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//

import Foundation
import SwiftUI

class ChatInfo: Identifiable, Codable, Equatable, Hashable {
  static func == (lhs: ChatInfo, rhs: ChatInfo) -> Bool {
    lhs.chatId == rhs.chatId
  }

  var hashValue: Int { Int.random(in: 0...14) }
  func hash(into hasher: inout Hasher) {}


    let chatId: String
    let title: String
  var lastMessage: String? {
    messages.last?.text
  }
  var lastMessageTime: Date? {
    messages.last?.timestamp
  }
    let unreadCount: Int
    let membersCount: Int
    let isOnline: Bool
    let avatarColor: String // В реальном приложении будет URL или Image
  var messages: [ChatMessage]

  init(chatId: String, title: String, unreadCount: Int, membersCount: Int, isOnline: Bool, avatarColor: String, messages: [ChatMessage]) {
    self.chatId = chatId
    self.title = title
    self.unreadCount = unreadCount
    self.membersCount = membersCount
    self.isOnline = isOnline
    self.avatarColor = avatarColor
    self.messages = messages
  }

  convenience init() {
    self.init(
      chatId: UUID().uuidString,
      title: "Чат 1",
      unreadCount: 0,
      membersCount: 5,
      isOnline: true,
      avatarColor: "blue",
      messages: []
    )
  }
}

// Расширение для цветов аватаров
extension ChatInfo {
    var avatarUIColor: Color {
        switch avatarColor {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        default: return .gray
        }
    }
}
