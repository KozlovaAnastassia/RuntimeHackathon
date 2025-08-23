//
//  ChatService.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//

import Combine
import Foundation

class ChatService {
    // В реальном приложении здесь будет сетевой запрос
    // или работа с локальной базой данных
    
    func getMessages() -> AnyPublisher<[Message], Error> {
        // Имитация загрузки сообщений
        Future<[Message], Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                let messages = [
                    Message(userId: "1", userName: "Анна", text: "Привет всем!", timestamp: Date().addingTimeInterval(-300), isCurrentUser: false),
                    Message(userId: "2", userName: "Иван", text: "Добро пожаловать в наш клуб!", timestamp: Date().addingTimeInterval(-240), isCurrentUser: false),
                    Message(userId: "3", userName: "Мария", text: "Какие интересные темы обсудим сегодня?", timestamp: Date().addingTimeInterval(-180), isCurrentUser: false)
                ]
                promise(.success(messages))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func sendMessage(_ message: Message) -> AnyPublisher<Message, Error> {
        Future<Message, Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                // Имитация отправки сообщения
                promise(.success(message))
            }
        }
        .eraseToAnyPublisher()
    }
}

extension ChatService {
  func getChatPreviews() -> AnyPublisher<[ChatPreview], Error> {
    Future<[ChatPreview], Error> { promise in
      DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
        let chats = [
          ChatPreview(
            chatId: "1",
            title: "Фотография и искусство",
            lastMessage: "Кто-нибудь был на выставке в центре современного искусства?",
            lastMessageTime: Date().addingTimeInterval(-300),
            unreadCount: 3,
            membersCount: 24,
            isOnline: true,
            avatarColor: "blue"
          ),
          ChatPreview(
            chatId: "2",
            title: "Книжный клуб",
            lastMessage: "Завтра обсуждаем '1984' Оруэлла",
            lastMessageTime: Date().addingTimeInterval(-3600),
            unreadCount: 0,
            membersCount: 18,
            isOnline: false,
            avatarColor: "green"
          ),
          ChatPreview(
            chatId: "3",
            title: "Путешествия по Европе",
            lastMessage: "Отличные фото Барселоны!",
            lastMessageTime: Date().addingTimeInterval(-7200),
            unreadCount: 5,
            membersCount: 32,
            isOnline: true,
            avatarColor: "orange"
          ),
          ChatPreview(
            chatId: "4",
            title: "Кулинарные эксперименты",
            lastMessage: "Рецепт пасты карбонара готов!",
            lastMessageTime: Date().addingTimeInterval(-86400),
            unreadCount: 0,
            membersCount: 15,
            isOnline: false,
            avatarColor: "purple"
          ),
          ChatPreview(
            chatId: "5",
            title: "Технологии и программирование",
            lastMessage: "Новый Swift уже в бете",
            lastMessageTime: Date().addingTimeInterval(-172800),
            unreadCount: 12,
            membersCount: 45,
            isOnline: true,
            avatarColor: "red"
          )
        ]
        promise(.success(chats))
      }
    }
    .eraseToAnyPublisher()
  }
}
