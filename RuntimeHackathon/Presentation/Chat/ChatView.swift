//
//  ContentView.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//

import SwiftUI

struct ChatView: View {
  @ObservedObject private var viewModel: ChatViewModel
  @FocusState private var isTextFieldFocused: Bool
  @State private var summarizeCliked = false

  init(viewModel: ChatViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    VStack(spacing: 0) {
      // Заголовок
      headerView

      // Список сообщений
      messagesListView

      // Поле ввода
      messageInputView
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: {
          summarizeCliked = true
        }) {
          Image(systemName: "plus")
        }
      }
    }
    .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil)) {
      Button("OK") {
        viewModel.errorMessage = nil
      }
    } message: {
      Text(viewModel.errorMessage ?? "")
    }
    .sheet(isPresented: $summarizeCliked) {
      ChatSummaryView(messages: viewModel.messages)
    }
    .onAppear {
      viewModel.loadMessages()
    }
  }

  private var headerView: some View {
    HStack {
      VStack(alignment: .leading) {
        Text("Чат клуба")
          .font(.headline)
        Text("\(viewModel.messages.count) сообщений")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      Spacer()
    }
    .padding()
    .background(Color(.systemBackground))
    .overlay(
      Rectangle()
        .frame(height: 0.5),
//        .foregroundColor(.separator),
      alignment: .bottom
    )
  }

  private var messagesListView: some View {
    ScrollViewReader { scrollView in
      ScrollView {
        VStack(spacing: 12) {
          ForEach(viewModel.messages) { message in
            MessageView(viewModel: viewModel, message: message)
              .id(message.id)
          }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
      }
      .onChange(of: viewModel.messages.count) { _ in
        // Прокрутка к последнему сообщению
        if let lastMessage = viewModel.messages.last {
          withAnimation {
            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
          }
        }
      }
    }
  }

  private var messageInputView: some View {
    HStack(spacing: 8) {
      TextField("Введите сообщение...", text: $viewModel.newMessageText, axis: .vertical)
        .textFieldStyle(.roundedBorder)
        .focused($isTextFieldFocused)
        .lineLimit(3...6)

      Button(action: {
        viewModel.sendMessage()
        isTextFieldFocused = true
      }) {
        Image(systemName: "paperplane.fill")
          .foregroundColor(.white)
          .padding(8)
          .background(Color.blue)
          .clipShape(Circle())
      }
      .disabled(viewModel.newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    .padding()
    .background(Color(.systemBackground))
    .overlay(
      Rectangle()
        .frame(height: 0.5),
//        .foregroundColor(.separator),
      alignment: .top
    )
  }
}

#Preview {
    ChatView(viewModel: ChatViewModel(chatId: "test-chat-id"))
}


