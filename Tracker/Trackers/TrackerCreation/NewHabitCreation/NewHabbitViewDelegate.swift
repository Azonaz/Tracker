import UIKit

final class NewHabbitViewDelegate: NSObject & UITableViewDelegate {
    private weak var viewController: NewHabitViewController?

    init(viewController: NewHabitViewController) {
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
            scheduleViewController.selectedWeekdays = viewController.getSelectedWeekdays()
            presentViewController(for: scheduleViewController)
        }
    }

    private func presentViewController(for viewController: UIViewController) {
        let navigationController = UINavigationController(rootViewController: viewController)
        self.viewController?.present(navigationController, animated: true)
    }
}
