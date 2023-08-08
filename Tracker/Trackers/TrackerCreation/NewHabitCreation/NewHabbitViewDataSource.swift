import UIKit

final class NewHabbitViewDataSource: NSObject & UITableViewDataSource {
    private weak var viewController: NewHabitViewController?

    init(viewController: NewHabitViewController) {
        self.viewController = viewController
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewController?.getTitles().count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewHabitCell.reuseIdentifier, for: indexPath)
        guard let viewController, let itemCell = cell as? NewHabitCell else { return UITableViewCell() }
        let title = viewController.getTitles()[indexPath.row]
        let categorySubtitle = viewController.getCategorySubtitle()
        let scheduleSubtitle = viewController.getScheduleSubtitle(from: viewController.getSchedule())
        let isFirstRow = indexPath.row == 0
        itemCell.configure(with: title,
                           categorySubtitle: categorySubtitle,
                           scheduleSubtitle: scheduleSubtitle,
                           isFirstRow: isFirstRow)
        return itemCell
    }
}
