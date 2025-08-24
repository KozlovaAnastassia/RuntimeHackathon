import SwiftUI
import PhotosUI

struct CreateNewsView: View {
    @ObservedObject var clubViewModel: ClubViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var newsTitle = ""
    @State private var newsDescription = ""
    @State private var selectedImages: [UIImage] = []
    @State private var photoPickerItems: [PhotosPickerItem] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Поле заголовка
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Заголовок")
                            .font(.headline)
                        
                        TextField("Введите заголовок новости", text: $newsTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // Выбор изображений
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Изображения")
                            .font(.headline)
                        
                        PhotosPicker(selection: $photoPickerItems, maxSelectionCount: 10, matching: .images) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                Text("Выбрать фотографии")
                            }
                        }
                        .onChange(of: photoPickerItems) { items in
                            loadSelectedImages(from: items)
                        }
                        
                        // Превью выбранных изображений
                        if !selectedImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(selectedImages.indices, id: \.self) { index in
                                        Image(uiImage: selectedImages[index])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipped()
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Поле описания
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Описание")
                            .font(.headline)
                        
                        TextEditor(text: $newsDescription)
                            .frame(height: 150)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Новая новость")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Опубликовать") {
                        createNews()
                    }
                    .disabled(newsTitle.isEmpty)
                }
            }
        }
    }
    
    private func loadSelectedImages(from items: [PhotosPickerItem]) {
        Task {
            selectedImages.removeAll()
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImages.append(uiImage)
                }
            }
        }
    }
    
    private func createNews() {
        let imageData = selectedImages.compactMap { $0.pngData() }
        clubViewModel.createNews(
            title: newsTitle,
            description: newsDescription,
            imagesData: imageData
        )
        presentationMode.wrappedValue.dismiss()
    }
}
