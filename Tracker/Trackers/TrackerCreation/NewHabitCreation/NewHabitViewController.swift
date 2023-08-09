import UIKit

protocol UpdateSubtitleDelegate: AnyObject {
    func updateCategorySubtitle(from string: String?, at indexPath: IndexPath?)
    func updateScheduleSubtitle(from weekday: [Weekday]?, at selectedWeekday: [Int: Bool])
}

final class NewHabitViewController: UIViewController {

    weak var delegate: TrackerCollectionViewCellDelegate?
    var indexCategory: IndexPath?
    private let mockData = MockData.shared
    private var tableTitles: [String] = []
    private var isHabit: Bool
    private lazy var titleCells: [String] = {
        isHabit ? ["Категория", "Расписание"] : ["Категория"]
    }()
 //   private var tableHeight: CGFloat = 0
  //  let trackerType: TrackerType
    private var trackerTitle: String = ""
    private var categorySubtitle: String = ""
    private lazy var scheduleSubtitle: [Weekday] = {
        isHabit ? [] : Weekday.allCases
    }()
    private var selectedWeekdays: [Int: Bool] = [:]
    private var tableViewDataSource: NewHabbitViewDataSource?
    private var tableViewDelegate: NewHabbitViewDelegate?

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .ypBackground
        textField.textColor = .ypBlack
        textField.clearButtonMode = .whileEditing
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode =  .always
        let attribute: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.ypGray]
        textField.attributedPlaceholder = NSAttributedString(string: "Введите название трекера", attributes: attribute)
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.delegate = self
        return textField
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRed
        label.isHidden = true
        label.text = "Ограничение 38 символов"
        label.textAlignment = .center
        return label
    }()

    private lazy var textFieldStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(errorLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var habitTableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 75
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(NewHabitCell.self, forCellReuseIdentifier: NewHabitCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypRed, for: .normal)
        button.setTitle("Отменить", for: .normal)
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.addTarget(self, action: #selector(tapCancelButton), for: .touchUpInside)
        return button
    }()

    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.backgroundColor = .ypGray
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.setTitle("Создать", for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(tapCreateButton), for: .touchUpInside)
        return button
    }()

    private lazy var buttonStackView: UIStackView = {
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 8
        buttonStack.alignment = .fill
        buttonStack.distribution = .fillEqually
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(createButton)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        return buttonStack
    }()

    init(isHabit: Bool) {
        self.isHabit = isHabit
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewDataSource = NewHabbitViewDataSource(viewController: self)
        tableViewDelegate = NewHabbitViewDelegate(viewController: self)
        createView()
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            textFieldStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textFieldStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textFieldStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.leadingAnchor.constraint(equalTo: textFieldStackView.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: textFieldStackView.trailingAnchor),
            errorLabel.heightAnchor.constraint(equalToConstant: 38),
            habitTableView.topAnchor.constraint(equalTo: textFieldStackView.bottomAnchor, constant: 24),
            habitTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            habitTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            habitTableView.heightAnchor.constraint(equalToConstant: isHabit ? 150 : 75),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func createView() {
        view.backgroundColor = .ypWhite
        navigationItem.title = isHabit ? "Новая привычка" : "Новое нерегулярное событие"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:
                                                                    UIColor.ypBlack]
        navigationItem.hidesBackButton = true
        view.addSubview(textFieldStackView)
        view.addSubview(habitTableView)
        view.addSubview(buttonStackView)
        activateConstraints()
    }

    private func createTracker() {
        if let text = nameTextField.text, !text.isEmpty {
            trackerTitle = text
        }
        let newTracker = Tracker(id: UUID(),
                                 title: trackerTitle,
                                 color: colorSelection.randomElement() ?? UIColor(),
                                 emodji: emodjies.randomElement() ?? String(),
                                 schedule: scheduleSubtitle)
        let categoryTitle = categorySubtitle
        if let index = mockData.categories.firstIndex(where: {
            $0.title == categoryTitle
        }) {
            let existingCategory = mockData.categories[index]
            let updatedTrackers = existingCategory.trackers + [newTracker]
            let updatedCategory = TrackerCategory(
                title: existingCategory.title,
                trackers: updatedTrackers
            )
            mockData.categories[index] = updatedCategory
        } else {
            let newCategory = TrackerCategory(
                title: categoryTitle,
                trackers: [newTracker]
            )
            mockData.update(categories: [newCategory])
        }
    }

    func getTitles() -> [String] {
        titleCells
    }

    func getCategorySubtitle() -> String {
        categorySubtitle
    }

    func getSchedule() -> [Weekday] {
        scheduleSubtitle
    }

    func getSelectedWeekdays() -> [Int: Bool] {
        selectedWeekdays
    }

    func getScheduleSubtitle(from selectedWeekdays: [Weekday]) -> String {
        if selectedWeekdays == Weekday.allCases {
            return "Каждый день"
        } else {
            return selectedWeekdays.compactMap { $0.weekdayShortName }.joined(separator: ", ")
        }
    }

    @objc
    private func tapCancelButton() {
        dismiss(animated: true)
    }

    @objc
    private func tapCreateButton() {
        createTracker()
        delegate?.updateTrackers()
        var currentViewController = self.presentingViewController
        while currentViewController is UINavigationController {
            currentViewController = currentViewController?.presentingViewController
        }
        currentViewController?.dismiss(animated: true)
    }
}

extension NewHabitViewController: UITextFieldDelegate {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = textField.text, !text.isEmpty else { return true }
        let newTextLength = text.count + string.count - range.length
        errorLabel.isHidden = (newTextLength <= 38)
        if newTextLength >= 1 {
            createButton.isEnabled = true
            createButton.backgroundColor = UIColor.ypBlack
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = UIColor.gray
        }
        return newTextLength <= 38
    }
}

extension NewHabitViewController: UpdateSubtitleDelegate {
    func updateCategorySubtitle(from string: String?, at indexPath: IndexPath?) {
        categorySubtitle = string ?? ""
        indexCategory = indexPath
        let indexPath = IndexPath(row: 0, section: 0)
        habitTableView.reloadRows(at: [indexPath], with: .none)
    }

    func updateScheduleSubtitle(from weekday: [Weekday]?, at selectedWeekday: [Int: Bool]) {
        scheduleSubtitle = weekday ?? []
        selectedWeekdays = selectedWeekday
        let indexPath = IndexPath(row: 1, section: 0)
        habitTableView.reloadRows(at: [indexPath], with: .none)
    }
}
