import UIKit

protocol NewHabitViewControllerDelegate: AnyObject {
    func addNewHabit(_ trackerCategory: TrackerCategory)
}

final class NewHabitViewController: UIViewController {
    
    weak var delegate: NewHabitViewControllerDelegate?
    
    private var category: String?
    //   private var schedule: [String] = []
    // private var newHabitTitle: String = ""
    private var choosenCategoryIndex: Int?
    private var choosenSchedule: [Int] = []
    //    private var categoryName: String = ""
 //   private var schedule: [Weekday] = []
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .ypBackground
        textField.textColor = .ypBlack
        textField.clearButtonMode = .whileEditing
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode =  .always
        let attribute: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.ypGray as Any]
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
        //    label.textAlignment = .center
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
        tableView.layer.cornerRadius = 16
        tableView.separatorColor = .ypGray
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
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
        button.layer.borderColor = UIColor.ypRed?.cgColor
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
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
            habitTableView.heightAnchor.constraint(equalToConstant: 150),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func createView() {
        view.backgroundColor = .ypWhite
        navigationItem.title = "Новая привычка"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.ypBlack as Any]
        navigationItem.hidesBackButton = true
        view.addSubview(textFieldStackView)
        view.addSubview(habitTableView)
        view.addSubview(buttonStackView)
        activateConstraints()
    }
    
    private func checkCreateButton() {
        if let text = nameTextField.text,
           !text.isEmpty,
           category != nil,
           !choosenSchedule.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        }
    }
    
    @objc
    private func tapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc
    private func tapCreateButton() {
        let text = nameTextField.text ?? ""
        let category = category ?? ""
        if let delegate = delegate {
            delegate.addNewHabit(TrackerCategory(
                title: category,
                trackers: [Tracker(id: UUID(),
                                   title: text,
                                   color: .colorSelection1,
                                   emodji: "😉",
                                   schedule: choosenSchedule)]))
        }
        dismiss(animated: true)
    }
}

extension NewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let viewController = CategoryViewController(selectIndex: choosenCategoryIndex)
            viewController.delegate = self
            navigationController?.pushViewController(viewController, animated: true)
        case 1:
            let viewController = ScheduleViewController(choosenDay: choosenSchedule)
            viewController.delegate = self
            navigationController?.pushViewController(viewController, animated: true)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension NewHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewHabitCell.reuseIdentifier,
                                                       for: indexPath) as? NewHabitCell else { return UITableViewCell()}
        cell.backgroundColor = .ypBackground
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Категории"
        case 1:
            cell.textLabel?.text = "Расписание"
        default:
            break
        }
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let lastRow = tableView.numberOfRows(inSection: indexPath.section) - 1
        if indexPath.row == lastRow {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width)
        }
        return cell
    }
}

extension NewHabitViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = textField.text, !text.isEmpty else {
            return true
        }
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkCreateButton()
        textField.resignFirstResponder()
        return true
    }
    
}

extension NewHabitViewController: CategoryViewControllerDelegate {
    func addCategory(_ category: String, index: Int) {
        let indexPath = IndexPath(row: 0, section: 0)
        if let cell = habitTableView.cellForRow(at: indexPath) as? NewHabitCell {
            cell.detailTextLabel?.text = category
        }
        self.category = category
        choosenCategoryIndex = index
        checkCreateButton()
    }
    
}

extension NewHabitViewController: ScheduleViewControllerDelegate {
    func addWeekdays(_ weekdays: [Int]) {
        choosenSchedule = weekdays
        var selectDaysView = ""
        if weekdays.count == 7 {
            selectDaysView = "Каждый день"
        } else {
            for index in choosenSchedule {
                var calendar = Calendar.current
                calendar.locale = Locale(identifier: "ru_RU")
                let day = calendar.shortWeekdaySymbols[index]
                selectDaysView.append(day)
                selectDaysView.append(", ")
            }
            selectDaysView = String(selectDaysView.dropLast(2))
        }
        let indexPath = IndexPath(row: 1, section: 0)
        if let cell = habitTableView.cellForRow(at: indexPath) as? NewHabitCell {
            cell.detailTextLabel?.text = selectDaysView
        }
        checkCreateButton()
    }
    
    
}
