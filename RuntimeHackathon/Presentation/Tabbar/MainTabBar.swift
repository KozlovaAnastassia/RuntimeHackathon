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
                ClubsListScreen(viewModel: storage)
            case 1:
                CalendarScreen()
                    .environmentObject(clubEventsService)
            case 3:
              ChatListScreen(viewModel: ChatListViewModel())
            case 4:
                UserProfileScreen(user: ProfileDataMock.sampleUser)
            default:
                EmptyView()
            }
            
            // Кастомный таббар
            Spacer()
            HStack {
                Spacer()
                TabBarButtonView(index: 0,
                             systemImage: "list.bullet.circle",
                             textKey: "Клубы",
                             selectedTab: $selectedTab)
                Spacer()
                TabBarButtonView(index: 1,
                             systemImage: "calendar",
                             textKey: "Календарь",
                             selectedTab: $selectedTab)
                Spacer()
                TabBarButtonView(index: 3,
                             systemImage: "bubble.left.and.bubble.right",
                             textKey: "Чат",
                             selectedTab: $selectedTab)
                Spacer()
                TabBarButtonView(index: 4,
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

#Preview {
    MainTabBar()
        .withDataLayer()
}



