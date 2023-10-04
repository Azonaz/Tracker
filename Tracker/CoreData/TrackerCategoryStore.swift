import Foundation
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategoriesList()
}

protocol TrackerCategoryStoreDataProviderProtocol {
    func fetchTrackerCategory(for category: TrackerCategory) throws -> TrackerCategoryCD
}

protocol TrackerCategoryStoreProtocol {
    func getTrackerCategories() throws -> [TrackerCategory]
    func addTrackerCategory(_ category: TrackerCategory) throws
    func editTrackerCategory(_ category: TrackerCategory, with newTitle: String) throws
    func deleteTrackerCategory(_ category: TrackerCategory)
}

final class TrackerCategoryStore: NSObject {
    weak var delegate: TrackerCategoryStoreDelegate?
    private let context: NSManagedObjectContext
    private let request = TrackerCategoryCD.fetchRequest()
    private let uiColorMarshalling = UIColorMarshalling()

    private lazy var trackerStore: TrackerStore = {
        TrackerStore(context: context)
    }()

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCD> = {
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCD.title, ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()

    convenience override init() {
        let context = CoreDataService.shared.context
        self.init(context: context)
    }

    init(context: NSManagedObjectContext, delegate: TrackerCategoryStoreDelegate? = nil) {
        self.context = context
        self.delegate = delegate
        super.init()
    }
}

private extension TrackerCategoryStore {

    func fetchTrackerCategories() throws -> [TrackerCategory] {
        request.predicate = NSPredicate(format: "title != nil")
        let categories = try context.fetch(request)
        return try categories.map { try getTrackerCategory(from: $0) }
    }

    func fetchTrackerCategoryCoreData(for category: TrackerCategory) throws -> TrackerCategoryCD {
        request.predicate = NSPredicate(format: "title == %@", category.title)
        guard let categoryCD = try context.fetch(request).first else {
            throw StoreError.fetchError
        }
        return categoryCD
    }

    func getTrackerCategory(from trackerCategoryCD: TrackerCategoryCD) throws -> TrackerCategory {
        guard
            let title = trackerCategoryCD.title,
            let trackers = trackerCategoryCD.trackers as? Set<TrackerCD>
        else {
            throw StoreError.decodingError
        }
        var trackersList: [Tracker] = []
        for tracker in trackers {
            do {
                let tracker = try trackerStore.getTracker(tracker)
                trackersList.append(tracker)
            } catch {
                throw StoreError.initError
            }
        }
        return TrackerCategory(title: title, trackers: trackersList)
    }

    func addNewTrackerCategory(_ category: TrackerCategory) throws {
        request.predicate = NSPredicate(format: "title == %@", category.title)
        let count = try context.count(for: request)
        guard count == 0 else {
            throw StoreError.initError
        }
        let categoryCD = TrackerCategoryCD(context: context)
        categoryCD.title = category.title
        categoryCD.trackers = NSSet()
        try context.save()
    }

    func deleteSelectedTrackerCategory(_ category: TrackerCategory) throws {
        request.predicate = NSPredicate(format: "title == %@", category.title)
        guard let categoryCD = try context.fetch(request).first else {
            throw StoreError.fetchError
        }
        context.delete(categoryCD)
        try context.save()
    }

    func editTrackerCategoryCD(for oldCategory: TrackerCategory, with newTitle: String) throws {
        request.predicate = NSPredicate(format: "title == %@", oldCategory.title)
        guard let categoryCD = try context.fetch(request).first else {
            throw StoreError.fetchError
        }
        categoryCD.title = newTitle
        try context.save()
    }
}

extension TrackerCategoryStore: TrackerCategoryStoreDataProviderProtocol, TrackerCategoryStoreProtocol {

    func fetchTrackerCategory(for category: TrackerCategory) throws -> TrackerCategoryCD {
        try fetchTrackerCategoryCoreData(for: category)
    }

    func getTrackerCategories() throws -> [TrackerCategory] {
        try fetchTrackerCategories()
    }

    func addTrackerCategory(_ category: TrackerCategory) throws {
        try addNewTrackerCategory(category)
    }

    func deleteTrackerCategory(_ category: TrackerCategory) {
        try? deleteSelectedTrackerCategory(category)
    }

    func editTrackerCategory(_ oldCategory: TrackerCategory, with newTitle: String) throws {
        try editTrackerCategoryCD(for: oldCategory, with: newTitle)
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategoriesList()
    }
}
