//
//  ChatViewModel.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//

import SwiftUI
import Combine

class ChatViewModel: ObservableObject {
  @Published var messages: [Message] = []
  @Published var newMessageText = ""
  @Published var isLoading = false
  @Published var errorMessage: String?

  private let chatId: String

  init(chatId: String) {
    self.chatId = chatId
  }

  private var cancellables = Set<AnyCancellable>()

  func loadMessages() {
    self.messages = ChatDatabase.shared.chats.first(where: { $0.chatId == chatId })?.messages ?? []
  }

  func sendMessage() {
    guard !newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

    let message = Message(
      userId: "currentUserId",
      userName: "Текущий пользователь",
      text: newMessageText,
      timestamp: Date(),
      isCurrentUser: true
    )

    ChatDatabase.shared.chats.first(where: { $0.chatId == chatId })?.messages.append(message)
    newMessageText = ""
    loadMessages()
  }

  func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: date)
  }
}
