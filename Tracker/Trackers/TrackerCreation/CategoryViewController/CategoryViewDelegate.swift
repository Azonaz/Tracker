import UIKit

final class CategoryViewDelegate: NSObject & UITableViewDelegate {
    private weak var viewController: CategoryViewController?

    init(viewController: CategoryViewController) {
        self.viewController = viewController
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewController else { return }
        viewController.selectedIndexPath.flatMap { tableView.cellForRow(at: $0) }?.accessoryType = .none
        viewController.selectedIndexPath = indexPath
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        let titleCategory = viewController.getCategoryTitle(viewController.getListOfCategories()[indexPath.row].title)
        viewController.delegate?.updateCategorySubtitle(from: titleCategory, at: viewController.selectedIndexPath)
    }
}
