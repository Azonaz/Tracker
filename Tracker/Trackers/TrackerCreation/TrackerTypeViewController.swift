import UIKit

final class TrackerTypeViewController: UIViewController {
    
    private var newHabitVC: UIViewController?
    private var newEventVC: UIViewController?
    
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.text = "Создание трекера"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
    
    init(newHabitVC: UIViewController? = nil, newEventVC: UIViewController? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.newHabitVC = newHabitVC
        self.newEventVC = newEventVC
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            buttonsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 31.5),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 136)
        ])
    }
    
    private func createView() {
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .ypWhite
        view.addSubview(titleLabel)
        view.addSubview(buttonsStackView)
        activateConstraints()
    }
    
    @objc
    private func tapHabitButton() {
        guard let newHabitVC else { return }
        navigationController?.pushViewController(newHabitVC, animated: true)
    }
    
    @objc
    private func tapEventButton() {
        guard let newEventVC else { return }
        navigationController?.pushViewController(newEventVC, animated: true)
    }
}
