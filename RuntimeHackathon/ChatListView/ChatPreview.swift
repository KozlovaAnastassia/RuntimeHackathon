//
//  ChatPreview.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//

import Foundation
import SwiftUI

struct ChatPreview: Identifiable, Codable {
    let id = UUID()
    let chatId: String
    let title: String
    let lastMessage: String?
    let lastMessageTime: Date?
    let unreadCount: Int
    let membersCount: Int
    let isOnline: Bool
    let avatarColor: String // В реальном приложении будет URL или Image
}

// Расширение для цветов аватаров
extension ChatPreview {
    var avatarUIColor: Color {
        switch avatarColor {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        default: return .gray
        }
    }
}
