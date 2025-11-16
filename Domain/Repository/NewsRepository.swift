import Foundation
import CoreData

// MARK: - Протокол для новостей
protocol NewsRepositoryProtocol {
    func getNews(for clubId: UUID) async throws -> [NewsItem]
    func saveNews(_ news: NewsItem, for clubId: UUID) async throws
    func deleteNews(_ news: NewsItem, from clubId: UUID) async throws
    func getAllNews() async throws -> [NewsItem]
    func searchNews(query: String) async throws -> [NewsItem]
}

class NewsRepository: NewsRepositoryProtocol {
    private let database: NewsDatabase
    private let apiService: NewsApiService
    
    init(database: NewsDatabase = .shared, apiService: NewsApiService = .shared) {
        self.database = database
        self.apiService = apiService
    }
    
    // MARK: - Получение новостей клуба
    func getNews(for clubId: UUID) async throws -> [NewsItem] {
        // Сначала получаем данные из базы данных
        let localNews = database.getNews(for: clubId)
        
        // Асинхронно обновляем данные из API
        Task {
            do {
                let apiNews = try await apiService.getNews(for: clubId)
                // Сохраняем новые данные в базу
                for news in apiNews {
                    database.saveNews(news, for: clubId)
                }
            } catch {
                print("Ошибка синхронизации новостей с API: \(error)")
            }
        }
        
        return localNews
    }
    
    // MARK: - Сохранение новости
    func saveNews(_ news: NewsItem, for clubId: UUID) async throws {
        // Сохраняем в локальную базу
        database.saveNews(news, for: clubId)
        
        // Асинхронно отправляем в API
        Task {
            do {
                if let existingNews = database.getNews(by: news.id) {
                    // Обновляем существующую новость
                    _ = try await apiService.updateNews(news.id, with: news, for: clubId)
                } else {
                    // Создаем новую новость
                    _ = try await apiService.createNews(news, for: clubId)
                }
            } catch {
                print("Ошибка синхронизации новости с API: \(error)")
            }
        }
    }
    
    // MARK: - Удаление новости
    func deleteNews(_ news: NewsItem, from clubId: UUID) async throws {
        // Удаляем из локальной базы
        database.deleteNews(news, from: clubId)
        
        // Асинхронно удаляем из API
        Task {
            do {
                try await apiService.deleteNews(news.id, from: clubId)
            } catch {
                print("Ошибка удаления новости из API: \(error)")
            }
        }
    }
    
    // MARK: - Получение всех новостей
    func getAllNews() async throws -> [NewsItem] {
        // Получаем результаты из API
        do {
            let apiNews = try await apiService.getAllNews()
            // Сохраняем результаты в локальную базу
            for news in apiNews {
                database.saveNews(news, for: UUID()) // Временный clubId
            }
            return apiNews
        } catch {
            // Если API недоступен, возвращаем локальные данные
            return database.getAllNews()
        }
    }
    
    // MARK: - Поиск новостей
    func searchNews(query: String) async throws -> [NewsItem] {
        // Получаем результаты из API
        do {
            let apiNews = try await apiService.searchNews(query: query)
            // Сохраняем результаты в локальную базу
            for news in apiNews {
                database.saveNews(news, for: UUID()) // Временный clubId
            }
            return apiNews
        } catch {
            // Если API недоступен, ищем в локальной базе
            let localNews = database.getAllNews()
            return localNews.filter { news in
                news.title.localizedCaseInsensitiveContains(query) ||
                news.description.localizedCaseInsensitiveContains(query)
            }
        }
    }
}

// MARK: - NewsDatabase (локальная база данных для новостей)
class NewsDatabase {
    static let shared = NewsDatabase()
    private let databaseManager = DatabaseManager.shared
    
    private init() {}
    
    // MARK: - Сохранение новости
    func saveNews(_ news: NewsItem, for clubId: UUID) {
        let context = databaseManager.context
        
        let fetchRequest: NSFetchRequest<NewsEntity> = NewsEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", news.id.uuidString)
        
        do {
            let existingNews = try context.fetch(fetchRequest)
            let newsEntity: NewsEntity
            
            if let existing = existingNews.first {
                newsEntity = existing
            } else {
                newsEntity = NewsEntity(context: context)
                newsEntity.id = news.id.uuidString
            }
            
            newsEntity.title = news.title
            newsEntity.newsDescription = news.description
            newsEntity.imagesData = news.imagesData
            newsEntity.clubId = clubId.uuidString
            newsEntity.createdAt = Date()
            newsEntity.updatedAt = Date()
            
            databaseManager.saveContext()
        } catch {
            print("Ошибка сохранения новости: \(error)")
        }
    }
    
    // MARK: - Получение новостей клуба
    func getNews(for clubId: UUID) -> [NewsItem] {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<NewsEntity> = NewsEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "clubId == %@", clubId.uuidString)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let newsEntities = try context.fetch(fetchRequest)
            return newsEntities.compactMap { entity in
                guard let idString = entity.id,
                      let id = UUID(uuidString: idString),
                      let title = entity.title,
                      let description = entity.newsDescription else {
                    return nil
                }
                
                return NewsItem(
                    title: title,
                    description: description,
                    imagesData: entity.imagesData ?? []
                )
            }
        } catch {
            print("Ошибка получения новостей: \(error)")
            return []
        }
    }
    
    // MARK: - Получение новости по ID
    func getNews(by id: UUID) -> NewsItem? {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<NewsEntity> = NewsEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id.uuidString)
        fetchRequest.fetchLimit = 1
        
        do {
            let newsEntities = try context.fetch(fetchRequest)
            guard let entity = newsEntities.first,
                  let idString = entity.id,
                  let newsId = UUID(uuidString: idString),
                  let title = entity.title,
                  let description = entity.newsDescription else {
                return nil
            }
            
            return NewsItem(
                title: title,
                description: description,
                imagesData: entity.imagesData ?? []
            )
        } catch {
            print("Ошибка получения новости: \(error)")
            return nil
        }
    }
    
    // MARK: - Удаление новости
    func deleteNews(_ news: NewsItem, from clubId: UUID) {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<NewsEntity> = NewsEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND clubId == %@", news.id.uuidString, clubId.uuidString)
        
        do {
            let newsEntities = try context.fetch(fetchRequest)
            newsEntities.forEach { context.delete($0) }
            databaseManager.saveContext()
        } catch {
            print("Ошибка удаления новости: \(error)")
        }
    }
    
    // MARK: - Получение всех новостей
    func getAllNews() -> [NewsItem] {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<NewsEntity> = NewsEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let newsEntities = try context.fetch(fetchRequest)
            return newsEntities.compactMap { entity in
                guard let idString = entity.id,
                      let id = UUID(uuidString: idString),
                      let title = entity.title,
                      let description = entity.newsDescription else {
                    return nil
                }
                
                return NewsItem(
                    title: title,
                    description: description,
                    imagesData: entity.imagesData ?? []
                )
            }
        } catch {
            print("Ошибка получения всех новостей: \(error)")
            return []
        }
    }
}

// MARK: - NewsApiService (заглушка для API)
class NewsApiService {
    static let shared = NewsApiService()
    
    private init() {}
    
    func getNews(for clubId: UUID) async throws -> [NewsItem] {
        // Возвращаем моковые данные
        return ContentDataMock.sampleNewsItems
    }
    
    func createNews(_ news: NewsItem, for clubId: UUID) async throws -> NewsItem {
        return news
    }
    
    func updateNews(_ id: UUID, with news: NewsItem, for clubId: UUID) async throws -> NewsItem {
        return news
    }
    
    func deleteNews(_ id: UUID, from clubId: UUID) async throws {
        // Заглушка
    }
    
    func getAllNews() async throws -> [NewsItem] {
        return ContentDataMock.sampleNewsItems
    }
    
    func searchNews(query: String) async throws -> [NewsItem] {
        return ContentDataMock.sampleNewsItems.filter { news in
            news.title.localizedCaseInsensitiveContains(query) ||
            news.description.localizedCaseInsensitiveContains(query)
        }
    }
}
