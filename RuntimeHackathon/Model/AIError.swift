//
//  AIChatServiceProtocol.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//

import Foundation

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
