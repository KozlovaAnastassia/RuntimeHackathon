//
//  ClubsListView.swift
//  RuntimeHackathon
//
//  Created by Анастасия Кузнецова on 23.08.2025.
//

import SwiftUI
import CoreData

struct ClubsListScreen: View {
    @ObservedObject var viewModel: ClubsListViewModel
    @State private var selectedClub: Club?
    
    init(viewModel: ClubsListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Загрузка клубов...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    Text("Список клубов")
                        .font(.title2)
                        .padding(.top)

                    VStack(spacing: 12) {
                        ForEach(sortedClubs) { club in
                            ClubRowView(
                                club: club,
                                onJoin: { 
                                    Task { await viewModel.joinClub(club) }
                                },
                                onLeave: { 
                                    Task { await viewModel.leaveClub(club) }
                                }
                            )
                            .onTapGesture {
                                selectedClub = club
                            }
                        }
                    }
                    .padding(.top)
                }
            }

            Button(action: { viewModel.showAddClubForm.toggle() }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Добавить клуб")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding()
            }
        }
        .sheet(isPresented: $viewModel.showAddClubForm) {
            AddClubScreen(viewModel: viewModel)
        }
        .sheet(item: $selectedClub) { club in
            ClubDetailScreen(club: club)
                .environmentObject(ClubEventsService.shared)
        }
        .task {
            await viewModel.loadClubs()
        }
        .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private var sortedClubs: [Club] {
        viewModel.clubs.sorted { $0.isJoined && !$1.isJoined }
    }
}

#Preview {
    ClubsListScreen(viewModel: ClubsListViewModel())
        .withDataLayer()
}
