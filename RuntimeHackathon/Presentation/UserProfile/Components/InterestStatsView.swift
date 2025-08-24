//
//  InterestStatsView.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import SwiftUI

struct InterestStatsView: View {
    let user: User

    var body: some View {
        HStack(spacing: 0) {
            StatItem(count: user.interests.count, label: "Интересов", icon: "heart.fill")
            Divider()
            StatItem(count: user.createdClubs.count, label: "Создано", icon: "plus.circle.fill")
            Divider()
            StatItem(count: user.joinedClubs.count, label: "Клубов", icon: "person.2.fill")
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct StatItem: View {
    let count: Int
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.orange)
            Text("\(count)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    InterestStatsView(user: sampleUser)
}
