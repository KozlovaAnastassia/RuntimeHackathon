//
//  ChatSummaryViewModel.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//


import SwiftUI

@MainActor
class ChatSummaryViewModel: ObservableObject {
    @Published var chatSummary: String?
    @Published var chatTitle: String?
    @Published var keyPoints: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let messages: [ChatMessage]
  private let aiService = YandexGPTService.shared

    init(messages: [ChatMessage]) {
        self.messages = messages
    }
    
    func generateSummary() async {
        guard !messages.isEmpty else {
            errorMessage = "AI сервис недоступен"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Генерируем краткое описание
            chatSummary = try await aiService.generateChatSummary(messages: messages)
            
            // Генерируем название чата
            chatTitle = try await aiService.generateChatTitleFromMessages(messages: messages)
            
            // Генерируем ключевые моменты
            keyPoints = try await aiService.generateKeyPoints(messages: messages)
        } catch {
            errorMessage = "Ошибка генерации: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func regenerateSummary() async {
        await generateSummary()
    }
    
    // MARK: - Вспомогательные свойства
    
    var uniqueParticipants: [String] {
        Array(Set(messages.map { $0.userName })).sorted()
    }
    
    var chatPeriod: String {
        guard let firstMessage = messages.min(by: { $0.timestamp < $1.timestamp }),
              let lastMessage = messages.max(by: { $0.timestamp < $1.timestamp }) else {
            return "Неизвестно"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        if Calendar.current.isDate(firstMessage.timestamp, inSameDayAs: lastMessage.timestamp) {
            return "Сегодня"
        } else {
            return "\(formatter.string(from: firstMessage.timestamp)) - \(formatter.string(from: lastMessage.timestamp))"
        }
    }
    
    // MARK: - Вспомогательные методы
    
    private func getAPIKey() -> String? {
        return Bundle.main.infoDictionary?["YANDEX_API_KEY"] as? String
    }
    
    private func getFolderId() -> String? {
        return Bundle.main.infoDictionary?["YANDEX_FOLDER_ID"] as? String
    }
}
