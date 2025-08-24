//
//  SimpleEventDetailScreen.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import SwiftUI

struct SimpleEventDetailScreen: View {
    let event: CalendarEvent
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Цветовая полоса
                    Rectangle()
                        .fill(event.color)
                        .frame(height: 4)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Заголовок
                        Text(event.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        // Описание
                        Text(event.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        // Местоположение
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.red)
                            Text("Место: \(event.location)")
                        }
                        
                        // Дата и время
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            Text("Дата: \(formatDate(event.date))")
                        }
                        
                        // Продолжительность
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.green)
                            Text("Продолжительность: \(formatDuration(event.durationInMinutes))")
                        }
                        
                        // Клуб (если событие из клуба)
                        if let clubName = event.clubName {
                            HStack {
                                Image(systemName: "person.3.fill")
                                    .foregroundColor(.purple)
                                Text("Клуб: \(clubName)")
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .navigationTitle("Детали мероприятия")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Закрыть") {
                    dismiss()
                },
                trailing: Button("Записаться") {
                    // Здесь будет логика записи
                }
                .foregroundColor(.blue)
            )
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return "\(hours) ч \(remainingMinutes) мин"
        } else {
            return "\(remainingMinutes) мин"
        }
    }
}

#Preview {
    SimpleEventDetailScreen(
        event: CalendarEvent(
            id: UUID(),
            title: "Тестовое событие",
            date: Date(),
            location: "Тестовое место",
            description: "Описание тестового события",
            color: .blue
        )
    )
}
