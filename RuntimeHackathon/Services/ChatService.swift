//
//  ChatService.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//

import Combine
import Foundation

class ChatDatabase {

  private init() {}
  public static let shared = ChatDatabase()

  var messages: [ChatMessage] = ChatMock.sampleMessages
  lazy var chats = ChatMock.sampleChats
}
