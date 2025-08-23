//
//  AddClubView.swift
//  RuntimeHackathon
//
//  Created by Анастасия Кузнецова on 23.08.2025.
//

import SwiftUI

struct AddClubView: View {
    @ObservedObject var viewModel: ClubsListViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    
    @State private var availableTags: [String] = ["Спорт", "Музыка", "Туризм", "Книги", "IT", "Искусство"]
    @State private var selectedTags: Set<String> = []
    
    private let maxDescriptionLength = 300

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Новый клуб")
                    .font(.title2)
                    .bold()
                
                // Название клуба
                TextField("Название клуба", text: $name)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                // Описание клуба
                VStack(alignment: .trailing, spacing: 4) {
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
                
                // Добавление картинки
                Button {
                    showImagePicker = true
                } label: {
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
                    .background(Color.blue.opacity(0.3)) // синяя заливка
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Теги
                VStack(alignment: .leading, spacing: 8) {
                    Text("Теги")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ChipsView(items: availableTags, selectedItems: $selectedTags)
                        .padding(.horizontal)
                }
                
                // Кнопка добавить клуб
                Button("Добавить клуб") {
                    let newClub = Club(
                        name: name,
                        imageName: "star",
                        isJoined: false,
                        localImagePath: nil // путь будет установлен внутри ViewModel
                    )
                    viewModel.addClub(newClub)
                    dismiss()
                }
                .disabled(name.isEmpty)
                .padding()
                .frame(maxWidth: .infinity)
                .background(name.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showImagePicker) {
            MediaPicker { image in
                selectedImage = image
                showImagePicker = false
            }
        }
    }
}
