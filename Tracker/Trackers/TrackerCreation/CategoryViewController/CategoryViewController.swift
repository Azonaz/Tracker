import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func addCategory(_ category: String, index: Int)
}

final class CategoryViewController: UIViewController {
    weak var delegate: CategoryViewControllerDelegate?
    
    private var mockCategory = ["Дом", "Важное", "Здоровье"]
    private var selectIndex: Int?
    private var categoryTableViewHeightConstraint: NSLayoutConstraint?
    
    private lazy var placeholderImage: UIView = {
        let placeholderImage = UIImageView()
        placeholderImage.image = .emptyTrackers
        return placeholderImage
    }()
    
    private lazy var placeholderText: UILabel = {
        let placeholderText = UILabel()
        placeholderText.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        placeholderText.textColor = .ypBlack
        placeholderText.textAlignment = .center
        placeholderText.numberOfLines = 2
        placeholderText.text = """
Привычки и события можно
объединить по смыслу
"""
        return placeholderText
    }()
    
    private lazy var placeholderStackView: UIStackView = {
        let placeholderStack = UIStackView()
        placeholderStack.axis = .vertical
        placeholderStack.spacing = 8
        placeholderStack.alignment = .center
        placeholderStack.distribution = .equalSpacing
        placeholderStack.addArrangedSubview(placeholderImage)
        placeholderStack.addArrangedSubview(placeholderText)
        placeholderStack.translatesAutoresizingMaskIntoConstraints = false
        return placeholderStack
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.separatorColor = .ypGray
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.backgroundColor = .ypBlack
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(nil, action: #selector(tapAddButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(selectIndex: Int?) {
        super.init(nibName: nil, bundle: nil)
        self.selectIndex = selectIndex
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
        checkPlaceholder()
    }
    
    private func activateConstraints() {
        categoryTableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: CGFloat(mockCategory.count * 75))
        categoryTableViewHeightConstraint?.isActive = true
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func createView() {
        view.backgroundColor = .ypWhite
        navigationItem.title = "Категория"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.ypBlack as Any]
        navigationItem.hidesBackButton = true
        view.addSubview(placeholderStackView)
        view.addSubview(tableView)
        view.addSubview(addCategoryButton)
        activateConstraints()
    }
    
    private func checkPlaceholder() {
        if mockCategory.count != 0 {
            placeholderStackView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        } else {
            tableView.isHidden = true
            placeholderStackView.isHidden = false
        }
    }
    
    @objc
    private func tapAddButton() {
       
    }
}

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mockCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier,
                                                       for: indexPath) as? CategoryCell else { return UITableViewCell()}
        cell.backgroundColor = .ypBackground
        cell.textLabel?.text = mockCategory[indexPath.row]
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let lastRow = tableView.numberOfRows(inSection: indexPath.section) - 1
        if indexPath.row == lastRow {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectCategory = mockCategory[indexPath.row]
        delegate?.addCategory(selectCategory, index: selectIndex ?? 0)
        navigationController?.popViewController(animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
        // tableView.reloadData()
    }
    
    //    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //        let rowNumbers = tableView.numberOfRows(inSection: 0)
    //    }
    
}
