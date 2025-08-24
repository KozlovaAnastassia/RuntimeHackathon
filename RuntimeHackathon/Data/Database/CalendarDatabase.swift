import Foundation
import CoreData
import SwiftUI

class CalendarDatabase {
    static let shared = CalendarDatabase()
    private let databaseManager = DatabaseManager.shared
    
    private init() {}
    
    // MARK: - Сохранение события
    func saveEvent(_ event: CalendarEvent) {
        let context = databaseManager.context
        
        let fetchRequest: NSFetchRequest<CalendarEventEntity> = CalendarEventEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", event.id.uuidString)
        
        do {
            let existingEvents = try context.fetch(fetchRequest)
            let eventEntity: CalendarEventEntity
            
            if let existingEvent = existingEvents.first {
                eventEntity = existingEvent
            } else {
                eventEntity = CalendarEventEntity(context: context)
                eventEntity.id = event.id.uuidString
            }
            
            eventEntity.title = event.title
            eventEntity.date = event.date
            eventEntity.location = event.location
            eventEntity.eventDescription = event.description
            eventEntity.createdAt = event.createdAt
            eventEntity.colorHex = event.color.toHex()
            eventEntity.clubName = event.clubName
            eventEntity.updatedAt = Date()
            
            databaseManager.saveContext()
        } catch {
            print("Ошибка сохранения события: \(error)")
        }
    }
    
    // MARK: - Получение всех событий
    func getAllEvents() -> [CalendarEvent] {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<CalendarEventEntity> = CalendarEventEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            let eventEntities = try context.fetch(fetchRequest)
            return eventEntities.compactMap { entity in
                guard let idString = entity.id,
                      let id = UUID(uuidString: idString),
                      let title = entity.title,
                      let date = entity.date,
                      let location = entity.location,
                      let description = entity.eventDescription,
                      let createdAt = entity.createdAt else {
                    return nil
                }
                
                let color = Color(hex: entity.colorHex ?? "#007AFF") ?? .blue
                
                return CalendarEvent(
                    id: id,
                    title: title,
                    date: date,
                    location: location,
                    description: description,
                    color: color,
                    clubName: entity.clubName
                )
            }
        } catch {
            print("Ошибка получения событий: \(error)")
            return []
        }
    }
    
    // MARK: - Получение событий по дате
    func getEvents(for date: Date) -> [CalendarEvent] {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<CalendarEventEntity> = CalendarEventEntity.fetchRequest()
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            let eventEntities = try context.fetch(fetchRequest)
            return eventEntities.compactMap { entity in
                guard let idString = entity.id,
                      let id = UUID(uuidString: idString),
                      let title = entity.title,
                      let date = entity.date,
                      let location = entity.location,
                      let description = entity.eventDescription,
                      let createdAt = entity.createdAt else {
                    return nil
                }
                
                let color = Color(hex: entity.colorHex ?? "#007AFF") ?? .blue
                
                return CalendarEvent(
                    id: id,
                    title: title,
                    date: date,
                    location: location,
                    description: description,
                    color: color,
                    clubName: entity.clubName
                )
            }
        } catch {
            print("Ошибка получения событий по дате: \(error)")
            return []
        }
    }
    
    // MARK: - Получение событий по диапазону дат
    func getEvents(from startDate: Date, to endDate: Date) -> [CalendarEvent] {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<CalendarEventEntity> = CalendarEventEntity.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            let eventEntities = try context.fetch(fetchRequest)
            return eventEntities.compactMap { entity in
                guard let idString = entity.id,
                      let id = UUID(uuidString: idString),
                      let title = entity.title,
                      let date = entity.date,
                      let location = entity.location,
                      let description = entity.eventDescription,
                      let createdAt = entity.createdAt else {
                    return nil
                }
                
                let color = Color(hex: entity.colorHex ?? "#007AFF") ?? .blue
                
                return CalendarEvent(
                    id: id,
                    title: title,
                    date: date,
                    location: location,
                    description: description,
                    color: color,
                    clubName: entity.clubName
                )
            }
        } catch {
            print("Ошибка получения событий по диапазону: \(error)")
            return []
        }
    }
    
    // MARK: - Получение события по ID
    func getEvent(by id: UUID) -> CalendarEvent? {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<CalendarEventEntity> = CalendarEventEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id.uuidString)
        fetchRequest.fetchLimit = 1
        
        do {
            let eventEntities = try context.fetch(fetchRequest)
            guard let entity = eventEntities.first,
                  let idString = entity.id,
                  let eventId = UUID(uuidString: idString),
                  let title = entity.title,
                  let date = entity.date,
                  let location = entity.location,
                  let description = entity.eventDescription,
                  let createdAt = entity.createdAt else {
                return nil
            }
            
            let color = Color(hex: entity.colorHex ?? "#007AFF") ?? .blue
            
            return CalendarEvent(
                id: eventId,
                title: title,
                date: date,
                location: location,
                description: description,
                color: color,
                clubName: entity.clubName
            )
        } catch {
            print("Ошибка получения события: \(error)")
            return nil
        }
    }
    
    // MARK: - Удаление события
    func deleteEvent(_ event: CalendarEvent) {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<CalendarEventEntity> = CalendarEventEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", event.id.uuidString)
        
        do {
            let eventEntities = try context.fetch(fetchRequest)
            eventEntities.forEach { context.delete($0) }
            databaseManager.saveContext()
        } catch {
            print("Ошибка удаления события: \(error)")
        }
    }
    
    // MARK: - Получение событий клуба
    func getClubEvents(for clubName: String) -> [CalendarEvent] {
        let context = databaseManager.context
        let fetchRequest: NSFetchRequest<CalendarEventEntity> = CalendarEventEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "clubName == %@", clubName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            let eventEntities = try context.fetch(fetchRequest)
            return eventEntities.compactMap { entity in
                guard let idString = entity.id,
                      let id = UUID(uuidString: idString),
                      let title = entity.title,
                      let date = entity.date,
                      let location = entity.location,
                      let description = entity.eventDescription,
                      let createdAt = entity.createdAt else {
                    return nil
                }
                
                let color = Color(hex: entity.colorHex ?? "#007AFF") ?? .blue
                
                return CalendarEvent(
                    id: id,
                    title: title,
                    date: date,
                    location: location,
                    description: description,
                    color: color,
                    clubName: entity.clubName
                )
            }
        } catch {
            print("Ошибка получения событий клуба: \(error)")
            return []
        }
    }
    
    // MARK: - Получение событий за неделю
    func getWeekEvents() -> [CalendarEvent] {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now
        
        return getEvents(from: startOfWeek, to: endOfWeek)
    }
    
    // MARK: - Получение предстоящих событий
    func getUpcomingEvents(limit: Int = 10) -> [CalendarEvent] {
        let now = Date()
        let allEvents = getAllEvents()
        
        return allEvents
            .filter { $0.date > now }
            .sorted { $0.date < $1.date }
            .prefix(limit)
            .map { $0 }
    }
}
