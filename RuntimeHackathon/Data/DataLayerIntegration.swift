import Foundation
import SwiftUI

// MARK: - Интеграция слоя данных с приложением

class DataLayerIntegration {
    static let shared = DataLayerIntegration()
    
    // MARK: - Repository экземпляры
    let clubRepository: ClubRepository
    let userRepository: UserRepository
    let calendarRepository: CalendarRepository
    
    private init() {
        // Инициализируем базу данных
        DatabaseInitializer.shared.initializeDatabase()
        
        // Создаем Repository экземпляры
        self.clubRepository = ClubRepository()
        self.userRepository = UserRepository()
        self.calendarRepository = CalendarRepository()
        
        print("Слой данных инициализирован")
    }
    
    // MARK: - Получение статистики
    func getStatistics() -> DatabaseStatistics {
        return DatabaseInitializer.shared.getDatabaseStatistics()
    }
    
    // MARK: - Очистка данных
    func clearAllData() {
        DatabaseInitializer.shared.clearDatabase()
    }
    
    // MARK: - Экспорт/Импорт
    func exportData() -> Data? {
        return DatabaseInitializer.shared.exportDatabase()
    }
    
    func importData(from data: Data) {
        DatabaseInitializer.shared.importDatabase(from: data)
    }
}

// MARK: - Environment Key для Repository
struct ClubRepositoryKey: EnvironmentKey {
    static let defaultValue: ClubRepository = ClubRepository()
}

struct UserRepositoryKey: EnvironmentKey {
    static let defaultValue: UserRepository = UserRepository()
}

struct CalendarRepositoryKey: EnvironmentKey {
    static let defaultValue: CalendarRepository = CalendarRepository()
}

// MARK: - Environment Values расширения
extension EnvironmentValues {
    var clubRepository: ClubRepository {
        get { self[ClubRepositoryKey.self] }
        set { self[ClubRepositoryKey.self] = newValue }
    }
    
    var userRepository: UserRepository {
        get { self[UserRepositoryKey.self] }
        set { self[UserRepositoryKey.self] = newValue }
    }
    
    var calendarRepository: CalendarRepository {
        get { self[CalendarRepositoryKey.self] }
        set { self[CalendarRepositoryKey.self] = newValue }
    }
}

// MARK: - View расширения для удобного доступа к Repository
extension View {
    func withDataLayer() -> some View {
        self
            .environment(\.clubRepository, DataLayerIntegration.shared.clubRepository)
            .environment(\.userRepository, DataLayerIntegration.shared.userRepository)
            .environment(\.calendarRepository, DataLayerIntegration.shared.calendarRepository)
    }
}

// MARK: - Обновленные ViewModels с использованием Repository

// MARK: - ClubsListViewModel с Repository
class UpdatedClubsListViewModel: ObservableObject {
    @Published var clubs: [Club] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    private let repository: ClubRepository
    
    init(repository: ClubRepository) {
        self.repository = repository
    }
    
    @MainActor
    func loadClubs() async {
        isLoading = true
        errorMessage = nil
        
        do {
            clubs = try await repository.getAllClubs()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func searchClubs() async {
        guard !searchText.isEmpty else {
            await loadClubs()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            clubs = try await repository.searchClubs(query: searchText)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func joinClub(_ club: Club) async {
        do {
            let updatedClub = try await repository.joinClub(club.id)
            if let index = clubs.firstIndex(where: { $0.id == club.id }) {
                clubs[index] = updatedClub
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func leaveClub(_ club: Club) async {
        do {
            let updatedClub = try await repository.leaveClub(club.id)
            if let index = clubs.firstIndex(where: { $0.id == club.id }) {
                clubs[index] = updatedClub
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - UserProfileViewModel с Repository
class UpdatedUserProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    @MainActor
    func loadProfile(userId: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            user = try await repository.getUser(by: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func updateProfile(_ updatedUser: User) async {
        do {
            try await repository.updateProfile(updatedUser)
            user = updatedUser
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func addInterest(_ interest: Interest) async {
        guard let userId = user?.id else { return }
        
        do {
            try await repository.addInterest(interest, to: userId)
            await loadProfile(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func removeInterest(_ interest: Interest) async {
        guard let userId = user?.id else { return }
        
        do {
            try await repository.removeInterest(interest, from: userId)
            await loadProfile(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - CalendarViewModel с Repository
class UpdatedCalendarViewModel: ObservableObject {
    @Published var events: [CalendarEvent] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedDate = Date()
    
    private let repository: CalendarRepository
    
    init(repository: CalendarRepository) {
        self.repository = repository
    }
    
    @MainActor
    func loadEvents(for date: Date) async {
        isLoading = true
        errorMessage = nil
        
        do {
            events = try await repository.getEvents(for: date)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadAllEvents() async {
        isLoading = true
        errorMessage = nil
        
        do {
            events = try await repository.getAllEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func createEvent(_ event: CalendarEvent) async {
        do {
            try await repository.saveEvent(event)
            await loadEvents(for: event.date)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func deleteEvent(_ event: CalendarEvent) async {
        do {
            try await repository.deleteEvent(event)
            await loadEvents(for: selectedDate)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func loadWeekEvents() async {
        isLoading = true
        errorMessage = nil
        
        do {
            events = try await repository.getWeekEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadUpcomingEvents() async {
        isLoading = true
        errorMessage = nil
        
        do {
            events = try await repository.getUpcomingEvents(limit: 10)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

// MARK: - Пример использования в SwiftUI View
struct ExampleView: View {
    @Environment(\.clubRepository) var clubRepository
    @StateObject private var viewModel: UpdatedClubsListViewModel
    
    init() {
        // Инициализируем ViewModel с Repository из Environment
        let repository = DataLayerIntegration.shared.clubRepository
        _viewModel = StateObject(wrappedValue: UpdatedClubsListViewModel(repository: repository))
    }
    
    var body: some View {
        NavigationView {
            List(viewModel.clubs) { club in
                VStack(alignment: .leading) {
                    Text(club.name)
                        .font(.headline)
                    Text(club.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(club.isJoined ? "Покинуть" : "Присоединиться") {
                        Task {
                            if club.isJoined {
                                await viewModel.leaveClub(club)
                            } else {
                                await viewModel.joinClub(club)
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
            .navigationTitle("Клубы")
            .searchable(text: $viewModel.searchText)
            .onSubmit(of: .search) {
                Task {
                    await viewModel.searchClubs()
                }
            }
            .task {
                await viewModel.loadClubs()
            }
            .refreshable {
                await viewModel.loadClubs()
            }
        }
        .withDataLayer() // Добавляем слой данных в Environment
    }
}

// MARK: - Интеграция с основным приложением
extension RuntimeHackathonApp {
    func setupDataLayer() {
        // Инициализируем слой данных при запуске приложения
        _ = DataLayerIntegration.shared
        
        // Выводим статистику базы данных
        let statistics = DataLayerIntegration.shared.getStatistics()
        print(statistics.description)
    }
}
