//
//  AIChatServiceProtocol.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//

import Foundation

protocol AIChatServiceProtocol {
  func sendMessage(_ message: String, chatHistory: [ChatMessage]) async throws -> String
  func generateChatTitle(messages: [ChatMessage]) async throws -> String
}

class YandexGPTService: AIChatServiceProtocol {
  private let apiKey: String = Bundle.main.infoDictionary?["YANDEX_API_KEY"] as! String
  private let folderId: String = Bundle.main.infoDictionary?["YANDEX_FOLDER_ID"] as! String
  private lazy var modelUri = "gpt://\(folderId)/yandexgpt"
  private let baseURL = "https://llm.api.cloud.yandex.net/foundationModels/v1/completion"

  func sendMessage(_ message: String, chatHistory: [ChatMessage]) async throws -> String {
    let messages = prepareMessages(for: message, chatHistory: chatHistory)

    let request = YandexGPTCompletionRequest(
      modelUri: modelUri,
      completionOptions: YandexGPTCompletionRequest.CompletionOptions(
        stream: false,
        temperature: 0.7,
        maxTokens: 2000
      ),
      messages: messages
    )

    return try await makeCompletionRequest(request)
  }

  func generateChatTitle(messages: [ChatMessage]) async throws -> String {
    let chatContent = messages.prefix(5).map { $0.content }.joined(separator: "\n")

    let systemMessage = YandexGPTCompletionRequest.Message(
      role: "system",
      text: "Создай краткое название для чата на основе обсуждения. Ответь только названием, максимум 50 символов."
    )

    let userMessage = YandexGPTCompletionRequest.Message(
      role: "user",
      text: "Обсуждение:\n\(chatContent)\n\nСоздай название для этого чата:"
    )

    let request = YandexGPTCompletionRequest(
      modelUri: modelUri,
      completionOptions: YandexGPTCompletionRequest.CompletionOptions(
        stream: false,
        temperature: 0.3,
        maxTokens: 100
      ),
      messages: [systemMessage, userMessage]
    )

    let title = try await makeCompletionRequest(request)
    return String(title.prefix(50)).trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func prepareMessages(for newMessage: String, chatHistory: [ChatMessage]) -> [YandexGPTCompletionRequest.Message] {
    var messages: [YandexGPTCompletionRequest.Message] = []

    // Системное сообщение с инструкциями
    messages.append(YandexGPTCompletionRequest.Message(
      role: "system",
      text: "Ты helpful AI ассистент в чате клуба по интересам. Отвечай кратко, по делу, дружелюбно. Учитывай контекст обсуждения."
    ))

    // История чата (берем последние 10 сообщений для оптимизации)
    let recentHistory = chatHistory.suffix(10)
    for chatMessage in recentHistory {
      messages.append(YandexGPTCompletionRequest.Message(
        role: chatMessage.role.rawValue,
        text: chatMessage.content
      ))
    }

    // Новое сообщение пользователя
    messages.append(YandexGPTCompletionRequest.Message(
      role: "user",
      text: newMessage
    ))

    return messages
  }

  private func makeCompletionRequest(_ request: YandexGPTCompletionRequest) async throws -> String {
    guard let url = URL(string: baseURL) else {
      throw AIError.invalidURL
    }

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"
    urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.setValue(" application/json", forHTTPHeaderField: "Accept")

    let requestBody = try JSONEncoder().encode(request)
    urlRequest.httpBody = requestBody

    let (data, response) = try await URLSession.shared.data(for: urlRequest)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw AIError.invalidResponse
    }

    guard httpResponse.statusCode == 200 else {
      let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
      throw AIError.httpError(statusCode: httpResponse.statusCode, message: errorText)
    }

    let completionResponse = try JSONDecoder().decode(YandexGPTCompletionResponse.self, from: data)
    return completionResponse.result.alternatives.first?.message.text ?? ""
  }
}

// Ошибки для AI сервиса
enum AIError: Error, LocalizedError {
  case invalidURL
  case invalidResponse
  case httpError(statusCode: Int, message: String)
  case decodingError

  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Неверный URL для AI сервиса"
    case .invalidResponse:
      return "Неверный ответ от AI сервиса"
    case .httpError(let statusCode, let message):
      return "Ошибка AI сервиса (\(statusCode)): \(message)"
    case .decodingError:
      return "Ошибка обработки ответа от AI"
    }
  }
}
