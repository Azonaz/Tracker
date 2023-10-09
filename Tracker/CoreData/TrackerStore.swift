import Foundation
import CoreData

struct TrackerStoreUpdate {
    let insertedSections: IndexSet
    let insertedIndexPaths: [IndexPath]
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

protocol TrackerStoreProtocol {
    func getTracker(_ trackerCD: TrackerCD) throws -> Tracker
    func addTracker(_ tracker: Tracker, in category: TrackerCategory) throws
    func deleteTracker(_ tracker: Tracker) throws
    func editTracker(_ tracker: Tracker, in category: TrackerCategory) throws
    func pinTracker(_ tracker: Tracker) throws
    func unpinTracker(_ tracker: Tracker) throws
}

final class TrackerStore: NSObject {
    weak var delegate: TrackerStoreDelegate?

    var trackers: [Tracker] {
        guard let objects = self.fetchedResultsController.fetchedObjects else {
            return []
        }
        let trackers = objects.compactMap { object in
            try? self.getTracker(from: object)
        }
        return trackers
    }

    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private var insertedSections: IndexSet = []
    private var insertedIndexPaths: [IndexPath] = []

    private lazy var trackerCategoryStore: TrackerCategoryStoreDataProviderProtocol = {
        TrackerCategoryStore(context: context)
    }()

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCD> = {
        let request = TrackerCD.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCD.title, ascending: true),
                                   NSSortDescriptor(keyPath: \TrackerCD.category?.title, ascending: false)]
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

    init(context: NSManagedObjectContext, delegate: TrackerStoreDelegate? = nil) {
        self.context = context
        self.delegate = delegate
    }
}

private extension TrackerStore {

    func getTracker(from trackerCD: TrackerCD) throws -> Tracker {
        guard
            let id = trackerCD.id,
            let title = trackerCD.title,
            let colorString = trackerCD.color,
            let emodji = trackerCD.emodji,
            let scheduleString = trackerCD.schedule
        else {
            throw StoreError.decodingError
        }
        return Tracker(id: id,
                       title: title,
                       color: uiColorMarshalling.getColor(from: colorString),
                       emodji: emodji,
                       schedule: scheduleString.components(separatedBy: ", ").compactMap { Weekday(rawValue: $0) },
                       isPinned: trackerCD.isPinned)
    }

    func addNewTrackerCoreData(_ tracker: Tracker, in category: TrackerCategory) throws {
        let trackerCategoryCD = try trackerCategoryStore.fetchTrackerCategory(for: category)
        let trackerCD = TrackerCD(context: context)
        trackerCD.id = tracker.id
        trackerCD.title = tracker.title
        trackerCD.color = uiColorMarshalling.getHexString(from: tracker.color)
        trackerCD.emodji = tracker.emodji
        trackerCD.schedule = tracker.schedule.compactMap { $0.rawValue }.joined(separator: ", ")
        trackerCD.category = trackerCategoryCD
        try context.save()
    }

    func deleteSelectTracker(_ tracker: Tracker) throws {
        let recordsRequest = NSFetchRequest<TrackerRecordCD>(entityName: "TrackerRecordCD")
        recordsRequest.predicate = NSPredicate(format: "id = %@", tracker.id as CVarArg)
        let deletedTracker = try context.fetch(recordsRequest)
        deletedTracker.forEach { context.delete($0) }
        let request = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
        request.predicate = NSPredicate(format: "id = %@", tracker.id as CVarArg)
        do {
            let deletesTrackers = try context.fetch(request)
            deletesTrackers.forEach { context.delete($0) }
            try context.save()
        } catch {
            throw StoreError.deleteError
        }
    }

    func editTrackerCoreData(_ tracker: Tracker, in category: TrackerCategory) throws {
        let request = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
        request.predicate = NSPredicate(format: "id = %@", tracker.id as CVarArg)
        do {
            let trackers = try context.fetch(request)
            if let trackerToEdit = trackers.first {
                trackerToEdit.title = tracker.title
                trackerToEdit.color = uiColorMarshalling.getHexString(from: tracker.color)
                trackerToEdit.emodji = tracker.emodji
                trackerToEdit.schedule = tracker.schedule.compactMap { $0.rawValue }.joined(separator: ", ")
                let categoryCD = try trackerCategoryStore.fetchTrackerCategory(for: category)
                trackerToEdit.category = categoryCD
                try context.save()
            }
        } catch {
            throw StoreError.decodingError
        }
    }

    func pinTrackerCoreData(_ tracker: Tracker) throws {
        let request = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
        request.predicate = NSPredicate(format: "id = %@", tracker.id as CVarArg)
        do {
            let trackers = try context.fetch(request)
            if let trackerToPin = trackers.first {
                trackerToPin.isPinned = true
                try context.save()
            }
        } catch {
            throw StoreError.decodingError
        }
    }

    func unpinTrackerCoreData(_ tracker: Tracker) throws {
        let request = NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
        request.predicate = NSPredicate(format: "id = %@", tracker.id as CVarArg)
        do {
            let trackers = try context.fetch(request)
            if let trackerToUnpin = trackers.first {
                trackerToUnpin.isPinned = false
                try context.save()
            }
        } catch {
            throw StoreError.decodingError
        }
    }
}

extension TrackerStore: TrackerStoreProtocol {

    func getTracker(_ trackerCD: TrackerCD) throws -> Tracker {
        try getTracker(from: trackerCD)
    }

    func addTracker(_ tracker: Tracker, in category: TrackerCategory) throws {
        try addNewTrackerCoreData(tracker, in: category)
    }

    func deleteTracker(_ tracker: Tracker) throws {
        try deleteSelectTracker(tracker)
    }

    func editTracker(_ tracker: Tracker, in category: TrackerCategory) throws {
        try editTrackerCoreData(tracker, in: category)
    }

    func pinTracker(_ tracker: Tracker) throws {
        try pinTrackerCoreData(tracker)
    }

    func unpinTracker(_ tracker: Tracker) throws {
        try unpinTrackerCoreData(tracker)
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedSections.removeAll()
        insertedIndexPaths.removeAll()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerStoreUpdate(insertedSections: insertedSections,
                                               insertedIndexPaths: insertedIndexPaths))
        insertedSections.removeAll()
        insertedIndexPaths.removeAll()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertedSections.insert(sectionIndex)
        default:
            break
        }
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
