//
//  ClubsListView.swift
//  RuntimeHackathon
//
//  Created by Анастасия Кузнецова on 23.08.2025.
//

import SwiftUI

struct ClubsListView: View {
    @ObservedObject var viewModel: ClubsListViewModel
    
    init(viewModel: ClubsListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            ScrollView {
                Text("Список клубов")
                    .font(.title2)
                    .padding(.top)

                VStack(spacing: 12) {
                    ForEach(sortedClubs) { club in
                        ClubRow(
                            club: club,
                            onJoin: { withAnimation(.spring()) { viewModel.joinClub(club) } },
                            onLeave: { withAnimation(.spring()) { viewModel.leaveClub(club) } }
                        )
                    }
                }
                .padding(.top)
            }

            Button(action: { viewModel.showAddClubForm.toggle() }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Добавить клуб")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding()
            }
        }
        .sheet(isPresented: $viewModel.showAddClubForm) {
            AddClubView(viewModel: viewModel)
        }
    }
    
    private var sortedClubs: [Club] {
        viewModel.clubs.sorted { $0.isJoined && !$1.isJoined }
    }
}
