//
//  ChatListView.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//

import SwiftUI

struct ChatListView: View {
  @ObservedObject var viewModel: ChatListViewModel
    @State private var showingNewChat = false

  init(viewModel: ChatListViewModel) {
    self.viewModel = viewModel
  }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Поисковая строка
                searchBar
                
                // Список чатов
                chatsList
            }
            .navigationTitle("Чаты")
            .navigationBarTitleDisplayMode(.large)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        showingNewChat = true
//                    }) {
//                        Image(systemName: "plus")
//                    }
//                }
//            }
            .refreshable {
                viewModel.refreshChats()
            }
            .sheet(isPresented: $showingNewChat) {
                NewChatView()
            }
            .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("Повторить") {
                    viewModel.loadChats()
                }
                Button("Отмена") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Поиск чатов...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
            
            if !viewModel.searchText.isEmpty {
                Button("Очистить") {
                    viewModel.searchText = ""
                }
                .foregroundColor(.blue)
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var chatsList: some View {
        Group {
            if viewModel.isLoading && viewModel.chats.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.filteredChats.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(viewModel.filteredChats) { chat in
                      NavigationLink(destination: ChatView(viewModel: ChatViewModel(messages: chat.messages))) {
                        ChatPreviewRow(chat: chat, viewModel: viewModel)
                        }
                        .listRowInsets(EdgeInsets())
                    }
                }
                .listStyle(.plain)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: viewModel.searchText.isEmpty ? "message.fill" : "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            if viewModel.searchText.isEmpty {
                Text("У вас пока нет чатов")
                    .font(.headline)
                Text("Начните общение с другими участниками клуба")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Чаты не найдены")
                    .font(.headline)
                Text("Попробуйте изменить поисковый запрос")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct ChatPreviewRow: View {
    let chat: ChatInfo

  init(chat: ChatInfo, viewModel: ChatListViewModel) {
    self.chat = chat
    self.viewModel = viewModel
  }

    var body: some View {
        HStack(spacing: 12) {
            // Аватар чата
            ZStack {
                Circle()
                    .fill(chat.avatarUIColor)
                    .frame(width: 50, height: 50)
                
                Text(String(chat.title.prefix(1)))
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chat.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if let lastMessageTime = chat.lastMessageTime {
                        Text(viewModel.formatLastMessageTime(lastMessageTime))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text(chat.lastMessage ?? "Нет сообщений")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                }
                
                HStack {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(chat.membersCount) участников")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if chat.isOnline {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .padding(.leading, 4)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
  @ObservedObject private var viewModel: ChatListViewModel
}
