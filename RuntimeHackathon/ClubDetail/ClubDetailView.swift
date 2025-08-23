//
//  ClubDetailView.swift
//  RuntimeHackathon
//
//  Created by KOZLOVA Anastasia on 23.08.2025.
//

import SwiftUI
import PhotosUI

struct ClubDetailView: View {
    let club: Club // Принимаем модель Club
    @StateObject private var clubViewModel: ClubViewModel
    @State private var isCreator: Bool
    @State private var showingCreateEvent = false
    @State private var showingCreateNews = false
    @State private var calendarReloadTrigger = UUID()
    @State private var selectedDateFilter: DateFilter = .all
    @Environment(\.presentationMode) var presentationMode
    
    init(club: Club) {
        self.club = club
        // Создаем ViewModel для конкретного клуба
      self._clubViewModel = StateObject(wrappedValue: ClubViewModel(clubId: club.id, isCreator: club.isCreator))
        // Инициализируем isCreator значением из модели клуба
        self._isCreator = State(initialValue: club.isCreator)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Заголовок клуба с данными из модели Club
                ClubHeaderSection(club: club)
                
                // Секция для создателя клуба
                if isCreator {
                    CreatorSection(
                        showingCreateEvent: $showingCreateEvent,
                        showingCreateNews: $showingCreateNews
                    )
                }
                
                // Информация о клубе
                ClubInfoSection()
                
                // Встроенный календарь
                CalendarSection(
                    clubEvents: clubViewModel.events,
                    reloadTrigger: calendarReloadTrigger
                )
                
                // Фильтр новостей
                DateFilterSection(selectedFilter: $selectedDateFilter)
                
                // Лента новостей (события + новости)
                NewsFeedSection(
                    events: clubViewModel.events,
                    newsItems: clubViewModel.newsItems,
                    isCreator: isCreator,
                    dateFilter: selectedDateFilter,
                    onDeleteNews: { newsId in
                        clubViewModel.deleteNews(id: newsId)
                    }
                )
            }
            .padding()
        }
        .navigationTitle(club.name) // Используем имя клуба из модели
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(trailing: Button("Закрыть") {
            presentationMode.wrappedValue.dismiss()
        })
        .sheet(isPresented: $showingCreateEvent) {
            CreateEventView(
                clubViewModel: clubViewModel,
                onEventCreated: {
                    calendarReloadTrigger = UUID()
                }
            )
        }
        .sheet(isPresented: $showingCreateNews) {
            CreateNewsView(clubViewModel: clubViewModel)
        }
    }
}

// MARK: - Секция заголовка клуба с данными из модели Club
struct ClubHeaderSection: View {
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
            
            // Кнопка действия
            Button(action: {
                // Логика присоединения/выхода из клуба
                print(club.isJoined ? "Покидаем клуб" : "Присоединяемся к клубу")
            }) {
                Text(club.isJoined ? "Выйти из клуба" : "Присоединиться к клубу")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(club.isJoined ? Color.gray : Color.orange) // Оранжевый цвет
                    .cornerRadius(12)
            }
        }
    }
}

// MARK: - Фильтр по дате
enum DateFilter: String, CaseIterable {
    case all = "Все"
    case today = "Сегодня"
    case week = "Неделя"
    case month = "Месяц"
    
    var dateRange: (Date?, Date?) {
        let now = Date()
        let calendar = Calendar.current
        
        switch self {
        case .all:
            return (nil, nil)
        case .today:
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)
            return (startOfDay, endOfDay)
        case .week:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))
            let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek ?? now)
            return (startOfWeek, endOfWeek)
        case .month:
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth ?? now)
            return (startOfMonth, endOfMonth)
        }
    }
}

// MARK: - Секция фильтра
struct DateFilterSection: View {
    @Binding var selectedFilter: DateFilter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Фильтр новостей")
                .font(.headline)
            
            HStack {
                ForEach(DateFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                    }) {
                        Text(filter.rawValue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedFilter == filter ? Color.orange : Color.gray.opacity(0.2)) // Оранжевый цвет
                            .foregroundColor(selectedFilter == filter ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Секция для создателя клуба
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

// MARK: - Экран создания новости
struct CreateNewsView: View {
    @ObservedObject var clubViewModel: ClubViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var newsTitle = ""
    @State private var newsDescription = ""
    @State private var selectedImages: [UIImage] = []
    @State private var photoPickerItems: [PhotosPickerItem] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Поле заголовка
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Заголовок")
                            .font(.headline)
                        
                        TextField("Введите заголовок новости", text: $newsTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // Выбор изображений
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Изображения")
                            .font(.headline)
                        
                        PhotosPicker(selection: $photoPickerItems, maxSelectionCount: 10, matching: .images) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                Text("Выбрать фотографии")
                            }
                        }
                        .onChange(of: photoPickerItems) { items in
                            loadSelectedImages(from: items)
                        }
                        
                        // Превью выбранных изображений
                        if !selectedImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(selectedImages.indices, id: \.self) { index in
                                        Image(uiImage: selectedImages[index])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipped()
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Поле описания
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Описание")
                            .font(.headline)
                        
                        TextEditor(text: $newsDescription)
                            .frame(height: 150)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Новая новость")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Опубликовать") {
                        createNews()
                    }
                    .disabled(newsTitle.isEmpty)
                }
            }
        }
    }
    
    private func loadSelectedImages(from items: [PhotosPickerItem]) {
        Task {
            selectedImages.removeAll()
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImages.append(uiImage)
                }
            }
        }
    }
    
    private func createNews() {
        let imageData = selectedImages.compactMap { $0.pngData() }
        clubViewModel.createNews(
            title: newsTitle,
            description: newsDescription,
            imagesData: imageData
        )
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Карусель изображений
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

// MARK: - Лента новостей (события + новости)
struct NewsFeedSection: View {
    let events: [ClubEvent]
    let newsItems: [NewsItem]
    let isCreator: Bool
    let dateFilter: DateFilter
    let onDeleteNews: (UUID) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Новости клуба")
                .font(.title2)
                .fontWeight(.bold)
            
            let filteredItems = getFilteredNewsItems()
            
            if filteredItems.isEmpty {
                Text("Нет новостей и событий")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(filteredItems.sorted(by: { $0.date > $1.date })) { item in
                    NewsCardView(
                        item: item,
                        isCreator: isCreator,
                        onDelete: {
                            if let newsId = item.newsId {
                                onDeleteNews(newsId)
                            }
                        }
                    )
                    Divider()
                }
            }
        }
    }
    
    private func getFilteredNewsItems() -> [NewsFeedItem] {
        var items: [NewsFeedItem] = []
        let (startDate, endDate) = dateFilter.dateRange
        
        // Добавляем события
        for event in events {
            let item = NewsFeedItem(
                id: event.id.uuidString,
                title: event.title,
                description: event.description,
                imagesData: [],
                date: event.date,
                publicationDate: event.createdAt,
                type: .event,
                newsId: nil
            )
            
            // Применяем фильтр по дате
            if shouldIncludeItem(item, startDate: startDate, endDate: endDate) {
                items.append(item)
            }
        }
        
        // Добавляем новости
        for news in newsItems {
            let item = NewsFeedItem(
                id: news.id.uuidString,
                title: news.title,
                description: news.description,
                imagesData: news.imagesData,
                date: news.createdAt,
                publicationDate: news.createdAt,
                type: .news,
                newsId: news.id
            )
            
            // Применяем фильтр по дате
            if shouldIncludeItem(item, startDate: startDate, endDate: endDate) {
                items.append(item)
            }
        }
        
        return items
    }
    
    private func shouldIncludeItem(_ item: NewsFeedItem, startDate: Date?, endDate: Date?) -> Bool {
        guard let startDate = startDate else { return true }
        
        if let endDate = endDate {
            return item.date >= startDate && item.date <= endDate
        } else {
            return item.date >= startDate
        }
    }
}

// MARK: - Модель элемента ленты новостей
struct NewsFeedItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let imagesData: [Data]
    let date: Date // Дата события или публикации новости
    let publicationDate: Date? // Дата публикации (для событий - когда создали, для новостей - когда опубликовали)
    let type: NewsItemType
    let newsId: UUID? // Только для новостей
    
    enum NewsItemType {
        case event
        case news
    }
}

// MARK: - Карточка новости в ленте
struct NewsCardView: View {
    let item: NewsFeedItem
    let isCreator: Bool
    let onDelete: () -> Void
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок с иконкой типа и кнопкой удаления
            HStack {
                HStack {
                    switch item.type {
                    case .event:
                        Image(systemName: "calendar.badge.plus")
                            .foregroundColor(.orange) // Оранжевый цвет
                    case .news:
                        Image(systemName: "newspaper")
                            .foregroundColor(.orange) // Оранжевый цвет
                    }
                    
                    Text(item.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                // Кнопка удаления для создателя (только для новостей)
                if isCreator && item.type == .news {
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                        .foregroundColor(.gray)
                    }
                    .alert("Удалить новость?", isPresented: $showingDeleteAlert) {
                        Button("Отмена", role: .cancel) { }
                        Button("Удалить", role: .destructive, action: onDelete)
                    } message: {
                        Text("Вы уверены, что хотите удалить эту новость?")
                    }
                }
            }
            
            // Даты
            VStack(alignment: .leading, spacing: 4) {
                switch item.type {
                case .event:
                    // Для событий показываем обе даты
                    Text("Опубликовано: \(formatDate(item.publicationDate ?? item.date))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Событие: \(formatEventDate(item.date))")
                        .font(.caption)
                        .foregroundColor(.orange) // Оранжевый цвет
                case .news:
                    // Для новостей показываем дату публикации
                    Text("Опубликовано: \(formatDate(item.date))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Карусель изображений (только для новостей)
            if item.type == .news && !item.imagesData.isEmpty {
                ImageCarouselView(images: item.imagesData)
            }
            
            // Описание
            Text(item.description)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func formatEventDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

// MARK: - Остальные секции (без изменений)
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

struct CalendarSection: View {
    let clubEvents: [ClubEvent]
    let reloadTrigger: UUID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Календарь событий")
                .font(.title2)
                .fontWeight(.bold)
            
            CalendarView(clubEvents: clubEvents)
                .frame(height: 400)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
                .id(reloadTrigger)
        }
    }
}

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
