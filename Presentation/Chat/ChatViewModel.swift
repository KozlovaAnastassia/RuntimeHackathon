//
//  ChatViewModel.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//

import SwiftUI
import Combine

@MainActor
class ChatViewModel: ObservableObject {
  @Published var messages: [ChatMessage] = []
  @Published var newMessageText = ""
  @Published var isLoading = false
  @Published var errorMessage: String?

  private let chatId: String
  private let repository: ChatRepository

  init(chatId: String, repository: ChatRepository = DataLayerIntegration.shared.chatRepository) {
    self.chatId = chatId
    self.repository = repository
  }

  private var cancellables = Set<AnyCancellable>()

  func loadMessages() async {
    isLoading = true
    errorMessage = nil
    
    do {
      messages = try await repository.getMessages(for: chatId)
    } catch {
      errorMessage = error.localizedDescription
    }
    
    isLoading = false
  }

  func sendMessage() async {
    guard !newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

    let message = ChatMessage(
      userId: "currentUserId",
      userName: "Текущий пользователь",
      text: newMessageText,
      timestamp: Date(),
      isCurrentUser: true
    )

    do {
      try await repository.sendMessage(message, to: chatId)
      newMessageText = ""
      await loadMessages()
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: date)
  }
}
