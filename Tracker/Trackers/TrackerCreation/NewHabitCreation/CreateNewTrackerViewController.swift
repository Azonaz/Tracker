import UIKit

protocol UpdateCellSubtitleDelegate: AnyObject {
    func updateCategorySubtitle(from string: String?, at indexPath: IndexPath?)
    func updateScheduleSubtitle(from weekday: [Weekday]?, at selectedWeekday: [Int: Bool])
}

final class CreateNewTrackerViewController: UIViewController {

    weak var delegate: TrackerCollectionViewCellDelegate?
    var indexCategory: IndexPath?
    private let mockData = MockData.shared
    private let collectionViewHeaders = ["Emodji", "Цвет"]
    private var tableTitles: [String] = []
    private var isHabit: Bool
    private lazy var titleCells: [String] = {
        isHabit ? ["Категория", "Расписание"] : ["Категория"]
    }()
    private var trackerTitle: String = ""
    private var categorySubtitle: String = ""
    private lazy var scheduleSubtitle: [Weekday] = {
        isHabit ? [] : Weekday.allCases
    }()
    private var selectedWeekdays: [Int: Bool] = [:]
    private var tableViewDataSource: NewTrackerDataSource?
    private var tableViewDelegate: NewTrackerDelegate?

    private lazy var scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var containView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .ypBackground
        textField.textColor = .ypBlack
        textField.clearButtonMode = .whileEditing
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
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
        tableView.register(NewTrackerSubtitleCell.self, forCellReuseIdentifier: NewTrackerSubtitleCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .ypWhite
        collectionView.allowsMultipleSelection = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(NewTrackerCollectionCell.self,
                                forCellWithReuseIdentifier: NewTrackerCollectionCell.reuseIdentifier)
        collectionView.register(NewTrackerCollectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: NewTrackerCollectionHeader.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
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
        tableViewDataSource = NewTrackerDataSource(viewController: self)
        tableViewDelegate = NewTrackerDelegate(viewController: self)
        createView()
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            containView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            containView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            containView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            containView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            containView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            containView.heightAnchor.constraint(greaterThanOrEqualTo: collectionView.heightAnchor),
            textFieldStackView.topAnchor.constraint(equalTo: containView.topAnchor, constant: 24),
            textFieldStackView.leadingAnchor.constraint(equalTo: containView.leadingAnchor, constant: 16),
            textFieldStackView.trailingAnchor.constraint(equalTo: containView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.leadingAnchor.constraint(equalTo: textFieldStackView.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: textFieldStackView.trailingAnchor),
            errorLabel.heightAnchor.constraint(equalToConstant: 38),
            habitTableView.topAnchor.constraint(equalTo: textFieldStackView.bottomAnchor, constant: 24),
            habitTableView.leadingAnchor.constraint(equalTo: containView.leadingAnchor, constant: 16),
            habitTableView.trailingAnchor.constraint(equalTo: containView.trailingAnchor, constant: -16),
            habitTableView.heightAnchor.constraint(equalToConstant: isHabit ? 150 : 75),
            buttonStackView.bottomAnchor.constraint(equalTo: containView.bottomAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: containView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: containView.trailingAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            collectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: habitTableView.bottomAnchor, constant: 16),
            collectionView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: 464)
        ])
    }

    private func createView() {
        view.backgroundColor = .ypWhite
        navigationItem.title = isHabit ? "Новая привычка" : "Новое нерегулярное событие"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:
                                                                    UIColor.ypBlack]
        navigationItem.hidesBackButton = true
        view.addSubview(scrollView)
        scrollView.addSubview(containView)
        containView.addSubview(textFieldStackView)
        containView.addSubview(habitTableView)
        containView.addSubview(buttonStackView)
        containView.addSubview(collectionView)
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

extension CreateNewTrackerViewController: UITextFieldDelegate {

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

extension CreateNewTrackerViewController: UpdateCellSubtitleDelegate {
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

extension CreateNewTrackerViewController: UICollectionViewDelegate {
}

extension CreateNewTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind:
                                                UICollectionView.elementKindSectionHeader, at: indexPath)
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: 34),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
    }
}

extension CreateNewTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return emodjies.count
        case 1:
            return colorSelection.count
        default:
            return 18
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
                                                                NewTrackerCollectionCell.reuseIdentifier,
                                                            for: indexPath) as? NewTrackerCollectionCell
        else {
            return UICollectionViewCell()
        }
        switch indexPath.section {
        case 0:
            cell.addEmodji(emodjies[indexPath.row])
        default:
            cell.addColor(colorSelection[indexPath.row])
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:
                                                                            NewTrackerCollectionHeader.reuseIdentifier,
                                                                         for: indexPath) as? NewTrackerCollectionHeader
        else {
            return UICollectionReusableView()
        }
        let header = collectionViewHeaders[indexPath.section]
        view.addHeader(header)
        return view
    }
}
