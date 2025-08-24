//
//  ChatListView.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//

import SwiftUI

struct ChatListScreen: View {
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
                ChatNewScreen()
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
            .onAppear {
              viewModel.loadChats()
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
                      NavigationLink(destination: ChatScreen(viewModel: ChatViewModel(chatId: chat.chatId))) {
                        ChatRowView(chat: chat, viewModel: viewModel)
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

#Preview {
    ChatListScreen(viewModel: ChatListViewModel(chats: ChatDataMock.emptyChats))
}


