import Foundation
import UIKit

// MARK: - Моковые данные для ImageCarouselView
struct ImageCarouselMock {
    static let sampleImages: [Data] = {
        // Создаем простые цветные изображения для тестирования
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple]
        var images: [Data] = []
        
        for color in colors {
            let size = CGSize(width: 300, height: 200)
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            
            // Рисуем цветной прямоугольник
            color.setFill()
            UIRectFill(CGRect(origin: .zero, size: size))
            
            // Добавляем текст для идентификации
            let text = "Тестовое изображение"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            text.draw(in: textRect, withAttributes: attributes)
            
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    images.append(imageData)
                }
            }
            
            UIGraphicsEndImageContext()
        }
        
        return images
    }()
    
    static let emptyImages: [Data] = []
}
