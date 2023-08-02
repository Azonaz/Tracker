import UIKit

protocol NewEventViewControllerDelegate: AnyObject {
    func addNewEvent(_ trackerCategory: TrackerCategory)
}


final class NewEventViewController: UIViewController {
    weak var delegate: NewEventViewControllerDelegate?
    
}
