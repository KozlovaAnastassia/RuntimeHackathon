//
//  Models.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//

import Foundation

struct Message: Identifiable, Codable {
  let id = UUID()
  let userId: String
  let userName: String
  let text: String
  let timestamp: Date
  let isCurrentUser: Bool
}

struct ChatRoom {
  let id: String
  let name: String
  let membersCount: Int
  let lastMessage: String?
  let lastMessageTime: Date?
}
