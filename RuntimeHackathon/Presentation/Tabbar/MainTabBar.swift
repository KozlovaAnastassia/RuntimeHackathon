//
//  MainTabBar.swift
//  RuntimeHackathon
//
//  Created by Анастасия Кузнецова on 23.08.2025.
//

import SwiftUI

struct MainTabBar: View {
    @State private var selectedTab = 0
    @StateObject var storage = ClubsListViewModel()
    @ObservedObject var clubEventsService = ClubEventsService.shared
  private let chatDatabase = ChatDatabase.shared

    var body: some View {
        VStack {
            // Контент по вкладкам
            switch selectedTab {
            case 0:
                ClubsListView(viewModel: storage)
            case 1:
                CalendarView()
                    .environmentObject(clubEventsService)
            case 3:
              ChatListView(viewModel: ChatListViewModel(chats: storage.clubs.filter({ $0.isJoined }).map{ $0.chat }))
            case 4:
                UserProfileView(user: sampleUser)
            default:
                EmptyView()
            }
            
            // Кастомный таббар
            Spacer()
            HStack {
                Spacer()
                TabBarButton(index: 0,
                             systemImage: "list.bullet.circle",
                             textKey: "Клубы",
                             selectedTab: $selectedTab)
                Spacer()
                TabBarButton(index: 1,
                             systemImage: "calendar",
                             textKey: "Календарь",
                             selectedTab: $selectedTab)
                Spacer()
                TabBarButton(index: 3,
                             systemImage: "bubble.left.and.bubble.right",
                             textKey: "Чат",
                             selectedTab: $selectedTab)
                Spacer()
                TabBarButton(index: 4,
                             systemImage: "person",
                             textKey: "Профиль",
                             selectedTab: $selectedTab)
                Spacer()
            }
            .frame(height: 50)
            .background(Color.gray.opacity(0.2))
        }
    }
}



