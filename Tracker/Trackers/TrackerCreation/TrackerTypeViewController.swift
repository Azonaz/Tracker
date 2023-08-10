import UIKit

final class TrackerTypeViewController: UIViewController {
    weak var delegate: TrackerCollectionViewCellDelegate?

    private lazy var habitButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(tapHabitButton), for: .touchUpInside)
        return button
    }()

    private lazy var eventButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(tapEventButton), for: .touchUpInside)
        return button
    }()

    private lazy var buttonsStackView: UIStackView = {
        let buttonsStack = UIStackView()
        buttonsStack.axis = .vertical
        buttonsStack.spacing = 16
        buttonsStack.alignment = .fill
        buttonsStack.distribution = .fillEqually
        buttonsStack.addArrangedSubview(habitButton)
        buttonsStack.addArrangedSubview(eventButton)
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        return buttonsStack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            buttonsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 136)
        ])
    }

    private func createView() {
        navigationItem.title = "Создание трекера"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:
                                                                    UIColor.ypBlack]
        view.backgroundColor = .ypWhite
        view.addSubview(buttonsStackView)
        activateConstraints()
    }

    @objc
    private func tapHabitButton() {
        let habitViewController = CreateNewTrackerViewController(isHabit: true)
        habitViewController.delegate = delegate
        let navigationController = UINavigationController(rootViewController: habitViewController)
        present(navigationController, animated: true)
    }

    @objc
    private func tapEventButton() {
        let eventViewController = CreateNewTrackerViewController(isHabit: false)
        eventViewController.delegate = delegate
        let navigationController = UINavigationController(rootViewController: eventViewController)
        present(navigationController, animated: true)
    }
}
