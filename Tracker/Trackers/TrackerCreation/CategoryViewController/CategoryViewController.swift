import UIKit

final class CategoryViewController: UIViewController {
    weak var delegate: UpdateCellSubtitleDelegate?
    var selectedIndexPath: IndexPath?
    private let mockData = MockData.shared
    private var categoriesList: [TrackerCategory] = []
    private var categoryTitle: String = ""
    private var tableViewDelegate: CategoryViewDelegate?
    private var tableViewDataSource: CategoryViewDataSource?

    private lazy var placeholderView: UIView = {
        PlaceholderView(image: .emptyTrackers,
                        title: """
                        Привычки и события можно
                        объединить по смыслу
                        """)
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 75
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
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

    override func viewDidLoad() {
        super.viewDidLoad()
        getCategories()
        tableViewDataSource = CategoryViewDataSource(viewController: self)
        tableViewDelegate = CategoryViewDelegate(viewController: self)
        createView()
        checkPlaceholder()
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func createView() {
        view.backgroundColor = .ypWhite
        navigationItem.title = "Категория"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:
                                                                    UIColor.ypBlack]
        navigationItem.hidesBackButton = true
        view.addSubview(placeholderView)
        view.addSubview(tableView)
        view.addSubview(addCategoryButton)
        activateConstraints()
    }

    private func getCategories() {
        categoriesList = mockData.categories
    }

    private func checkPlaceholder() {
        if categoriesList.isEmpty {
            placeholderView.isHidden = false
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
            placeholderView.isHidden = true
        }
    }

    func getCategoriesList() -> [TrackerCategory] {
        categoriesList
    }

    func getCategoryTitle(_ title: String) -> String {
        categoryTitle = title
        return categoryTitle
    }

    @objc
    func tapAddButton() {
        let newCategoryViewController = NewCategoryViewController()
        newCategoryViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: newCategoryViewController)
        present(navigationController, animated: true)
    }
}

extension CategoryViewController: NewCategoryViewControllerDelegate {

    func updateCategoriesList(with category: TrackerCategory) {
        categoriesList.append(category)
        mockData.update(categories: [category])
        checkPlaceholder()
        tableView.reloadData()
    }
}
