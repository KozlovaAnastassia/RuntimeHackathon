//
//  YandexGPTCompletionRequest.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//


import Foundation

// Запрос к API
struct YandexGPTCompletionRequest: Codable {
    let modelUri: String
    let completionOptions: CompletionOptions
    let messages: [Message]
    
    struct CompletionOptions: Codable {
        let stream: Bool
        let temperature: Double?
        let maxTokens: Int?
    }
    
    struct Message: Codable {
        let role: String
        let text: String
    }
}

// Ответ от API
struct YandexGPTCompletionResponse: Codable {
  let result: Result

  struct Result: Codable {
    let alternatives: [Alternative]
    let usage: Usage
    let modelVersion: String
  }

  struct Alternative: Codable {
    let message: Message
    let status: AlternativeStatus

    enum AlternativeStatus: String, Codable {
      case final = "ALTERNATIVE_STATUS_FINAL"
      case unfinished = "ALTERNATIVE_STATUS_UNFINISHED"
      case contentFilter = "ALTERNATIVE_STATUS_CONTENT_FILTER"
      case toolCallParseError = "ALTERNATIVE_STATUS_TOOL_CALL_PARSE_ERROR"
    }
  }

  struct Message: Codable {
    let role: Role
    let text: String

    enum Role: String, Codable {
      case assistant = "assistant"
      case user = "user"
      case system = "system"
    }
  }

  struct Usage: Codable {
    let inputTextTokens: String
    let completionTokens: String
    let totalTokens: String
    let completionTokensDetails: CompletionTokensDetails
  }

  struct CompletionTokensDetails: Codable {
    let reasoningTokens: String
  }
}

// Расширение для удобного доступа к основному ответу
extension YandexGPTCompletionResponse {
  var mainText: String? {
    result.alternatives.first?.message.text
  }

  var isFinal: Bool {
    result.alternatives.first?.status == .final
  }
}


// Новая модель для AI чата
struct ChatMessage: Identifiable, Codable {
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
