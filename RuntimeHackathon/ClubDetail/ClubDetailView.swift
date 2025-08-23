//
//  ClubDetailView.swift
//  RuntimeHackathon
//
//  Created by KOZLOVA Anastasia on 23.08.2025.
//

import SwiftUI

struct ClubDetailView: View {
    @StateObject private var clubViewModel = ClubViewModel()
    @State private var isCreator = true
    @State private var showingCreateEvent = false
    @State private var calendarReloadTrigger = UUID() // Для перезагрузки календаря
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Секция для создателя клуба
                if isCreator {
                    CreatorSection(
                        showingCreateEvent: $showingCreateEvent
                    )
                }
                
                // Информация о клубе
                ClubInfoSection()
                
                // Встроенный календарь
                CalendarSection(
                    clubEvents: clubViewModel.events,
                    reloadTrigger: calendarReloadTrigger
                )
                
                // Лента новостей
                NewsFeedSection(events: clubViewModel.events)
            }
            .padding()
        }
        .navigationTitle("Клуб по интересам")
        .sheet(isPresented: $showingCreateEvent) {
            CreateEventView(
                clubViewModel: clubViewModel,
                onEventCreated: {
                    // Принудительно перезагружаем календарь
                    calendarReloadTrigger = UUID()
                }
            )
        }
    }
}

// MARK: - Секция календаря
struct CalendarSection: View {
    let clubEvents: [ClubEvent]
    let reloadTrigger: UUID // Для принудительной перезагрузки
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Календарь событий")
                .font(.title2)
                .fontWeight(.bold)
            
            // Встроенный календарь с принудительной перезагрузкой
            CalendarView(clubEvents: clubEvents)
                .frame(height: 400)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
                .id(reloadTrigger) // Принудительная перезагрузка
        }
    }
}

// MARK: - Экран создания события
struct CreateEventView: View {
    @ObservedObject var clubViewModel: ClubViewModel
    let onEventCreated: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var eventTitle = ""
    @State private var eventDate = Date()
    @State private var eventDescription = ""
    @State private var eventLocation = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Название события") {
                    TextField("Введите название", text: $eventTitle)
                }
                
                Section("Дата события") {
                    DatePicker("Выберите дату", selection: $eventDate)
                }
                
                Section("Место проведения") {
                    TextField("Введите место", text: $eventLocation)
                }
                
                Section("Описание") {
                    TextEditor(text: $eventDescription)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Новое событие")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Создать") {
                        createEvent()
                    }
                    .disabled(eventTitle.isEmpty)
                }
            }
        }
    }
    
    private func createEvent() {
        clubViewModel.createEvent(
            title: eventTitle,
            date: eventDate,
            location: eventLocation,
            description: eventDescription
        )
        
        // Уведомляем о создании события
        onEventCreated()
        
        presentationMode.wrappedValue.dismiss()
    }
}

// Остальные секции остаются без изменений...

struct CreatorSection: View {
    @Binding var showingCreateEvent: Bool
    
    var body: some View {
        Button(action: {
            showingCreateEvent = true
        }) {
            VStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                
                Text("Создать событие")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBlue).opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct ClubInfoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("О клубе")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Добро пожаловать в наш клуб любителей фотографии! Мы встречаемся каждую неделю, чтобы делиться опытом, обсуждать техники съемки и проводить мастер-классы.")
                .font(.body)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("📍 Место встречи")
                        .font(.headline)
                    Text("ул. Ленина, 15, каб. 301")
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("⏰ Время встреч")
                        .font(.headline)
                    Text("Каждую среду в 18:00")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct NewsFeedSection: View {
    let events: [ClubEvent]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Новости клуба")
                .font(.title2)
                .fontWeight(.bold)
            
            if events.isEmpty {
                Text("Нет событий")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(events.sorted(by: { $0.date > $1.date })) { event in // Сортируем по дате события
                    NewsCardView(
                        newsItem: NewsItem(
                            image: "calendar.badge.plus",
                            title: event.title,
                            date: formatDate(event.date), // Используем дату события, а не создания
                            description: event.description
                        )
                    )
                    
                    Divider()
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

struct NewsCardView: View {
    let newsItem: NewsItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: newsItem.image)
                .font(.title2)
                .frame(width: 60, height: 60)
                .background(Color.blue.opacity(0.2))
                .clipShape(Circle())
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(newsItem.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(newsItem.date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(newsItem.description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
