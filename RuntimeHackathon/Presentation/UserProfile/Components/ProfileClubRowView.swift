//
//  ClubRowView.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import SwiftUI

struct ProfileClubRowView: View {
    let club: Club
    let isCreator: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(club.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)

                    if isCreator {
                        Text("👑")
                            .font(.caption)
                    }
                }
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
            )
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    ProfileClubRowView(
        club: Club(id: UUID(), name: "Тестовый клуб", imageName: "star", isJoined: true, isCreator: false),
        isCreator: false
    )
}
