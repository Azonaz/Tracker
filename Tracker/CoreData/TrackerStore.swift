import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject{
    
}

final class TrackerStore: NSObject {
    weak var delegate: TrackerStoreDelegate?
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCD> = {
        let fetchRequest = TrackerCD.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCD.title, ascending: true),
                                        NSSortDescriptor(keyPath: \TrackerCD.category?.title, ascending: false)]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self
        self.fetchedResultsController = controller
        try? controller.performFetch()
        return controller
    }()

    convenience override init() {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Can't get AppDelegate")
        }
        let context = delegate.persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
    }
}


extension TrackerStore: NSFetchedResultsControllerDelegate {
    
}
