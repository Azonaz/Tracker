import Foundation
import CoreData

enum StoreError: Error {
    case fetchError
    case decodingError
    case initError
}

protocol CoreDataSavable {
    func saveContext() throws
}

final class CoreDataService {
    static let shared = CoreDataService()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private init() { }

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
