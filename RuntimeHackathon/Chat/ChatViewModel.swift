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

  init(messages: [Message]) {
    self.messages = messages
  }

  private var cancellables = Set<AnyCancellable>()

  func loadMessages() {
    self.messages = messages.sorted { $0.timestamp < $1.timestamp }
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

    messages += [message]
    newMessageText = ""
  }

  func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: date)
  }
}
