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
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    
    init(viewModel: ClubsListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            // Поле ввода названия
            TextField("Название клуба", text: $name)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            
            // Картинка
            VStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .onTapGesture { showImagePicker = true }
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            VStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("Добавить изображение")
                                    .foregroundColor(.gray)
                            }
                        )
                        .padding(.horizontal)
                        .onTapGesture { showImagePicker = true }
                }
            }
            
            Spacer()
            
            Button("Добавить клуб") {
                viewModel.addClub(name: name, imageName: "star", localImage: selectedImage)
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
        .sheet(isPresented: $showImagePicker) {
            MediaPicker { image in
                if let img = image {
                    selectedImage = img
                }
                showImagePicker = false
            }
        }
    }
}
