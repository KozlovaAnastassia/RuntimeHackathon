//
//  MediaPicker.swift
//  RuntimeHackathon
//
//  Created by Анастасия Кузнецова on 23.08.2025.
//

import SwiftUI
import PhotosUI

struct MediaPicker: UIViewControllerRepresentable {
    var didPickImage: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: MediaPicker
        
        init(_ parent: MediaPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let result = results.first else {
                parent.didPickImage(nil)
                return
            }

            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.didPickImage(image as? UIImage)
                        // не вызываем picker.dismiss здесь
                    }
                }
            } else {
                parent.didPickImage(nil)
            }
        }
    }
}
