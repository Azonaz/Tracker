import UIKit

final class CategoryViewDelegate: NSObject, UITableViewDelegate {
    private weak var viewController: CategoryViewController?

    init(viewController: CategoryViewController) {
        self.viewController = viewController
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewController else { return }
        viewController.selectedIndexPath.flatMap { tableView.cellForRow(at: $0) }?.accessoryType = .none
        viewController.selectedIndexPath = indexPath
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        let titleCategory = viewController.getCategoryTitle(viewController.getCategoriesList()[indexPath.row].title)
        viewController.delegate?.updateCategorySubtitle(from: titleCategory, at: viewController.selectedIndexPath)
        viewController.dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}
