import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func addWeekdays(_ weekdays: [Int])
}

final class ScheduleViewController: UIViewController {
    weak var delegate: ScheduleViewControllerDelegate?
    private var dayList: [Int] = []
    private var switchOn: [Int: Bool] = [:]
    private var calendar = Calendar.current
    private var days = [String]()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.separatorColor = .ypGray
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.reuseIdentifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(tapAddButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(choosenDay: [Int]) {
        super.init(nibName: nil, bundle: nil)
        calendar.locale = Locale(identifier: "ru_RU")
        days = calendar.weekdaySymbols
        dayList = choosenDay
        changingSwitch()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
        configWeekdays()
        tableView.reloadData()
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -38),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func createView() {
        view.backgroundColor = .ypWhite
        navigationItem.title = "Расписание"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.ypBlack as Any]
        navigationItem.hidesBackButton = true
        view.addSubview(tableView)
        view.addSubview(addButton)
        activateConstraints()
    }
    
    @objc
    private func tapAddButton(_ sender: UISwitch!) {
        dayList.removeAll()
        let tableView = tableView
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                guard let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as? ScheduleCell else { continue }
                guard cell.switchDay.isOn else { continue }
                guard let text = cell.textLabel?.text else { continue }
                guard let weekday = getIndexOfWeek(text) else { continue }
                dayList.append(weekday)
            }
        }
        delegate?.addWeekdays(dayList)
        navigationController?.popViewController(animated: true)
    }
    
    func changingSwitch () {
        for (index, day) in days.enumerated() {
            let weekdayIndex = calendar.weekdaySymbols.firstIndex(of: day.lowercased()) ?? 0
            if dayList.contains(weekdayIndex + 1) {
                switchOn[index] = true
            } else {
                switchOn[index] = false
            }
        }
    }
    
    func configWeekdays() {
        let weekdaysSymbol = calendar.weekdaySymbols
        let firstDayIndex = 1
        let weekdays = Array(weekdaysSymbol[firstDayIndex...]) + Array(weekdaysSymbol[..<firstDayIndex])
        days = weekdays.map { $0 }
    }
    
    private func getIndexOfWeek(_ text: String) -> Int? {
        return calendar.weekdaySymbols.firstIndex(of: text.lowercased())
    }
}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource, ScheduleCellDelegate {
    func changeSwitch(_ cell: ScheduleCell, isOn: Bool) {
        if let indexPath = tableView.indexPath(for: cell) {
            switchOn[indexPath.row] = isOn
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.reuseIdentifier)
                as? ScheduleCell else { return UITableViewCell()}
        cell.backgroundColor = .ypBackground
        cell.textLabel?.text = days[indexPath.row]
        let switchOn = switchOn[indexPath.row] ?? false
        cell.switchDay.isOn = switchOn
        cell.delegate = self
        let numbersOfRows = tableView.numberOfRows(inSection: 0)
        if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.clipsToBounds = true
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == numbersOfRows - 1 {
            cell.layer.cornerRadius = 16
            cell.clipsToBounds = true
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        if tableView.numberOfRows(inSection: indexPath.section) - 1 == indexPath.row {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGRectGetWidth(tableView.bounds))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
