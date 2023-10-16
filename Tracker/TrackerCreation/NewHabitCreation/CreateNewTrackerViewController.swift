import UIKit

protocol UpdateCellSubtitleDelegate: AnyObject {
    func updateCategorySubtitle(with name: String?, at indexPath: IndexPath?)
    func updateScheduleSubtitle(with days: [Weekday]?, at scheduleSelectedDays: [Int: Bool])
}

final class CreateNewTrackerViewController: UIViewController {
    weak var delegate: TrackerCollectionViewCellDelegate?
    var indexCategory: IndexPath?
    var trackerToEdit: Tracker?
    var categoryEditTracker: String?
    var recordsLabel: String?
    private let colorMarshalling = UIColorMarshalling()
    private let trackerStore: TrackerStoreProtocol = TrackerStore()
    let trackerCategoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore()
    private let collectionViewHeaders = [headerCollectionViewEmodji, headerCollectionViewColor]
    private var tableTitles: [String] = []
    private var isHabit: Bool
    private lazy var titleCells: [String] = { isHabit ? [headerCategory, headerSchedule] : [headerCategory] }()
    private var trackerTitle: String = ""
    private var categorySubtitle: String = ""
    private lazy var scheduleSubtitle: [Weekday] = { isHabit ? [] : Weekday.allCases }()
    private var scheduleSelectedDays: [Int: Bool] = [:]
    private var tableViewDataSource: NewTrackerDataSource?
    private var tableViewDelegate: NewTrackerDelegate?
    private var emodji: String?
    private var color: UIColor?
    private var selectedIndexEmodjy: IndexPath?
    private var selectedIndexColor: IndexPath?
    private var checkButtonText: String = ""
    private var trackerToEditID = UUID()

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

    private lazy var recordsQuantity: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .ypBackground
        textField.textColor = .ypBlack
        textField.clearButtonMode = .whileEditing
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        let attribute: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.ypGray]
        textField.attributedPlaceholder = NSAttributedString(string: newTrackerTextBarPlaceholderText,
                                                             attributes: attribute)
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
        label.text = errorLabelText
        label.textAlignment = .center
        return label
    }()

    private lazy var textFieldStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(errorLabel)
        return stackView
    }()

    private lazy var habitTableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 75
        tableView.isScrollEnabled = false
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
        tableView.register(NewTrackerSubtitleCell.self, forCellReuseIdentifier: NewTrackerSubtitleCell.reuseIdentifier)
        return tableView
    }()

    private lazy var emodjiCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .ypWhite
        collectionView.allowsMultipleSelection = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(NewTrackerEmodjiCollectionCell.self,
                                forCellWithReuseIdentifier: NewTrackerEmodjiCollectionCell.reuseIdentifier)
        collectionView.register(NewTrackerCollectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: NewTrackerCollectionHeader.reuseIdentifier)
        return collectionView
    }()

    private lazy var colorCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .ypWhite
        collectionView.allowsMultipleSelection = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(NewTrackerColorCollectionCell.self,
                                forCellWithReuseIdentifier: NewTrackerColorCollectionCell.reuseIdentifier)
        collectionView.register(NewTrackerCollectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: NewTrackerCollectionHeader.reuseIdentifier)
        return collectionView
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypRed, for: .normal)
        button.setTitle(cancelButtonText, for: .normal)
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
        button.setTitle(checkButtonText, for: .normal)
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
        if trackerToEdit != nil {
            checkButtonText = saveButtonText
        } else {
            checkButtonText = createButtonText
        }
        createView()
        createEditTrackerView()
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
            textFieldStackView.topAnchor.constraint(equalTo: trackerToEdit != nil ? recordsQuantity.bottomAnchor
                                                    : containView.topAnchor, constant: 24),
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
            emodjiCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            emodjiCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            emodjiCollectionView.topAnchor.constraint(equalTo: habitTableView.bottomAnchor, constant: 16),
            emodjiCollectionView.heightAnchor.constraint(equalToConstant: 232),
            colorCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            colorCollectionView.topAnchor.constraint(equalTo: emodjiCollectionView.bottomAnchor),
            colorCollectionView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 232)
        ])
    }

    private func createView() {
        view.backgroundColor = .ypWhite
        let standartTitle = isHabit ? newHabbitText : newEventText
        let isEditTitle = trackerToEdit != nil
        navigationItem.title = isEditTitle ? editHabbitText : standartTitle
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:
                                                                    UIColor.ypBlack]
        navigationItem.hidesBackButton = true
        view.addSubview(scrollView)
        scrollView.addSubview(containView)
        if trackerToEdit != nil {
            containView.addSubview(recordsQuantity)
            NSLayoutConstraint.activate([
                recordsQuantity.topAnchor.constraint(equalTo: containView.topAnchor, constant: 24),
                recordsQuantity.leadingAnchor.constraint(equalTo: containView.leadingAnchor, constant: 16),
                recordsQuantity.trailingAnchor.constraint(equalTo: containView.trailingAnchor, constant: -16),
                recordsQuantity.heightAnchor.constraint(equalToConstant: 38)
            ])}
        [textFieldStackView, habitTableView, buttonStackView, emodjiCollectionView, colorCollectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containView.addSubview($0)
        }
        activateConstraints()
    }

    private func createEditTrackerView() {
        guard let tracker = trackerToEdit else { return }
        trackerToEditID = tracker.id
        nameTextField.text = tracker.title
        recordsQuantity.text = recordsLabel
        categorySubtitle = categoryEditTracker ?? ""
        scheduleSubtitle = tracker.schedule
        if let emodjiIndex = emodjies.firstIndex(of: tracker.emodji) {
            selectedIndexEmodjy = IndexPath(row: emodjiIndex, section: 0)
        }
        if let colorIndex = colorSelection.firstIndex(where: {
            colorMarshalling.getHexString(from: $0) == colorMarshalling.getHexString(from: tracker.color)
        }) {
            selectedIndexColor = IndexPath(row: colorIndex, section: 0)
        }
        for (index, day) in Weekday.allCases.enumerated() where scheduleSubtitle.contains(day) {
            scheduleSelectedDays[index] = true
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let emodjiIndexPath = self.selectedIndexEmodjy {
                self.emodjiCollectionView.selectItem(at: emodjiIndexPath, animated: false, scrollPosition: [])
                self.collectionView(self.emodjiCollectionView, didSelectItemAt: emodjiIndexPath)
            }
            if let colorIndexPath = self.selectedIndexColor {
                self.colorCollectionView.selectItem(at: colorIndexPath, animated: false, scrollPosition: [])
                self.collectionView(self.colorCollectionView, didSelectItemAt: colorIndexPath)
            }
        }
        checkCreateButton()
    }
}

extension CreateNewTrackerViewController {
    func getCellTitles() -> [String] {
        titleCells
    }

    func getCategorySubtitle() -> String {
        categorySubtitle
    }

    func getSchedule() -> [Weekday] {
        scheduleSubtitle
    }

    func getScheduleSelectedDays() -> [Int: Bool] {
        scheduleSelectedDays
    }

    func getScheduleSubtitle(from scheduleSelectedDays: [Weekday]) -> String {
        if scheduleSelectedDays == Weekday.allCases {
            return everyDayText
        } else {
            return scheduleSelectedDays.compactMap { $0.weekdayShortName }.joined(separator: ", ")
        }
    }

    private func createTracker() {
        let categoryTitle = categorySubtitle
        let newTracker = Tracker(id: UUID(),
                                 title: nameTextField.text ?? "",
                                 color: color ?? UIColor(),
                                 emodji: emodji ?? String(),
                                 schedule: scheduleSubtitle,
                                 isPinned: false)
        do {
            let categories = try trackerCategoryStore.getTrackerCategories()
            if let foundCategory = categories.first(where: { $0.title == categoryTitle }) {
                let updatedCategoryTrackers = foundCategory.trackers + [newTracker]
                let updatedCategory = TrackerCategory(title: foundCategory.title, trackers: updatedCategoryTrackers)
                try trackerStore.addTracker(newTracker, in: updatedCategory)
            } else {
                let newCategory = TrackerCategory(title: categoryTitle, trackers: [newTracker])
                try trackerStore.addTracker(newTracker, in: newCategory)
            }
        } catch {
            showSaveAlert(message: errorSaveTrackerAlert)
        }
    }

    private func editTracker(id: UUID) {
        let categoryTitle = categorySubtitle
        let trackerToEdit = Tracker(id: id,
                                    title: nameTextField.text ?? "",
                                    color: color ?? UIColor(),
                                    emodji: emodji ?? String(),
                                    schedule: scheduleSubtitle,
                                    isPinned: false)
        do {
            let categories = try trackerCategoryStore.getTrackerCategories()
            if let foundCategory = categories.first(where: { $0.title == categoryTitle }) {
                let updatedCategoryTrackers = foundCategory.trackers + [trackerToEdit]
                let updatedCategory = TrackerCategory(title: foundCategory.title, trackers: updatedCategoryTrackers)
                try trackerStore.editTracker(trackerToEdit, in: updatedCategory)
            } else {
                let newCategory = TrackerCategory(title: categoryTitle, trackers: [trackerToEdit])
                try trackerStore.editTracker(trackerToEdit, in: newCategory)
            }
        } catch {
            showSaveAlert(message: errorSaveTrackerAlert)
        }
    }

    private func showSaveAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    private func checkCreateButton() {
        let isEmodjiSelected = emodji != nil
        let isColorSelected = color != nil
        let isCategorySubtitleFilled = !categorySubtitle.isEmpty
        let isScheduleSubtitleFilled = !scheduleSubtitle.isEmpty || !scheduleSelectedDays.isEmpty
        let isNameFilled = !(nameTextField.text?.isEmpty ?? true)
        createButton.isEnabled = isEmodjiSelected && isColorSelected && isCategorySubtitleFilled &&
        isScheduleSubtitleFilled && isNameFilled
        createButton.backgroundColor = createButton.isEnabled ? UIColor.ypBlack : UIColor.gray
    }

    @objc
    private func tapCancelButton() {
        dismiss(animated: true)
    }

    @objc
    private func tapCreateButton() {
        if trackerToEdit != nil {
            editTracker(id: trackerToEditID)
        } else {
            createTracker()
        }
        delegate?.updateTrackers()
        var currentViewController = self.presentingViewController
        while currentViewController is UINavigationController {
            currentViewController = currentViewController?.presentingViewController
        }
        currentViewController?.dismiss(animated: true)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        view.endEditing(true)
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
        guard let text = textField.text else { return true }
        let newTextLength = text.count + string.count - range.length
        errorLabel.isHidden = newTextLength <= 38
        checkCreateButton()
        return newTextLength <= 38
    }
}

extension CreateNewTrackerViewController: UpdateCellSubtitleDelegate {
    func updateCategorySubtitle(with string: String?, at indexPath: IndexPath?) {
        categorySubtitle = string ?? ""
        checkCreateButton()
        indexCategory = indexPath
        let indexPath = IndexPath(row: 0, section: 0)
        habitTableView.reloadRows(at: [indexPath], with: .none)
    }

    func updateScheduleSubtitle(with weekday: [Weekday]?, at selectedDays: [Int: Bool]) {
        scheduleSubtitle = weekday ?? []
        checkCreateButton()
        scheduleSelectedDays = selectedDays
        let indexPath = IndexPath(row: 1, section: 0)
        habitTableView.reloadRows(at: [indexPath], with: .none)
    }
}

extension CreateNewTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emodjiCollectionView {
            if let previousSelectedIndexPath = selectedIndexEmodjy {
                collectionView.deselectItem(at: previousSelectedIndexPath, animated: false)
                let previousSelectedCell = collectionView.cellForItem(at: previousSelectedIndexPath)
                previousSelectedCell?.layer.cornerRadius = 0
                previousSelectedCell?.backgroundColor = .clear
            }
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.cornerRadius = 16
            cell?.backgroundColor = .ypLightGray
            selectedIndexEmodjy = indexPath
            emodji = emodjies[indexPath.row]
        } else if collectionView == colorCollectionView {
            if let previousSelectedIndexPath = selectedIndexColor {
                collectionView.deselectItem(at: previousSelectedIndexPath, animated: false)
                let previousSelectedCell = collectionView.cellForItem(at: previousSelectedIndexPath)
                previousSelectedCell?.layer.borderWidth = 0
            }
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.borderWidth = 3
            cell?.layer.cornerRadius = 16
            let borderColor = colorSelection[indexPath.item].withAlphaComponent(0.3)
            cell?.layer.borderColor = borderColor.cgColor
            selectedIndexColor = indexPath
            color = colorSelection[indexPath.row]
        }
        checkCreateButton()
    }
}

extension CreateNewTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 34)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
    }
}

extension CreateNewTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emodjiCollectionView {
            return emodjies.count
        } else if collectionView == colorCollectionView {
            return colorSelection.count
        } else {
            return 18
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emodjiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
                                                                    NewTrackerEmodjiCollectionCell.reuseIdentifier,
                                                                for: indexPath) as? NewTrackerEmodjiCollectionCell
            else {
                return UICollectionViewCell()
            }
            cell.addEmodji(emodjies[indexPath.row])
            return cell
        } else if collectionView == colorCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
                                                                    NewTrackerColorCollectionCell.reuseIdentifier,
                                                                for: indexPath) as? NewTrackerColorCollectionCell
            else {
                return UICollectionViewCell()
            }
            cell.addColor(colorSelection[indexPath.row])
            return cell
        } else {
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:
                                                                            NewTrackerCollectionHeader.reuseIdentifier,
                                                                         for: indexPath) as? NewTrackerCollectionHeader
        else {
            return UICollectionReusableView()
        }
        if collectionView == emodjiCollectionView {
                view.addHeader(collectionViewHeaders[0])
            } else if collectionView == colorCollectionView {
                view.addHeader(collectionViewHeaders[1])
            }
        return view
    }
}
