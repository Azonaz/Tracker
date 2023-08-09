import UIKit

final class NewTrackerDataSource: NSObject, UITableViewDataSource {
    private weak var viewController: CreateNewTrackerViewController?

    init(viewController: CreateNewTrackerViewController) {
        self.viewController = viewController
        super.init()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewController?.getTitles().count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewTrackerSubtitleCell.reuseIdentifier, for: indexPath)
        guard let viewController, let itemCell = cell as? NewTrackerSubtitleCell else { return UITableViewCell() }
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
