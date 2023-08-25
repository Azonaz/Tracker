import Foundation
import CoreData

protocol TrackerRecordStoreProtocol {
    func fetchTrackerRecords(for tracker: Tracker) throws -> [TrackerRecord]
    func addTrackerRecord(for id: UUID, by date: Date) throws
    func deleteTrackerRecord(for id: UUID, by date: Date) throws
}

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext

    convenience override init() {
        let context = CoreDataService.shared.context
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

private extension TrackerRecordStore {

    func fetchRecords(tracker: Tracker) throws -> [TrackerRecord] {
        let request = TrackerRecordCD.fetchRequest()
        request.predicate = NSPredicate(format: "tracker.id = %@", tracker.id as CVarArg)
        guard let objects = try? context.fetch(request) else { return [] }
        let records = objects.compactMap { object -> TrackerRecord? in
            guard
                let id = object.id,
                let date = object.date
            else { return nil }
            return TrackerRecord(id: id, date: date)
        }
        return records
    }

    func fetchTrackerCoreData(for trackerId: UUID) throws -> TrackerCD? {
        let request = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@",
                                        (\TrackerCD.id)._kvcKeyPathString!, trackerId as CVarArg)
        guard let trackerCoreData = try context.fetch(request).first else {
            throw StoreError.fetchError
        }
        return trackerCoreData
    }

    func fetchTrackerRecordCoreData(for recordID: UUID, and date: Date) throws -> TrackerRecordCD? {
        let request = TrackerRecordCD.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                        (\TrackerRecordCD.tracker?.id)._kvcKeyPathString!, recordID as CVarArg,
                                        (\TrackerRecordCD.date)._kvcKeyPathString!, date as CVarArg)
        guard let recordCoreData = try context.fetch(request).first else {
            throw StoreError.fetchError
        }
        return recordCoreData
    }

    func addTrackerRecord(id: UUID, date: Date) throws {
        guard let trackerCD = try fetchTrackerCoreData(for: id) else {
            throw StoreError.fetchError
        }
        let trackerRecordCD = TrackerRecordCD(context: context)
        trackerRecordCD.id = id
        trackerRecordCD.date = date
        trackerRecordCD.tracker = trackerCD
        try context.save()
    }

    func deleteTrackerRecord(id: UUID, date: Date) throws {
        guard let recordCD = try fetchTrackerRecordCoreData(for: id, and: date) else {
            throw StoreError.fetchError
        }
        context.delete(recordCD)
        try context.save()
    }
}

extension TrackerRecordStore: TrackerRecordStoreProtocol {

    func fetchTrackerRecords(for tracker: Tracker) throws -> [TrackerRecord] {
        try fetchRecords(tracker: tracker)
    }

    func addTrackerRecord(for id: UUID, by date: Date) throws {
        try addTrackerRecord(id: id, date: date)
    }

    func deleteTrackerRecord(for id: UUID, by date: Date) throws {
        try deleteTrackerRecord(id: id, date: date)
    }
}
