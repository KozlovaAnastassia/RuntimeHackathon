//
//  CreatedClubsSection.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import SwiftUI

struct CreatedClubsSectionView: View {
    let clubs: [Club]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Создатель клубов")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                if clubs.count > 3 {
                    Text("еще \(clubs.count - 3)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            ForEach(clubs.prefix(3), id: \.id) { club in
                ProfileClubRowFullView(club: club)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    CreatedClubsSectionView(clubs: ProfileDataMock.sampleClubs)
}
