//
//  ChatService.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//

import Combine
import Foundation

class ChatDatabase {

  private init() {}
  public static let shared = ChatDatabase()

  var messages: [ChatMessage] = [
    ChatMessage(userId: "1", userName: "Анна", text: "Привет всем!", timestamp: Date().addingTimeInterval(-300), isCurrentUser: false),
    ChatMessage(userId: "2", userName: "Иван", text: "Добро пожаловать в наш клуб!", timestamp: Date().addingTimeInterval(-240), isCurrentUser: false),
    ChatMessage(userId: "3", userName: "Мария", text: "Какие интересные темы обсудим сегодня?", timestamp: Date().addingTimeInterval(-180), isCurrentUser: false)
  ]

  lazy var chats = [
    ChatInfo(
      chatId: "1",
      title: "Фотография и искусство",
      unreadCount: 3,
      membersCount: 24,
      isOnline: true,
      avatarColor: "blue",
      messages: messages
    ),
    ChatInfo(
      chatId: "2",
      title: "Книжный клуб",
      unreadCount: 0,
      membersCount: 18,
      isOnline: false,
      avatarColor: "green",
      messages: messages
    ),
    ChatInfo(
      chatId: "3",
      title: "Путешествия по Европе",
      unreadCount: 5,
      membersCount: 32,
      isOnline: true,
      avatarColor: "orange",
      messages: messages
    ),
    ChatInfo(
      chatId: "4",
      title: "Кулинарные эксперименты",
      unreadCount: 0,
      membersCount: 15,
      isOnline: false,
      avatarColor: "purple",
      messages: messages
    ),
    ChatInfo(
      chatId: "5",
      title: "Технологии и программирование",
      unreadCount: 12,
      membersCount: 45,
      isOnline: true,
      avatarColor: "red",
      messages: messages
    )
  ]
}
