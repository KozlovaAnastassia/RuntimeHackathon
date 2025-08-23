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

  private let chatService: ChatService
  private let currentUserId: String
  private var cancellables = Set<AnyCancellable>()

  init(chatService: ChatService = ChatService(), currentUserId: String = "current_user_id") {
    self.chatService = chatService
    self.currentUserId = currentUserId
    loadMessages()
  }

  func loadMessages() {
    isLoading = true
    chatService.getMessages()
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] completion in
          self?.isLoading = false
          if case .failure(let error) = completion {
            self?.errorMessage = error.localizedDescription
          }
        },
        receiveValue: { [weak self] messages in
          self?.messages = messages.sorted { $0.timestamp < $1.timestamp }
        }
      )
      .store(in: &cancellables)
  }

  func sendMessage() {
    guard !newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

    let message = Message(
      userId: currentUserId,
      userName: "Текущий пользователь",
      text: newMessageText,
      timestamp: Date(),
      isCurrentUser: true
    )

    chatService.sendMessage(message)
      .sink(
        receiveCompletion: { completion in
          if case .failure(let error) = completion {
            print("Ошибка отправки сообщения: \(error)")
          }
        },
        receiveValue: { [weak self] sentMessage in
          DispatchQueue.main.async {
            self?.messages.append(sentMessage)
            self?.newMessageText = ""
            // Прокрутка к новому сообщению
          }
        }
      )
      .store(in: &cancellables)
  }

  func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: date)
  }
}
