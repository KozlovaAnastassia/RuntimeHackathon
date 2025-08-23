//
//  ClubsListViewModel.swift
//  RuntimeHackathon
//
//  Created by Анастасия Кузнецова on 23.08.2025.
//

import Foundation
import UIKit

final class ClubsListViewModel: ObservableObject {
    @Published var clubs: [Club] = [
        Club(name: "Red Club", imageName: "sportscourt", isJoined: true, isCreator: true),
        Club(name: "Blue Club", imageName: "figure.walk", isJoined: false, isCreator: false),
        Club(name: "Green Club", imageName: "leaf", isJoined: false, isCreator: false)
    ]
    @Published var showAddClubForm: Bool = false

    func addClub(_ club: Club, localImage: UIImage? = nil) {
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
        clubs.append(newClub)
    }

    func joinClub(_ club: Club) {
        if let index = clubs.firstIndex(where: { $0.id == club.id }) {
            clubs[index].isJoined = true
            clubs.sort { $0.isJoined && !$1.isJoined }
        }
    }

    func leaveClub(_ club: Club) {
        if let index = clubs.firstIndex(where: { $0.id == club.id }) {
            clubs[index].isJoined = false
            clubs.sort { $0.isJoined && !$1.isJoined }
        }
    }
}
