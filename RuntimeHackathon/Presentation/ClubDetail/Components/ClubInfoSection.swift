import SwiftUI

struct ClubInfoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("О клубе")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Добро пожаловать в наш клуб любителей фотографии! Мы встречаемся каждую неделю, чтобы делиться опытом, обсуждать техники съемки и проводить мастер-классы.")
                .font(.body)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("📍 Место встречи")
                        .font(.headline)
                    Text("ул. Ленина, 15, каб. 301")
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("⏰ Время встреч")
                        .font(.headline)
                    Text("Каждую среду в 18:00")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ClubInfoSection()
}
