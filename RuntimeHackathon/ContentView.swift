//
//  ContentView.swift
//  RuntimeHackathon
//
//  Created by KOZLOVA Anastasia on 22.08.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .font(.system(size: 60))
                
                Text("Добро пожаловать!")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text("Runtime Hackathon")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Кнопка для открытия календаря
                NavigationLink(destination: CalendarView()) {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.title2)
                        Text("Открыть календарь")
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Главная")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ContentView()
}
