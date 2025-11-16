//
//  ProfileInfoSection.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import SwiftUI

struct ProfileInfoSectionView: View {
    let bio: String
    let isEditing: Bool
    let onEdit: () -> Void
    let onSave: () -> Void
    let onCancel: () -> Void
    @Binding var editedBio: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("О себе")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Button(action: isEditing ? onSave : onEdit) {
                    Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(isEditing ? .green : .orange)
                }
                .buttonStyle(PlainButtonStyle())

                if isEditing {
                    Button(action: onCancel) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            if isEditing {
                TextEditor(text: $editedBio)
                    .frame(height: 100)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            } else {
                if !bio.isEmpty {
                    Text(bio)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(4)
                } else {
                    Text("Добавьте информацию о себе")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ProfileInfoSectionView(
        bio: ProfileDataMock.sampleBio,
        isEditing: false,
        onEdit: {},
        onSave: {},
        onCancel: {},
        editedBio: .constant(ProfileDataMock.sampleBio)
    )
}
