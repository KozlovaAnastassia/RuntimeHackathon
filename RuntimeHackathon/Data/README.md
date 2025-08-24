# Архитектура данных RuntimeHackathon

## Обзор

Данная архитектура реализует паттерн Repository с синхронизацией между локальной базой данных (Core Data) и удаленным API. Это обеспечивает офлайн-работу приложения и плавную синхронизацию данных.

## Структура папок

```
Data/
├── Database/           # Локальная база данных (Core Data)
│   ├── DatabaseManager.swift
│   ├── ClubDatabase.swift
│   ├── UserDatabase.swift
│   ├── CalendarDatabase.swift
│   └── RuntimeHackathonDB.xcdatamodeld/
├── Api/               # API клиенты и сервисы
│   ├── ApiClient.swift
│   ├── ClubApiService.swift
│   ├── UserApiService.swift
│   ├── CalendarApiService.swift
│   └── swagger.yaml
├── Services/          # Бизнес-логика сервисов
│   ├── ChatService.swift
│   ├── ClubEventsService.swift
│   ├── MediaPicker.swift
│   └── YandexGPTService.swift
└── Mock/              # Моковые данные

Domain/
└── Repository/        # Repository слой
    ├── RepositoryProtocol.swift
    ├── ClubRepository.swift
    ├── UserRepository.swift
    ├── ChatRepository.swift
    ├── NewsRepository.swift
    └── CalendarRepository.swift
```

## Компоненты

### 1. База данных (Core Data)

#### DatabaseManager
- Центральный менеджер для работы с Core Data
- Управляет persistent container
- Предоставляет методы для сохранения и очистки данных

#### Специализированные базы данных
- **ClubDatabase**: Работа с клубами и связанными чатами
- **UserDatabase**: Работа с пользователями и их интересами
- **CalendarDatabase**: Работа с календарными событиями
- **NewsDatabase**: Работа с новостями клубов

### 2. API слой

#### ApiClient
- Базовый HTTP клиент
- Обработка ошибок и статус кодов
- Поддержка GET, POST, PUT, DELETE запросов
- Кастомные кодировщики для работы с датами

#### API сервисы
- **ClubApiService**: CRUD операции для клубов
- **UserApiService**: Управление профилем пользователя
- **CalendarApiService**: Работа с календарными событиями
- **ChatApiService**: Управление чатами и сообщениями
- **NewsApiService**: Работа с новостями клубов

#### Swagger документация
- Полная спецификация API
- Описание всех эндпоинтов и моделей данных
- Готова для генерации серверного кода

### 3. Repository слой

#### Протоколы
- **ClubRepositoryProtocol**: Интерфейс для работы с клубами
- **UserRepositoryProtocol**: Интерфейс для работы с пользователями
- **CalendarRepositoryProtocol**: Интерфейс для работы с событиями
- **ChatRepositoryProtocol**: Интерфейс для работы с чатами
- **NewsRepositoryProtocol**: Интерфейс для работы с новостями

#### Реализации
Каждый Repository реализует следующую логику:
1. **Приоритет локальных данных**: Сначала возвращает данные из базы
2. **Асинхронная синхронизация**: В фоне обновляет данные из API
3. **Fallback механизм**: При недоступности API использует локальные данные
4. **Двусторонняя синхронизация**: Изменения сохраняются локально и отправляются в API

## Принципы работы

### 1. Синхронизация данных
```swift
func getAllClubs() async throws -> [Club] {
    // 1. Возвращаем локальные данные немедленно
    let localClubs = database.getAllClubs()
    
    // 2. Асинхронно обновляем из API
    Task {
        let apiClubs = try await apiService.getAllClubs()
        for club in apiClubs {
            database.saveClub(club)
        }
    }
    
    return localClubs
}
```

### 2. Обработка ошибок
- API ошибки не блокируют работу приложения
- Локальные данные всегда доступны
- Логирование ошибок для отладки

### 3. Оптимизация производительности
- Кэширование в Core Data
- Асинхронные операции
- Минимизация сетевых запросов

## Использование в ViewModels

### Базовый шаблон ViewModel
```swift
@MainActor
class MyViewModel: ObservableObject {
    @Published var data: [MyModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: MyRepository
    
    init(repository: MyRepository = DataLayerIntegration.shared.myRepository) {
        self.repository = repository
    }
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            data = try await repository.getAllData()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
```

### Примеры обновленных ViewModels

#### ClubsListViewModel
```swift
@MainActor
final class ClubsListViewModel: ObservableObject {
    @Published var clubs: [Club] = []
    @Published var showAddClubForm: Bool = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    private let repository: ClubRepository
    
    init(repository: ClubRepository = DataLayerIntegration.shared.clubRepository) {
        self.repository = repository
    }
    
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
    
    func joinClub(_ club: Club) async {
        do {
            let updatedClub = try await repository.joinClub(club.id)
            if let index = clubs.firstIndex(where: { $0.id == club.id }) {
                clubs[index] = updatedClub
            }
            clubs.sort { $0.isJoined && !$1.isJoined }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

#### UserProfileViewModel
```swift
@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: UserRepository
    
    init(repository: UserRepository = DataLayerIntegration.shared.userRepository) {
        self.repository = repository
    }
    
    func loadProfile(userId: UUID) async {
        isLoading = true
        do {
            user = try await repository.getUser(by: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func saveProfileSection() async {
        guard var currentUser = user else { return }
        do {
            currentUser.name = editedName
            try await repository.updateProfile(currentUser)
            user = currentUser
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

#### CalendarViewModel
```swift
@MainActor
class CalendarViewModel: ObservableObject {
    @Published var events: [CalendarEvent] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: CalendarRepository
    
    init(repository: CalendarRepository = DataLayerIntegration.shared.calendarRepository) {
        self.repository = repository
        updateCalendarDays()
    }
    
    func loadEvents() async {
        isLoading = true
        do {
            events = try await repository.getAllEvents()
            updateCalendarDays()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
```

#### ChatListViewModel
```swift
@MainActor
class ChatListViewModel: ObservableObject {
    @Published var chats: [ChatInfo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: ChatRepository
    
    init(repository: ChatRepository = DataLayerIntegration.shared.chatRepository) {
        self.repository = repository
    }
    
    func loadChats() async {
        isLoading = true
        do {
            chats = try await repository.getChats()
            chats.sort { $0.lastMessageTime ?? Date() > $1.lastMessageTime ?? Date() }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
```

#### ClubDetailViewModel (ClubViewModel)
```swift
@MainActor
class ClubViewModel: ObservableObject {
    @Published var events: [ClubEvent] = []
    @Published var newsItems: [NewsItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let clubId: UUID
    private let isCreator: Bool
    private let clubRepository: ClubRepository
    private let newsRepository: NewsRepository
    
    init(clubId: UUID, isCreator: Bool, 
         clubRepository: ClubRepository = DataLayerIntegration.shared.clubRepository,
         newsRepository: NewsRepository = NewsRepository()) {
        self.clubId = clubId
        self.isCreator = isCreator
        self.clubRepository = clubRepository
        self.newsRepository = newsRepository
    }
    
    func loadData() async {
        await loadEvents()
        await loadNews()
    }
    
    private func loadEvents() async {
        isLoading = true
        do {
            let calendarEvents = try await DataLayerIntegration.shared.calendarRepository.getClubEvents(for: await getClubName())
            events = calendarEvents.map { calendarEvent in
                ClubEvent(
                    title: calendarEvent.title,
                    date: calendarEvent.date,
                    location: calendarEvent.location,
                    description: calendarEvent.description
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
```

## Интеграция с SwiftUI

### Environment Keys
```swift
struct ClubRepositoryKey: EnvironmentKey {
    static let defaultValue: ClubRepository = ClubRepository()
}

struct UserRepositoryKey: EnvironmentKey {
    static let defaultValue: UserRepository = UserRepository()
}

struct CalendarRepositoryKey: EnvironmentKey {
    static let defaultValue: CalendarRepository = CalendarRepository()
}

struct ChatRepositoryKey: EnvironmentKey {
    static let defaultValue: ChatRepository = ChatRepository()
}

struct NewsRepositoryKey: EnvironmentKey {
    static let defaultValue: NewsRepository = NewsRepository()
}
```

### View Modifier
```swift
extension View {
    func withDataLayer() -> some View {
        self
            .environment(\.clubRepository, DataLayerIntegration.shared.clubRepository)
            .environment(\.userRepository, DataLayerIntegration.shared.userRepository)
            .environment(\.calendarRepository, DataLayerIntegration.shared.calendarRepository)
            .environment(\.chatRepository, DataLayerIntegration.shared.chatRepository)
            .environment(\.newsRepository, DataLayerIntegration.shared.newsRepository)
    }
}
```

## Использование в Views

### Базовое использование
```swift
struct MyView: View {
    @StateObject private var viewModel = ClubsListViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Загрузка...")
            } else {
                List(viewModel.clubs) { club in
                    Text(club.name)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadClubs()
            }
        }
        .withDataLayer()
    }
}
```

### Обработка состояний
```swift
struct MyView: View {
    @StateObject private var viewModel = MyViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Загрузка...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Основной контент
                List(viewModel.data) { item in
                    ItemRow(item: item)
                }
            }
        }
        .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .onAppear {
            Task {
                await viewModel.loadData()
            }
        }
        .withDataLayer()
    }
}
```

### Асинхронные операции
```swift
Button("Присоединиться к клубу") {
    Task {
        await viewModel.joinClub(club)
    }
}

Button("Сохранить профиль") {
    Task {
        await viewModel.saveProfileSection()
    }
}
```

## Операции с данными

### Получение данных
```swift
// Получение клубов (с синхронизацией)
let clubs = try await clubRepository.getAllClubs()

// Получение конкретного клуба
if let club = try await clubRepository.getClub(by: clubId) {
    // Работа с клубом
}

// Поиск клубов
let searchResults = try await clubRepository.searchClubs(query: "программирование")

// Получение событий календаря
let events = try await calendarRepository.getAllEvents()

// Получение чатов пользователя
let chats = try await chatRepository.getChats()

// Получение новостей клуба
let news = try await newsRepository.getNews(for: clubId)
```

### Изменение данных
```swift
// Присоединение к клубу
let updatedClub = try await clubRepository.joinClub(clubId)

// Создание события
try await calendarRepository.saveEvent(newEvent)

// Обновление профиля
try await userRepository.updateProfile(updatedUser)

// Отправка сообщения
try await chatRepository.sendMessage(message, to: chatId)

// Создание новости
try await newsRepository.saveNews(newsItem, for: clubId)
```

## Преимущества архитектуры

### 1. Офлайн-работа
- Приложение работает без интернета
- Данные сохраняются локально в Core Data
- Автоматическая синхронизация при восстановлении соединения

### 2. Производительность
- Мгновенный отклик UI (данные из локальной БД)
- Фоновая синхронизация с API
- Кэширование данных

### 3. Надежность
- Обработка ошибок сети
- Fallback на локальные данные
- Детальное логирование ошибок

### 4. Тестируемость
- Легкая замена репозиториев на моки
- Изолированное тестирование слоев
- Четкое разделение ответственности

### 5. Масштабируемость
- Единый интерфейс для всех операций с данными
- Легкое добавление новых источников данных
- Консистентная архитектура

## Расширение

### Добавление новой сущности
1. Создать Core Data модель
2. Добавить Database класс
3. Создать API сервис
4. Реализовать Repository
5. Обновить Swagger документацию

### Пример для NewsItem
```swift
// 1. NewsDatabase.swift
class NewsDatabase {
    func saveNews(_ news: NewsItem, for clubId: UUID) { ... }
    func getNews(for clubId: UUID) -> [NewsItem] { ... }
}

// 2. NewsApiService.swift
class NewsApiService {
    func getNews(for clubId: UUID) async throws -> [NewsItem] { ... }
    func saveNews(_ news: NewsItem, for clubId: UUID) async throws { ... }
}

// 3. NewsRepository.swift
class NewsRepository: NewsRepositoryProtocol {
    func getNews(for clubId: UUID) async throws -> [NewsItem] { ... }
    func saveNews(_ news: NewsItem, for clubId: UUID) async throws { ... }
}

// 4. Обновить swagger.yaml
```

## Зависимости

- **Core Data**: Локальная база данных
- **URLSession**: Сетевые запросы
- **Foundation**: Базовые типы данных
- **SwiftUI**: Для Color и других UI типов

## Безопасность

- JWT токены для авторизации
- HTTPS для всех API запросов
- Валидация данных на клиенте и сервере
- Безопасное хранение в Core Data

## Миграция существующих экранов

### Шаг 1: Обновить ViewModel
Заменить использование моковых данных на репозитории.

### Шаг 2: Добавить состояния
Добавить `@Published var isLoading` и `@Published var errorMessage`.

### Шаг 3: Сделать методы асинхронными
Изменить синхронные методы на `async` и добавить обработку ошибок.

### Шаг 4: Обновить View
Добавить обработку состояний загрузки и ошибок.

### Шаг 5: Добавить модификатор
Добавить `.withDataLayer()` к корневому View.

## Примеры использования

См. файл `UpdatedViewModelsExamples.swift` для подробных примеров использования всех обновленных ViewModels и сервисов.
