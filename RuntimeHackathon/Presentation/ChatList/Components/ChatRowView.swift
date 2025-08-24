//
//  ChatPreviewRow.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import SwiftUI

struct ChatRowView: View {
    let chat: ChatInfo
    @ObservedObject private var viewModel: ChatListViewModel

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
}

#Preview {
    ChatRowView(
        chat: ChatRowMock.sampleChat,
        viewModel: ChatRowMock.sampleChatListViewModel
    )
}
