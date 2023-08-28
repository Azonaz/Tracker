import Foundation
import CoreData

struct TrackerCategoryStoreUpdate {
    let insertedIndexPaths: [IndexPath]
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}

protocol TrackerCategoryStoreDataProviderProtocol {
    func fetchTrackerCategory(for category: TrackerCategory) throws -> TrackerCategoryCD
}

protocol TrackerCategoryStoreProtocol {
    func getTrackerCategories() throws -> [TrackerCategory]
    func addTrackerCategory(_ category: TrackerCategory) throws
}

final class TrackerCategoryStore: NSObject {
    weak var delegate: TrackerCategoryStoreDelegate?
    private let context: NSManagedObjectContext
    private let request = TrackerCategoryCD.fetchRequest()
    private let uiColorMarshalling = UIColorMarshalling()
    private var insertedIndexPaths: [IndexPath] = []

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
        guard let objects = fetchedResultsController.fetchedObjects else {
            throw StoreError.fetchError
        }
        let categories = try objects.map { try getTrackerCategory(from: $0) }
        return categories
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
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths.removeAll()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerCategoryStoreUpdate(insertedIndexPaths: insertedIndexPaths))
        insertedIndexPaths.removeAll()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any,
                    at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexPaths.append(indexPath)
            }
        default:
            break
        }
    }
}
