import Foundation
import CoreData

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RuntimeHackathonDB")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Не удалось загрузить Core Data: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Ошибка сохранения контекста: \(error)")
            }
        }
    }
    
    func deleteAllData() {
        let entities = persistentContainer.managedObjectModel.entities
        entities.forEach { entity in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try context.execute(deleteRequest)
            } catch {
                print("Ошибка удаления данных для \(entity.name!): \(error)")
            }
        }
        saveContext()
    }
}
