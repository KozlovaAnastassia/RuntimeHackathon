//
//  ChatListViewModel.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//


import SwiftUI
import Combine

@MainActor
class ChatListViewModel: ObservableObject {
    @Published var chats: [ChatInfo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""

    private var cancellables = Set<AnyCancellable>()
    private let repository: ChatRepository
    
    init(repository: ChatRepository = DataLayerIntegration.shared.chatRepository) {
        self.repository = repository
    }
    
    var filteredChats: [ChatInfo] {
        if searchText.isEmpty {
            return chats
        } else {
            return chats.filter { chat in
                chat.title.localizedCaseInsensitiveContains(searchText) ||
                (chat.lastMessage?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    func loadChats() async {
        isLoading = true
        errorMessage = nil
        
        do {
            chats = try await repository.getChats()
            chats.sort { $0.lastMessageTime ?? Date() > $1.lastMessageTime ?? Date() }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func searchChats() async {
        guard !searchText.isEmpty else {
            await loadChats()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            chats = try await repository.searchChats(query: searchText)
            chats.sort { $0.lastMessageTime ?? Date() > $1.lastMessageTime ?? Date() }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refreshChats() async {
        await loadChats()
    }
    
    func formatLastMessageTime(_ date: Date?) -> String {
        guard let date = date else { return "" }
        
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Вчера"
        } else if calendar.dateComponents([.day], from: date, to: now).day ?? 0 < 7 {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yy"
            return formatter.string(from: date)
        }
    }
}
