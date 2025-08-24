//
//  MessageView.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import SwiftUI

struct MessageView: View {
    let message: ChatMessage
    @ObservedObject private var viewModel: ChatViewModel

    init(viewModel: ChatViewModel, message: ChatMessage) {
        self.viewModel = viewModel
        self.message = message
    }

    var body: some View {
        HStack {
            if message.isCurrentUser {
                Spacer()
            }

            VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.userName)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(message.text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(message.isCurrentUser ? Color.blue : Color(.systemGray6))
                    .foregroundColor(message.isCurrentUser ? .white : .primary)
                    .cornerRadius(16)

                Text(viewModel.formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if !message.isCurrentUser {
                Spacer()
            }
        }
    }
}

#Preview {
    MessageView(
        viewModel: ChatViewModel(chatId: "test-chat-id"),
        message: MessageMock.sampleMessage
    )
}
