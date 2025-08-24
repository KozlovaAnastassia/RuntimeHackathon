import SwiftUI

struct ClubHeaderSectionView: View {
    let club: Club
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                // Изображение клуба - используем данные из модели
                if let localImagePath = club.localImagePath,
                   let image = UIImage(contentsOfFile: localImagePath) {
                    // Если есть локальный путь к изображению
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    // Иначе используем imageName из модели
                    Image(systemName: club.imageName)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.orange) // Оранжевый цвет
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(club.name) // Имя клуба из модели
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 12) {
                        // Статус участия из модели
                        HStack {
                            if club.isJoined {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.orange)
                                Text("Вы участник")
                                .foregroundColor(.orange)
                                    .font(.caption)
                            } else {
                                Image(systemName: "person.fill.badge.plus")
                                    .foregroundColor(.orange) // Оранжевый цвет
                                Text("Присоединиться")
                                    .foregroundColor(.orange) // Оранжевый цвет
                                    .font(.caption)
                            }
                        }
                        
                        Spacer()
                        
                        // Количество участников (можно добавить в модель Club)
                        HStack {
                            Image(systemName: "person.2.fill")
                            Text("0 участников") // Замените на реальное значение из модели
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    ClubHeaderSectionView(club: ClubDataMock.testClub)
}
