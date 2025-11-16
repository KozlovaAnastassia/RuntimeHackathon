import Foundation

class CalendarRepository: CalendarRepositoryProtocol {
    private let database: CalendarDatabase
    private let apiService: CalendarApiService
    
    init(database: CalendarDatabase = .shared, apiService: CalendarApiService = .shared) {
        self.database = database
        self.apiService = apiService
    }
    
    // MARK: - Получение всех событий
    func getAllEvents() async throws -> [CalendarEvent] {
        // Сначала получаем данные из базы данных
        let localEvents = database.getAllEvents()
        
        // Асинхронно обновляем данные из API
        Task {
            do {
                let apiEvents = try await apiService.getAllEvents()
                // Сохраняем новые данные в базу
                for event in apiEvents {
                    database.saveEvent(event)
                }
            } catch {
                print("Ошибка синхронизации событий с API: \(error)")
            }
        }
        
        return localEvents
    }
    
    // MARK: - Получение события по ID
    func getEvent(by id: UUID) async throws -> CalendarEvent? {
        // Сначала проверяем локальную базу
        if let localEvent = database.getEvent(by: id) {
            // Асинхронно обновляем данные из API
            Task {
                do {
                    let apiEvent = try await apiService.getEvent(by: id)
                    database.saveEvent(apiEvent)
                } catch {
                    print("Ошибка синхронизации события с API: \(error)")
                }
            }
            return localEvent
        }
        
        // Если нет в локальной базе, получаем из API
        do {
            let apiEvent = try await apiService.getEvent(by: id)
            database.saveEvent(apiEvent)
            return apiEvent
        } catch {
            return nil
        }
    }
    
    // MARK: - Сохранение события
    func saveEvent(_ event: CalendarEvent) async throws {
        // Сохраняем в локальную базу
        database.saveEvent(event)
        
        // Асинхронно отправляем в API
        Task {
            do {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let dateString = formatter.string(from: event.date)
                
                if let existingEvent = database.getEvent(by: event.id) {
                    // Обновляем существующее событие
                    let request = UpdateEventRequest(
                        title: event.title,
                        date: dateString,
                        location: event.location,
                        description: event.description,
                        colorHex: event.color.toHex(),
                        clubName: event.clubName
                    )
                    _ = try await apiService.updateEvent(event.id, with: request)
                } else {
                    // Создаем новое событие
                    let request = CreateEventRequest(
                        title: event.title,
                        date: dateString,
                        location: event.location,
                        description: event.description,
                        colorHex: event.color.toHex(),
                        clubName: event.clubName
                    )
                    _ = try await apiService.createEvent(request)
                }
            } catch {
                print("Ошибка синхронизации события с API: \(error)")
            }
        }
    }
    
    // MARK: - Удаление события
    func deleteEvent(_ event: CalendarEvent) async throws {
        // Удаляем из локальной базы
        database.deleteEvent(event)
        
        // Асинхронно удаляем из API
        Task {
            do {
                try await apiService.deleteEvent(event.id)
            } catch {
                print("Ошибка удаления события из API: \(error)")
            }
        }
    }
    
    // MARK: - Получение событий по дате
    func getEvents(for date: Date) async throws -> [CalendarEvent] {
        // Сначала получаем данные из базы данных
        let localEvents = database.getEvents(for: date)
        
        // Асинхронно обновляем данные из API
        Task {
            do {
                let apiEvents = try await apiService.getEvents(for: date)
                // Сохраняем новые данные в базу
                for event in apiEvents {
                    database.saveEvent(event)
                }
            } catch {
                print("Ошибка синхронизации событий по дате с API: \(error)")
            }
        }
        
        return localEvents
    }
    
    // MARK: - Получение событий по диапазону дат
    func getEvents(from startDate: Date, to endDate: Date) async throws -> [CalendarEvent] {
        // Сначала получаем данные из базы данных
        let localEvents = database.getEvents(from: startDate, to: endDate)
        
        // Асинхронно обновляем данные из API
        Task {
            do {
                let apiEvents = try await apiService.getEvents(from: startDate, to: endDate)
                // Сохраняем новые данные в базу
                for event in apiEvents {
                    database.saveEvent(event)
                }
            } catch {
                print("Ошибка синхронизации событий по диапазону с API: \(error)")
            }
        }
        
        return localEvents
    }
    
    // MARK: - Получение событий клуба
    func getClubEvents(for clubName: String) async throws -> [CalendarEvent] {
        // Получаем результаты из API
        do {
            let apiEvents = try await apiService.getClubEvents(for: clubName)
            // Сохраняем результаты в локальную базу
            for event in apiEvents {
                database.saveEvent(event)
            }
            return apiEvents
        } catch {
            // Если API недоступен, возвращаем локальные данные
            let localEvents = database.getClubEvents(for: clubName)
            return localEvents
        }
    }
    
    // MARK: - Получение событий пользователя
    func getUserEvents() async throws -> [CalendarEvent] {
        // Получаем результаты из API
        do {
            let apiEvents = try await apiService.getUserEvents()
            // Сохраняем результаты в локальную базу
            for event in apiEvents {
                database.saveEvent(event)
            }
            return apiEvents
        } catch {
            // Если API недоступен, возвращаем все локальные события
            let localEvents = database.getAllEvents()
            return localEvents
        }
    }
    
    // MARK: - Поиск событий
    func searchEvents(query: String) async throws -> [CalendarEvent] {
        // Получаем результаты из API
        do {
            let apiEvents = try await apiService.searchEvents(query: query)
            // Сохраняем результаты в локальную базу
            for event in apiEvents {
                database.saveEvent(event)
            }
            return apiEvents
        } catch {
            // Если API недоступен, ищем в локальной базе
            let localEvents = database.getAllEvents()
            return localEvents.filter { event in
                event.title.localizedCaseInsensitiveContains(query) ||
                event.description.localizedCaseInsensitiveContains(query) ||
                event.location.localizedCaseInsensitiveContains(query)
            }
        }
    }
    
    // MARK: - Получение событий по категории
    func getEventsByCategory(_ category: String) async throws -> [CalendarEvent] {
        // Получаем результаты из API
        do {
            let apiEvents = try await apiService.getEventsByCategory(category)
            // Сохраняем результаты в локальную базу
            for event in apiEvents {
                database.saveEvent(event)
            }
            return apiEvents
        } catch {
            // Если API недоступен, возвращаем пустой массив
            // Фильтрация по категории требует дополнительной логики
            return []
        }
    }
    
    // MARK: - Получение предстоящих событий
    func getUpcomingEvents(limit: Int) async throws -> [CalendarEvent] {
        // Получаем результаты из API
        do {
            let apiEvents = try await apiService.getUpcomingEvents(limit: limit)
            // Сохраняем результаты в локальную базу
            for event in apiEvents {
                database.saveEvent(event)
            }
            return apiEvents
        } catch {
            // Если API недоступен, фильтруем локальные события
            let localEvents = database.getAllEvents()
            let now = Date()
            return localEvents
                .filter { $0.date > now }
                .sorted { $0.date < $1.date }
                .prefix(limit)
                .map { $0 }
        }
    }
    
    // MARK: - Получение событий за неделю
    func getWeekEvents() async throws -> [CalendarEvent] {
        // Получаем результаты из API
        do {
            let apiEvents = try await apiService.getWeekEvents()
            // Сохраняем результаты в локальную базу
            for event in apiEvents {
                database.saveEvent(event)
            }
            return apiEvents
        } catch {
            // Если API недоступен, вычисляем события за неделю
            let calendar = Calendar.current
            let now = Date()
            let weekFromNow = calendar.date(byAdding: .weekOfYear, value: 1, to: now) ?? now
            return database.getEvents(from: now, to: weekFromNow)
        }
    }
    
    // MARK: - Получение событий за месяц
    func getMonthEvents() async throws -> [CalendarEvent] {
        // Получаем результаты из API
        do {
            let apiEvents = try await apiService.getMonthEvents()
            // Сохраняем результаты в локальную базу
            for event in apiEvents {
                database.saveEvent(event)
            }
            return apiEvents
        } catch {
            // Если API недоступен, вычисляем события за месяц
            let calendar = Calendar.current
            let now = Date()
            let monthFromNow = calendar.date(byAdding: .month, value: 1, to: now) ?? now
            return database.getEvents(from: now, to: monthFromNow)
        }
    }
}
