import UIKit

protocol NewCategoryViewControllerDelegate: AnyObject {
    func updateCategoriesList(with category: TrackerCategory)
}

final class NewCategoryViewController: UIViewController {
    weak var delegate: NewCategoryViewControllerDelegate?

    private lazy var newCategoryTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .ypBackground
        textField.textColor = .ypBlack
        textField.clearButtonMode = .whileEditing
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.ypGray]
        textField.attributedPlaceholder = NSAttributedString(string: "Введите название категории",
                                                             attributes: attributes)
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.addTarget(nil, action: #selector(tapAddButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        newCategoryTextField.delegate = self
        addButton.isEnabled = false
        addButton.backgroundColor = .ypGray
        createView()
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            newCategoryTextField.heightAnchor.constraint(equalToConstant: 75),
            newCategoryTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            newCategoryTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            newCategoryTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func createView() {
        view.backgroundColor = .ypWhite
        navigationItem.title = "Новая категория"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:
                                                                    UIColor.ypBlack]
        navigationItem.hidesBackButton = true
        view.addSubview(newCategoryTextField)
        view.addSubview(addButton)
        activateConstraints()
    }

    @objc
    private func tapAddButton() {
        if let text = newCategoryTextField.text, !text.isEmpty {
            let category = TrackerCategory(title: text, trackers: [])
            delegate?.updateCategoriesList(with: category)
        }
        dismiss(animated: true)
    }
}

extension NewCategoryViewController: UITextFieldDelegate {
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
        let newLength = text.count + string.count - range.length
        if newLength >= 3 && newLength <= 38 {
            addButton.isEnabled = true
            addButton.backgroundColor = .ypBlack
        } else {
            addButton.isEnabled = false
            addButton.backgroundColor = .ypGray
        }
        return newLength <= 38
    }
}
