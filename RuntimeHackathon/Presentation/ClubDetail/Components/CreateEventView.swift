import SwiftUI

struct CreateEventView: View {
    @ObservedObject var clubViewModel: ClubViewModel
    let onEventCreated: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var eventTitle = ""
    @State private var eventDate = Date()
    @State private var eventDescription = ""
    @State private var eventLocation = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Название события") {
                    TextField("Введите название", text: $eventTitle)
                }
                
                Section("Дата события") {
                    DatePicker("Выберите дату", selection: $eventDate)
                }
                
                Section("Место проведения") {
                    TextField("Введите место", text: $eventLocation)
                }
                
                Section("Описание") {
                    TextEditor(text: $eventDescription)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Новое событие")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Создать") {
                        createEvent()
                    }
                    .disabled(eventTitle.isEmpty)
                }
            }
        }
    }
    
    private func createEvent() {
        clubViewModel.createEvent(
            title: eventTitle,
            date: eventDate,
            location: eventLocation,
            description: eventDescription
        )
        
        onEventCreated()
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    CreateEventView(
        clubViewModel: ClubViewModel(clubId: UUID(), isCreator: true),
        onEventCreated: {}
    )
}
