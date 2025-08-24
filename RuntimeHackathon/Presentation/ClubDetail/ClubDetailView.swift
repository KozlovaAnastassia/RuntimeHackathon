//
//  ClubDetailView.swift
//  RuntimeHackathon
//
//  Created by KOZLOVA Anastasia on 23.08.2025.
//

import SwiftUI

struct ClubDetailView: View {
    let club: Club // Принимаем модель Club
    @StateObject private var clubViewModel: ClubViewModel
    @State private var isCreator: Bool
    @State private var showingCreateEvent = false
    @State private var showingCreateNews = false
    @State private var calendarReloadTrigger = UUID()
    @State private var selectedDateFilter: DateFilter = .all
    @Environment(\.presentationMode) var presentationMode
    
    init(club: Club) {
        self.club = club
        // Создаем ViewModel для конкретного клуба
      self._clubViewModel = StateObject(wrappedValue: ClubViewModel(clubId: club.id, isCreator: club.isCreator))
        // Инициализируем isCreator значением из модели клуба
        self._isCreator = State(initialValue: club.isCreator)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Заголовок клуба с данными из модели Club
                ClubHeaderSection(club: club)
                
                // Секция для создателя клуба
                if isCreator {
                    CreatorSection(
                        showingCreateEvent: $showingCreateEvent,
                        showingCreateNews: $showingCreateNews
                    )
                }
                
                // Информация о клубе
                ClubInfoSection()
                
                // Встроенный календарь
                CalendarSection(
                    clubEvents: clubViewModel.events,
                    reloadTrigger: calendarReloadTrigger
                )
                .environmentObject(ClubEventsService.shared)
                
                // Фильтр новостей
                DateFilterSection(selectedFilter: $selectedDateFilter)
                
                // Лента новостей (события + новости)
                NewsFeedSection(
                    events: clubViewModel.events,
                    newsItems: clubViewModel.newsItems,
                    isCreator: isCreator,
                    dateFilter: selectedDateFilter,
                    onDeleteNews: { newsId in
                        clubViewModel.deleteNews(id: newsId)
                    }
                )
            }
            .padding()
        }
        .navigationTitle(club.name) // Используем имя клуба из модели
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(trailing: Button("Закрыть") {
            presentationMode.wrappedValue.dismiss()
        })
        .sheet(isPresented: $showingCreateEvent) {
            CreateEventView(
                clubViewModel: clubViewModel,
                onEventCreated: {
                    calendarReloadTrigger = UUID()
                }
            )
        }
        .sheet(isPresented: $showingCreateNews) {
            CreateNewsView(clubViewModel: clubViewModel)
        }
    }
}

#Preview {
    ClubDetailView(club: Club(
        id: UUID(),
        name: "Тестовый клуб",
        imageName: "sportscourt",
        isJoined: true,
        isCreator: true
    ))
}
