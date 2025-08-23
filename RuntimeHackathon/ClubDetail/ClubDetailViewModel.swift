//
//  ClubDetailViewModel.swift
//  RuntimeHackathon
//
//  Created by KOZLOVA Anastasia on 23.08.2025.
//

import SwiftUI

class ClubViewModel: ObservableObject {
    @Published var events: [ClubEvent] = []
    
    init() {
        loadEvents()
    }
    
    func createEvent(title: String, date: Date, location: String, description: String) {
        let newEvent = ClubEvent(title: title, date: date, location: location, description: description)
        events.append(newEvent)
        saveEvents()
        
        // Отладка
        print("Создано событие: \(title) на дату: \(date)")
        print("Всего событий: \(events.count)")
    }
    
    private func saveEvents() {
        if let encoded = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(encoded, forKey: "ClubEvents")
        }
    }
    
    private func loadEvents() {
        if let data = UserDefaults.standard.data(forKey: "ClubEvents"),
           let decoded = try? JSONDecoder().decode([ClubEvent].self, from: data) {
            events = decoded
        }
    }
}
