//
//  ChatSummaryView.swift
//  RuntimeHackathon
//
//  Created by AFONIN Kirill on 23.08.2025.
//


import SwiftUI

struct ChatSummaryView: View {
    @StateObject private var viewModel: ChatSummaryViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(messages: [Message]) {
        _viewModel = StateObject(wrappedValue: ChatSummaryViewModel(messages: messages))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Основное описание
                    mainSummarySection
                    
                    // Ключевые моменты
                    keyPointsSection
                    
                    // Информация о чате
                    chatInfoSection
                    
                    // Действия
                    actionsSection
                }
                .padding()
            }
            .navigationTitle("Описание обсуждения")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.generateSummary()
            }
            .overlay(
                Group {
                    if viewModel.isLoading {
                        ProgressView("Анализируем переписку...")
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                    }
                },
                alignment: .center
            )
            .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("Повторить") {
                    Task {
                        await viewModel.generateSummary()
                    }
                }
                Button("Отмена") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    private var mainSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.magnifyingglass")
                    .foregroundColor(.blue)
                Text("Основная тема")
                    .font(.headline)
                Spacer()
            }
            
            if let summary = viewModel.chatSummary {
                Text(summary)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else if !viewModel.isLoading {
                Text("Не удалось сгенерировать описание")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
    }
    
    private var keyPointsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundColor(.green)
                Text("Ключевые моменты")
                    .font(.headline)
                Spacer()
            }
            
            if !viewModel.keyPoints.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.keyPoints.indices, id: \.self) { index in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .foregroundColor(.green)
                                .font(.headline)
                            Text(viewModel.keyPoints[index])
                                .font(.body)
                            Spacer()
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            } else if !viewModel.isLoading {
                Text("Ключевые моменты не найдены")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
    }
    
    private var chatInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.orange)
                Text("Информация")
                    .font(.headline)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "message")
                    Text("Сообщений: \(viewModel.messages.count)")
                }
                
                HStack {
                    Image(systemName: "person.2")
                    Text("Участников: \(viewModel.uniqueParticipants.count)")
                }
                
                if let chatTitle = viewModel.chatTitle {
                    HStack {
                        Image(systemName: "tag")
                        Text("Название: \(chatTitle)")
                    }
                }
                
                HStack {
                    Image(systemName: "calendar")
                    Text("Период: \(viewModel.chatPeriod)")
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                // Действие: Поделиться описанием
                shareSummary()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Поделиться описанием")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBlue))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            Button(action: {
                Task {
                    await viewModel.regenerateSummary()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Обновить описание")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(8)
            }
            .disabled(viewModel.isLoading)
        }
    }
    
    private func shareSummary() {
        var shareText = "Описание обсуждения:\n\n"
        
        if let summary = viewModel.chatSummary {
            shareText += "\(summary)\n\n"
        }
        
        if !viewModel.keyPoints.isEmpty {
            shareText += "Ключевые моменты:\n"
            shareText += viewModel.keyPoints.map { "• \($0)" }.joined(separator: "\n")
        }
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true)
    }
}
