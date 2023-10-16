import UIKit

final class ScheduleViewController: UIViewController {
    weak var delegate: UpdateCellSubtitleDelegate?
    var schedule: [Weekday] = []
    var scheduleSelectedDays: [Int: Bool] = [:]
    private var dataSource: ScheduleViewDataSource?

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 75
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = dataSource
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.reuseIdentifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return tableView
    }()

    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.setTitle(readyButtonText, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(tapAddButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = ScheduleViewDataSource(viewController: self)
        createView()
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -38),
            addButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func createView() {
        view.backgroundColor = .ypWhite
        navigationItem.title = headerSchedule
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.ypBlack]
        navigationItem.hidesBackButton = true
        [tableView, addButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        activateConstraints()
    }

    func getWeekdays() -> [String] {
        return Weekday.allCases.map { $0.weekdayFullName }
    }

    @objc
    private func tapAddButton() {
        delegate?.updateScheduleSubtitle(with: schedule, at: scheduleSelectedDays)
        dismiss(animated: true)
    }
}
