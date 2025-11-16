//
//  Models.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//

import Foundation

struct ChatRoom {
  let id: String
  let name: String
  let membersCount: Int
  let lastMessage: String?
  let lastMessageTime: Date?
}
