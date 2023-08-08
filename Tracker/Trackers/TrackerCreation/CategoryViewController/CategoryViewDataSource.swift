import UIKit

final class CategoryViewDataSource: NSObject & UITableViewDataSource {
    private weak var viewController: CategoryViewController?

    init(viewController: CategoryViewController) {
        self.viewController = viewController
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewController?.getListOfCategories().count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier, for: indexPath)
        guard let viewController, let categoryCell = cell as? CategoryCell else { return UITableViewCell() }
        let categories = viewController.getListOfCategories()[indexPath.row]
        let title = categories.title
        let isFirstRow = indexPath.row == 0
        let isLastRow = indexPath.row == viewController.getListOfCategories().count - 1
        let isSelected = indexPath == viewController.selectedIndexPath
        categoryCell.configure(with: title, isFirstRow: isFirstRow, isLastRow: isLastRow, isSelected: isSelected)
        return categoryCell
    }
}
