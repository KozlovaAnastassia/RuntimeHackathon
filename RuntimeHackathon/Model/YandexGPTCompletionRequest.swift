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
