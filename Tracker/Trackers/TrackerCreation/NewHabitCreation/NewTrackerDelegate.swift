import UIKit

final class NewTrackerDelegate: NSObject, UITableViewDelegate {
    private weak var viewController: CreateNewTrackerViewController?

    init(viewController: CreateNewTrackerViewController) {
        self.viewController = viewController
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewController else { return }
        if indexPath.row == 0 {
            let categoryViewController = CategoryViewController()
            categoryViewController.delegate = viewController
            categoryViewController.selectedIndexPath = viewController.indexCategory
            presentViewController(for: categoryViewController)
        } else {
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = viewController
            scheduleViewController.schedule = viewController.getSchedule()
            scheduleViewController.scheduleSelectedDays = viewController.getScheduleSelectedDays()
            presentViewController(for: scheduleViewController)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }

    private func presentViewController(for viewController: UIViewController) {
        let navigationController = UINavigationController(rootViewController: viewController)
        self.viewController?.present(navigationController, animated: true)
    }
}
