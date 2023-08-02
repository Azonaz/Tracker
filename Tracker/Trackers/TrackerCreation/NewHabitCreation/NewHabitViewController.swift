import UIKit

protocol NewHabitViewControllerDelegate: AnyObject {
    func addNewHabit(_ trackerCategory: TrackerCategory)
}

final class NewHabitViewController: UIViewController {
    
    weak var delegate: NewHabitViewControllerDelegate?
    
    private var category: String?
    private var schedule: [String] = []
    private var newHabitTitle: String = ""
    private var choosenSchedule: [String] = []
    
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        return textField
    }()
    
    private lazy var errorLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRed
        label.isHidden = true
        label.text = "Ограничение 38 символов"
        return label
    }()
    
    private lazy var searchStackView: UIStackView = {
        let searchStack = UIStackView()
        searchStack.axis = .vertical
        searchStack.alignment = .center
        searchStack.addArrangedSubview(nameTextField)
        searchStack.addArrangedSubview(errorLabel)
        searchStack.translatesAutoresizingMaskIntoConstraints = false
        return searchStack
    }()
    
    private lazy var habitTableView: UITableView = {
       let tableView = UITableView()
        tableView.backgroundColor = .ypWhite
        tableView.layer.cornerRadius = 16
        tableView.separatorColor = .ypGray
        tableView.isScrollEnabled = false
        tableView.register(NewHabitCell.self, forCellReuseIdentifier: NewHabitCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
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
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            searchStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            searchStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.leadingAnchor.constraint(equalTo: searchStackView.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: searchStackView.trailingAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            errorLabel.heightAnchor.constraint(equalToConstant: 38),
            habitTableView.topAnchor.constraint(equalTo: searchStackView.bottomAnchor, constant: 24),
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
        view.addSubview(titleLabel)
        view.addSubview(searchStackView)
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
            delegate.addNewHabit(TrackerCategory(title: category, trackers: [Tracker(id: UUID(), title: text, color: .ColorSelection1 ?? .red, emodji: emodjies[3], schedule: choosenSchedule)]))
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
            let viewController = CategoryViewController()
            navigationController?.pushViewController(viewController, animated: true)
        case 1:
            let viewController = ScheduleViewController()
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
    // swiftlint:disable force_cast
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewHabitCell.reuseIdentifier, for: indexPath) as! NewHabitCell
        cell.backgroundColor = .ypBackground
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Категории"
        case 1:
            cell.textLabel?.text = "Расписание"
        default:
            break
        }
        return cell
    }
    // swiftlint:disable force_cast
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        
        if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.clipsToBounds = true
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == numberOfRows - 1 {
            cell.layer.cornerRadius = 16
            cell.clipsToBounds = true
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
}

extension NewHabitViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxStringLength = 38
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        if newString.count > maxStringLength {
            showErrorLabel()
        } else {
            hideErrorLabel()
        }
        return newString.count <= maxStringLength
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        newHabitTitle = textField.text ?? ""
        hideErrorLabel()
        return true
    }
    
    private func showErrorLabel() {
        guard errorLabel.isHidden else { return }
        self.errorLabel.isHidden = false
        self.searchStackView.layoutIfNeeded()
    }
    
    private func hideErrorLabel() {
        guard !errorLabel.isHidden else { return }
        self.errorLabel.isHidden = true
        self.searchStackView.layoutIfNeeded()
    }
}
