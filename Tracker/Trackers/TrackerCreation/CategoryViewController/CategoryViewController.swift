import UIKit

final class CategoryViewController: UIViewController {
    weak var delegate: UpdateCellSubtitleDelegate?
    var selectedIndexPath: IndexPath?
    private let trackerCategoryStore: TrackerCategoryStore = TrackerCategoryStore()
    private var categoriesList: [TrackerCategory] = []
    private var categoryTitle: String = ""
    private var tableViewDelegate: CategoryViewDelegate?
    private var tableViewDataSource: CategoryViewDataSource?

    private lazy var placeholderImage: UIImageView = {
        let image = UIImageView()
        image.image = .emptyTrackers
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    private lazy var placeholderText: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.numberOfLines = 2
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .center
        let attributedText = NSMutableAttributedString(string: """
                                                               Привычки и события можно
                                                               объединить по смыслу
                                                               """)
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle,
                                    range: NSRange(location: 0, length: attributedText.length))
        label.attributedText = attributedText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var placeholderStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.addArrangedSubview(placeholderImage)
        stackView.addArrangedSubview(placeholderText)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
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
        view.addSubview(placeholderStackView)
        view.addSubview(tableView)
        view.addSubview(addCategoryButton)
        activateConstraints()
    }

    private func getCategories() {
        do {
            categoriesList = try trackerCategoryStore.getTrackerCategories()
        } catch {
            assertionFailure("Unable to get categories' list")
        }
    }

    private func checkPlaceholder() {
        if categoriesList.isEmpty {
            placeholderStackView.isHidden = false
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
            placeholderStackView.isHidden = true
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
        do {
            try trackerCategoryStore.addTrackerCategory(category)
        } catch {
            assertionFailure("Unable to add category")
        }
        getCategories()
        tableView.reloadData()
        checkPlaceholder()
    }
}

extension CategoryViewController: TrackerCategoryStoreDelegate {
    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
        getCategories()
        tableView.performBatchUpdates {
            tableView.insertRows(at: update.insertedIndexPaths, with: .automatic)
        }
        tableView.reloadData()
    }
}
