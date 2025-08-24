//
//  ClubRowViewFull.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import SwiftUI

struct ProfileClubRowFullView: View {
    let club: Club

    var body: some View {
        HStack {
            // Иконка клуба
            Image(systemName: club.imageName)
                .font(.title3)
                .foregroundColor(.orange)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(club.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)

                    // Иконка создателя
                    if club.isCreator {
                        Text("👑")
                            .font(.caption)
                    }
                }
            }

            Spacer()

            // Количество участников (если есть)
            if let membersCount = getMembersCount() {
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("\(membersCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                )
            }
        }
        .padding(.vertical, 6)
    }

    private func getMembersCount() -> Int? {
        // Временно возвращаем случайное число или значение из модели если есть
        return Int.random(in: 10...50)
        // Или если у Club есть свойство membersCount:
        // return club.membersCount
    }
}

#Preview {
    ProfileClubRowFullView(
        club: ProfileClubRowMock.sampleClubCreator
    )
}
