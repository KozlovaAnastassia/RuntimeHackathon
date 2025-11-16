//
//  AddClubView.swift
//  RuntimeHackathon
//
//  Created by Анастасия Кузнецова on 23.08.2025.
//

import SwiftUI

struct AddClubScreen: View {
    @ObservedObject var viewModel: ClubsListViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    
    @State private var availableTags: [String] = ClubDataMock.availableTags
    @State private var selectedTags: Set<String> = []
    
    private let maxDescriptionLength = 300

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Новый клуб")
                    .font(.title2)
                    .bold()
                
                // Название клуба
                infoView
                // Добавление картинки
                imageView
                // Теги
                tegsView
                // Кнопка добавить клуб
                addButton
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showImagePicker) {
            MediaPicker { image in
                // просто сохраняем выбранное изображение, экран не закрывается
                if let img = image {
                    selectedImage = img
                }
                showImagePicker = false
            }
        }
    }
    
    private var infoView: some View {
      VStack(alignment: .trailing, spacing: 4) {
            // Название клуба
            TextField("Название клуба", text: $name)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 12)
            
            // Описание клуба
            TextEditor(text: $description)
                .frame(minHeight: 100, maxHeight: 200)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                .onChange(of: description) { newValue in
                    if description.count > maxDescriptionLength {
                        description = String(description.prefix(maxDescriptionLength))
                    }
                }
            
            Text("\(description.count)/\(maxDescriptionLength)")
                .foregroundColor(description.count > maxDescriptionLength ? .red : .gray)
                .font(.caption)
                .padding(.trailing, 20)
        }
    }
    
    private var imageView: some View {
        Button {
            showImagePicker = true
        } label: {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(12)
                    .padding(.horizontal)
            } else {
                HStack {
                    Text("Добавить обложку клуба")
                        .foregroundColor(.black)
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                }
                .padding()
                .background(Color.blue.opacity(0.3))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
    
    private var tegsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Теги")
                .font(.headline)
                .padding(.horizontal)
            
            ChipsView(items: availableTags, selectedItems: $selectedTags)
                .padding(.horizontal)
        }
    }
    
    private var addButton: some View {
        Button("Добавить клуб") {
            let club = Club(
                name: name,
                imageName: "star",
                isJoined: true,
                description: description,
                tags: Array(selectedTags),
                isCreator: true
            )
            Task {
                await viewModel.addClub(club, localImage: selectedImage)
                dismiss()
            }
        }
        .disabled(name.isEmpty)
        .padding()
        .frame(maxWidth: .infinity)
        .background(name.isEmpty ? Color.gray : Color.blue)
        .foregroundColor(.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    AddClubScreen(viewModel: ClubsListViewModel())
        .withDataLayer()
}
