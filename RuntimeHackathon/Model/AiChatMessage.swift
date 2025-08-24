//
//  YandexGPTCompletionRequest.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//


import Foundation

// Новая модель для AI чата
struct AiChatMessage: Identifiable, Codable {
  let id = UUID()
  let role: MessageRole
  let content: String
  let timestamp: Date

  enum MessageRole: String, Codable {
    case user
    case assistant
    case system
  }
}
