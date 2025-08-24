import SwiftUI

struct ImageCarouselView: View {
    let images: [Data]
    @State private var currentIndex = 0
    
    var body: some View {
        if !images.isEmpty {
            VStack {
                TabView(selection: $currentIndex) {
                    ForEach(images.indices, id: \.self) { index in
                        if let uiImage = UIImage(data: images[index]) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .tag(index)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .frame(height: 220)
                
                // Индикатор страниц
                if images.count > 1 {
                    HStack(spacing: 8) {
                        ForEach(images.indices, id: \.self) { index in
                            Circle()
                                .fill(currentIndex == index ? Color.orange : Color.gray) // Оранжевый цвет
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
}

#Preview {
    ImageCarouselView(images: ContentDataMock.sampleImages)
}
