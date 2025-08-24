# Руководство по миграции на Repository Pattern

## Обзор изменений

Все ViewModels и сервисы в папке `Presentation` и `Data/Services` были обновлены для использования созданных репозиториев вместо моковых данных. Это обеспечивает:

- **Офлайн-работу** приложения
- **Автоматическую синхронизацию** с API
- **Единообразный интерфейс** для работы с данными
- **Лучшую тестируемость** кода

## Обновленные компоненты

### 1. ViewModels

#### ClubsListViewModel
**Было:**
```swift
@Published var clubs: [Club] = ClubDataMock.sampleClubs

func joinClub(_ club: Club) {
    if let index = clubs.firstIndex(where: { $0.id == club.id }) {
        clubs[index].isJoined = true
    }
}
```

**Стало:**
```swift
@Published var clubs: [Club] = []
@Published var isLoading = false
@Published var errorMessage: String?
private let repository: ClubRepository

func loadClubs() async {
    isLoading = true
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
    } catch {
        errorMessage = error.localizedDescription
    }
}
```

#### UserProfileViewModel
**Было:**
```swift
init(user: User) {
    self.user = user
    // ...
}

func saveProfileSection() async {
    try await Task.sleep(nanoseconds: 500_000_000)
    user.name = editedName
    // ...
}
```

**Стало:**
```swift
@Published var user: User?
private let repository: UserRepository

init(repository: UserRepository = DataLayerIntegration.shared.userRepository) {
    self.repository = repository
}

func loadProfile(userId: UUID) async {
    isLoading = true
    do {
        user = try await repository.getUser(by: userId)
        // ...
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
```

#### CalendarViewModel
**Было:**
```swift
init() {
    generateSampleEvents()
    updateCalendarDays()
}

private func generateSampleEvents() {
    events = CalendarDataMock.generateSampleEvents()
}
```

**Стало:**
```swift
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
```

#### ChatListViewModel
**Было:**
```swift
init(chats: [ChatInfo]) {
    ChatDatabase.shared.chats = chats
    loadChats()
}

func loadChats() {
    self.chats = ChatDatabase.shared.chats.sorted { ... }
}
```

**Стало:**
```swift
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
```

#### ClubDetailViewModel (ClubViewModel)
**Было:**
```swift
init(clubId: UUID, isCreator: Bool) {
    self.clubId = clubId
    loadEvents()
    loadNews()
}

private func loadEvents() {
    events = ClubEventsService.shared.getEventsForClub(clubId)
}
```

**Стало:**
```swift
private let clubRepository: ClubRepository
private let newsRepository: NewsRepository

init(clubId: UUID, isCreator: Bool, 
     clubRepository: ClubRepository = DataLayerIntegration.shared.clubRepository,
     newsRepository: NewsRepository = NewsRepository()) {
    self.clubId = clubId
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
        events = calendarEvents.map { /* конвертация */ }
    } catch {
        errorMessage = error.localizedDescription
    }
    isLoading = false
}
```

### 2. Сервисы

#### ClubEventsService
**Было:**
```swift
func loadAllEvents() {
    var allEvents: [ClubEvent] = []
    let clubs = ClubsListViewModel().clubs
    for club in clubs {
        let key = "ClubEvents_\(club.id.uuidString)"
        if let data = UserDefaults.standard.data(forKey: key) {
            // ...
        }
    }
}
```

**Стало:**
```swift
private let calendarRepository: CalendarRepository

func loadAllEvents() async {
    isLoading = true
    do {
        let calendarEvents = try await calendarRepository.getAllEvents()
        allClubEvents = calendarEvents.map { /* конвертация */ }
    } catch {
        errorMessage = error.localizedDescription
    }
    isLoading = false
}
```

## Новые компоненты

### 1. ChatRepository
Полностью новый репозиторий для работы с чатами:
- `getChats()` - получение всех чатов
- `getChat(by:)` - получение чата по ID
- `saveChat()` - сохранение чата
- `deleteChat()` - удаление чата
- `getMessages()` - получение сообщений
- `sendMessage()` - отправка сообщения
- `searchChats()` - поиск чатов

### 2. NewsRepository
Новый репозиторий для работы с новостями клубов:
- `getNews(for:)` - получение новостей клуба
- `saveNews()` - сохранение новости
- `deleteNews()` - удаление новости
- `getAllNews()` - получение всех новостей
- `searchNews()` - поиск новостей

### 3. Обновленная Core Data модель
Добавлена сущность `NewsEntity` для хранения новостей:
```xml
<entity name="NewsEntity">
    <attribute name="clubId" type="String"/>
    <attribute name="createdAt" type="Date"/>
    <attribute name="id" type="String"/>
    <attribute name="imagesData" type="Transformable"/>
    <attribute name="newsDescription" type="String"/>
    <attribute name="title" type="String"/>
    <attribute name="updatedAt" type="Date"/>
</entity>
```

## Интеграция с SwiftUI

### Environment Keys
Добавлены новые Environment Keys для доступа к репозиториям:
```swift
struct ChatRepositoryKey: EnvironmentKey {
    static let defaultValue: ChatRepository = ChatRepository()
}

struct NewsRepositoryKey: EnvironmentKey {
    static let defaultValue: NewsRepository = NewsRepository()
}
```

### View Modifier
Обновлен модификатор `.withDataLayer()`:
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

## Использование в коде

### Базовое использование
```swift
struct MyView: View {
    @StateObject private var viewModel = ClubsListViewModel()
    
    var body: some View {
        List(viewModel.clubs) { club in
            Text(club.name)
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
if viewModel.isLoading {
    ProgressView("Загрузка...")
}

if let errorMessage = viewModel.errorMessage {
    Text(errorMessage)
        .foregroundColor(.red)
}
```

### Асинхронные операции
```swift
Button("Присоединиться к клубу") {
    Task {
        await viewModel.joinClub(club)
    }
}
```

## Преимущества миграции

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

## Заключение

Миграция на Repository Pattern обеспечивает более надежную, производительную и масштабируемую архитектуру приложения. Все компоненты теперь работают с единым интерфейсом данных, поддерживают офлайн-режим и автоматическую синхронизацию.
