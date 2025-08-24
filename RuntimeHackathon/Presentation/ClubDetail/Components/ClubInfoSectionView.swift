import SwiftUI

struct ClubInfoSectionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("О клубе")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(ContentDataMock.clubInfoStrings["О клубе"] ?? "")
                .font(.body)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Место встречи")
                        .font(.headline)
                    Text("Главный зал")
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Время встречи")
                        .font(.headline)
                    Text("Каждый вторник в 19:00")
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
    ClubInfoSectionView()
}
