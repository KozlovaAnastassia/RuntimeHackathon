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
└── Mock/              # Моковые данные (существующие)

Domain/
└── Repository/        # Repository слой
    ├── RepositoryProtocol.swift
    ├── ClubRepository.swift
    ├── UserRepository.swift
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

#### Swagger документация
- Полная спецификация API
- Описание всех эндпоинтов и моделей данных
- Готова для генерации серверного кода

### 3. Repository слой

#### Протоколы
- **ClubRepositoryProtocol**: Интерфейс для работы с клубами
- **UserRepositoryProtocol**: Интерфейс для работы с пользователями
- **CalendarRepositoryProtocol**: Интерфейс для работы с событиями

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

## Использование

### Инициализация
```swift
let clubRepository = ClubRepository()
let userRepository = UserRepository()
let calendarRepository = CalendarRepository()
```

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
```

### Изменение данных
```swift
// Присоединение к клубу
let updatedClub = try await clubRepository.joinClub(clubId)

// Создание события
try await calendarRepository.saveEvent(newEvent)

// Обновление профиля
try await userRepository.updateProfile(updatedUser)
```

## Преимущества архитектуры

1. **Офлайн-работа**: Приложение работает без интернета
2. **Быстрый отклик**: Локальные данные доступны мгновенно
3. **Автоматическая синхронизация**: Данные обновляются в фоне
4. **Надежность**: Fallback на локальные данные при ошибках API
5. **Масштабируемость**: Легко добавлять новые сущности
6. **Тестируемость**: Четкое разделение слоев

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
// 2. NewsApiService.swift  
// 3. NewsRepository.swift
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
