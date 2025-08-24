import SwiftUI

struct CreatorSection: View {
    @Binding var showingCreateEvent: Bool
    @Binding var showingCreateNews: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Button(action: {
                    showingCreateEvent = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.title2)
                            .foregroundColor(.orange) // Оранжевый цвет
                        
                        Text("Создать событие")
                            .font(.headline)
                            .foregroundColor(.orange) // Оранжевый цвет
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemOrange).opacity(0.1)) // Оранжевый цвет
                    .cornerRadius(12)
                }
                
                Button(action: {
                    showingCreateNews = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "newspaper")
                            .font(.title2)
                            .foregroundColor(.orange) // Оранжевый цвет
                        
                        Text("Создать новость")
                            .font(.headline)
                            .foregroundColor(.orange) // Оранжевый цвет
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemOrange).opacity(0.1)) // Оранжевый цвет
                    .cornerRadius(12)
                }
            }
        }
    }
}
