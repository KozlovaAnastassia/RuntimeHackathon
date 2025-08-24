//
//  ClubsListViewModel.swift
//  RuntimeHackathon
//
//  Created by Анастасия Кузнецова on 23.08.2025.
//

import Foundation
import UIKit

@MainActor
final class ClubsListViewModel: ObservableObject {
    @Published var clubs: [Club] = []
    @Published var showAddClubForm: Bool = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    private let repository: ClubRepository
    
    init(repository: ClubRepository = DataLayerIntegration.shared.clubRepository) {
        self.repository = repository
    }
    
    func loadClubs() async {
        isLoading = true
        errorMessage = nil
        
        do {
            clubs = try await repository.getAllClubs()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func searchClubs() async {
        guard !searchText.isEmpty else {
            await loadClubs()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            clubs = try await repository.searchClubs(query: searchText)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func addClub(_ club: Club, localImage: UIImage? = nil) async {
        var path: String? = nil
        if let image = localImage, let data = image.jpegData(compressionQuality: 0.8) {
            let filename = UUID().uuidString + ".jpg"
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(filename)
            try? data.write(to: url)
            path = url.path
        }

        var newClub = club
        newClub.localImagePath = path
        
        do {
            try await repository.saveClub(newClub)
            await loadClubs() // Перезагружаем список
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func joinClub(_ club: Club) async {
        do {
            let updatedClub = try await repository.joinClub(club.id)
            if let index = clubs.firstIndex(where: { $0.id == club.id }) {
                clubs[index] = updatedClub
            }
            clubs.sort { $0.isJoined && !$1.isJoined }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func leaveClub(_ club: Club) async {
        do {
            let updatedClub = try await repository.leaveClub(club.id)
            if let index = clubs.firstIndex(where: { $0.id == club.id }) {
                clubs[index] = updatedClub
            }
            clubs.sort { $0.isJoined && !$1.isJoined }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
