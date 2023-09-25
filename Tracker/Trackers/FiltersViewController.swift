import UIKit

final class FiltersViewController: UIViewController {
    weak var delegate: TrackersViewController?
    var selectedFilterIndexPath: IndexPath?

    private let filters = [allTrackerFilter, todayTrackerFilter, doneTrackerFilter, undoneTrackerFilter]

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 75
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInsetReference = .fromCellEdges
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
    }

    private func createView() {
        navigationItem.title = filtersText
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:
                                                                    UIColor.ypBlack]
        view.backgroundColor = .ypWhite
        view.addSubview(tableView)
        activateConstraints()
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
}

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFilterIndexPath.flatMap { tableView.cellForRow(at: $0) }?.accessoryType = .none
        selectedFilterIndexPath = indexPath
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseIdentifier, for: indexPath)
        guard let filterCell = cell as? FilterCell else { return UITableViewCell() }
        let filter = filters[indexPath.row]
        let isFirstRow = indexPath.row == 0
        let isLastRow = indexPath.row == filters.count - 1
        let isSelected = indexPath == selectedFilterIndexPath
        filterCell.configure(with: filter,
                               isFirstRow: isFirstRow,
                               isLastRow: isLastRow,
                               isSelected: isSelected)
        return filterCell
    }
}
