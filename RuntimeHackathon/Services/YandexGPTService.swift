//
//  AIChatServiceProtocol.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//

import Foundation

protocol AIChatServiceProtocol {
  func sendMessage(_ message: String, chatHistory: [AiChatMessage]) async throws -> String
}

class YandexGPTService: AIChatServiceProtocol {
  private let apiKey: String = ""
  private let folderId: String = ""
  private lazy var modelUri = "gpt://\(folderId)/yandexgpt"
  private let baseURL = "https://llm.api.cloud.yandex.net/foundationModels/v1/completion"

  private init() {}
  public static let shared = YandexGPTService()

  func sendMessage(_ message: String, chatHistory: [AiChatMessage]) async throws -> String {
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

  func sortClubs(byInterests interests: [String], clubs: [Club]) async throws -> [Club] {
    let interestsString = interests.joined(separator: ", ")
    let clubsString = clubs.map { "\($0.name)" }.joined(separator: "\n")

    let prompt = """
        Ты эксперт по подбору клубов по интересам. Отсортируй список клубов по релевантности для пользователя с указанными интересами.
        
        Интересы пользователя: \(interestsString)
        
        Список клубов:
        \(clubsString)
        
        Правила сортировки:
        1. Наиболее релевантные клубы по интересам пользователя - первыми
        2. Учитывай описание клубов и их теги
        3. Ответ должен содержать ТОЛЬКО названия клубов в порядке убывания релевантности, разделенные запятыми
        4. Не добавляй пояснения, только список названий
        
        Отсортированный список:
        """

    let aiResponse = try await sendMessage(prompt, chatHistory: [])
    let sortedNames = parseClubNames(from: aiResponse)

    // Сортируем оригинальные клубы по порядку из AI ответа
    let sortedClubs = sortedNames.compactMap { name in
      clubs.first { $0.name.lowercased() == name.lowercased() }
    }

    // Добавляем оставшиеся клубы в конец
    let remainingClubs = clubs.filter { club in
      !sortedClubs.contains { $0.id == club.id }
    }

    return sortedClubs + remainingClubs
  }

  private func prepareMessages(for newMessage: String, chatHistory: [AiChatMessage]) -> [YandexGPTCompletionRequest.Message] {
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

  private func parseClubNames(from response: String) -> [String] {
    // Разбиваем по запятым и очищаем от лишних пробелов
    return response
      .split(separator: ",")
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { !$0.isEmpty }
  }
}

// MARK: - Метод для генерации описания переписки

extension YandexGPTService {
  func generateChatSummary(messages: [ChatMessage]) async throws -> String {
    // Берем последние 20 сообщений для создания резюме
    let recentMessages = messages.suffix(20)

    // Форматируем сообщения для AI
    let conversationText = recentMessages.map { message in
      "\(message.userName): \(message.text)"
    }.joined(separator: "\n")

    let prompt = """
        Проанализируй следующую переписку в чате клуба по интересам и создай краткое описание обсуждения.
        
        Переписка:
        \(conversationText)
        
        Требования к описанию:
        1. Максимум 2-3 предложения
        2. Основная тема обсуждения
        3. Ключевые моменты разговора
        4. Настроение участников (если можно определить)
        5. Ответ должен быть на русском языке
        6. Не используй имена участников в описании
        
        Краткое описание:
        """

    return try await sendMessage(prompt, chatHistory: [])
  }

  func generateChatTitleFromMessages(messages: [ChatMessage]) async throws -> String {
    let recentMessages = messages.suffix(15)

    let conversationText = recentMessages.map { message in
      "\(message.userName): \(message.text)"
    }.joined(separator: "\n")

    let prompt = """
        На основе следующей переписки в чате придумай краткое название для обсуждения.
        
        Переписка:
        \(conversationText)
        
        Требования к названию:
        1. Максимум 50 символов
        2. Четко отражает тему обсуждения
        3. Лаконично и понятно
        4. Без кавычек и специальных символов
        5. Ответ должен содержать ТОЛЬКО название
        
        Название обсуждения:
        """

    let title = try await sendMessage(prompt, chatHistory: [])
    return String(title.prefix(50)).trimmingCharacters(in: .whitespacesAndNewlines)
  }

  func generateKeyPoints(messages: [ChatMessage]) async throws -> [String] {
    let recentMessages = messages.suffix(25)

    let conversationText = recentMessages.map { message in
      "\(message.userName): \(message.text)"
    }.joined(separator: "\n")

    let prompt = """
        Выдели ключевые моменты из этой переписки в чате клуба по интересам.
        
        Переписка:
        \(conversationText)
        
        Требования:
        1. 3-5 ключевых пунктов
        2. Каждый пункт - одно предложение
        3. Начинай каждый пункт с "-"
        4. Без нумерации
        5. Ответ должен содержать ТОЛЬКО список ключевых моментов
        
        Ключевые моменты:
        """

    let response = try await sendMessage(prompt, chatHistory: [])
    return parseKeyPoints(from: response)
  }

  private func parseKeyPoints(from response: String) -> [String] {
    return response
      .split(separator: "\n")
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { !$0.isEmpty && ($0.hasPrefix("-") || $0.hasPrefix("•")) }
      .map { line in
        line.replacingOccurrences(of: "^[-•]\\s*", with: "", options: .regularExpression)
      }
  }
}
