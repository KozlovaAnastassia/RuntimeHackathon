//
//  ChatPreview.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//

import Foundation
import SwiftUI

class ChatPreview: Identifiable, Codable {
    let id = UUID()
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
  var messages: [Message]

  init(chatId: String, title: String, unreadCount: Int, membersCount: Int, isOnline: Bool, avatarColor: String, messages: [Message]) {
    self.chatId = chatId
    self.title = title
    self.unreadCount = unreadCount
    self.membersCount = membersCount
    self.isOnline = isOnline
    self.avatarColor = avatarColor
    self.messages = messages
  }
}

// Расширение для цветов аватаров
extension ChatPreview {
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
