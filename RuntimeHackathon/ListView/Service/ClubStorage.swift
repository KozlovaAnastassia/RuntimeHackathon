//
//  ClubStorage.swift
//  RuntimeHackathon
//
//  Created by Анастасия Кузнецова on 23.08.2025.
//

import SwiftUI

final class ClubsStorage: ObservableObject {
    @Published var clubs: [Club] = []
    
    // Директория для локальных картинок
    private let imagesDirectory: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("ClubImages")
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }()
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        // Моковые клубы при старте
        let mockClubs = [
            Club(name: "Red Club", imageName: "sportscourt", isJoined: true),
            Club(name: "Blue Club", imageName: "figure.walk", isJoined: false),
            Club(name: "Green Club", imageName: "leaf", isJoined: false)
        ]
        self.clubs = mockClubs
    }
    
    func addClub(name: String, imageName: String, localImage: UIImage? = nil) {
        var localImagePath: String? = nil
        if let image = localImage, let data = image.jpegData(compressionQuality: 0.8) {
            let filename = UUID().uuidString + ".jpg"
            let url = imagesDirectory.appendingPathComponent(filename)
            try? data.write(to: url)
            localImagePath = url.path
        }
        
        let newClub = Club(name: name, imageName: imageName, isJoined: false, localImagePath: localImagePath)
        clubs.append(newClub)
    }
    
    func joinClub(_ club: Club) {
        if let index = clubs.firstIndex(where: { $0.id == club.id }) {
            clubs[index].isJoined = true
            clubs.sort { $0.isJoined && !$1.isJoined }
        }
    }
}
