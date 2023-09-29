import UIKit

final class CategoryViewController: UIViewController {
    weak var delegate: UpdateCellSubtitleDelegate?
    var selectedIndexPath: IndexPath?
    private var viewModel: CategoryViewModel = CategoryViewModel()

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
        let attributedText = NSMutableAttributedString(string: categoryPlaceholderText)
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
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle(addCategoryButtonText, for: .normal)
        button.backgroundColor = .ypBlack
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(nil, action: #selector(tapAddButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.categoriesDidChange = { [weak self] _ in
          //  print("Categories did change. New data: \(self?.viewModel.categoriesList ?? [])")
            self?.checkPlaceholder()
            self?.tableView.reloadData()
        }
        viewModel.getCategoriesList()
        createView()
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
        navigationItem.title = headerCategory
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:
                                                                    UIColor.ypBlack]
        navigationItem.hidesBackButton = true
        view.addSubview(placeholderStackView)
        view.addSubview(tableView)
        view.addSubview(addCategoryButton)
        activateConstraints()
    }

    private func checkPlaceholder() {
        if viewModel.categoriesList.isEmpty {
            placeholderStackView.isHidden = false
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
            placeholderStackView.isHidden = true
        }
    }

    func alertForDeletingCategory(at indexPath: IndexPath) {
        let alert = UIAlertController(title: categoryDeleteAlertText, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: deleteText, style: .destructive) { _ in
            self.viewModel.deleteCategory(at: indexPath)
        }
        let cancelAction = UIAlertAction(title: cancelButtonText, style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    func openEditCategory(category: TrackerCategory) {
        let newCategoryViewController = NewCategoryViewController()
        newCategoryViewController.delegate = self
        newCategoryViewController.categoryToEdit = category
        let navigationController = UINavigationController(rootViewController: newCategoryViewController)
        self.present(navigationController, animated: true)
    }

    @objc
    private func tapAddButton() {
        let newCategoryViewController = NewCategoryViewController()
        newCategoryViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: newCategoryViewController)
        present(navigationController, animated: true)
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath.flatMap { tableView.cellForRow(at: $0) }?.accessoryType = .none
        selectedIndexPath = indexPath
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        let selectedCategory = viewModel.getCategory(at: indexPath)
        delegate?.updateCategorySubtitle(with: selectedCategory.title, at: selectedIndexPath)
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        selectedIndexPath = indexPath
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(title: deleteText, image: nil) { _ in
                self.alertForDeletingCategory(at: indexPath)
            }
            deleteAction.attributes = [.destructive]
            return UIMenu(title: "", children: [UIAction(title: editText, image: nil) { _ in
                self.openEditCategory(category: self.viewModel.getCategory(at: indexPath))
            },
                                                deleteAction])
        }
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categoriesList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier, for: indexPath)
        guard let categoryCell = cell as? CategoryCell else { return UITableViewCell() }
        let category = viewModel.getCategory(at: indexPath)
        let title = category.title
        let isFirstRow = indexPath.row == 0
        let isLastRow = indexPath.row == viewModel.categoriesList.count - 1
        let isSelected = indexPath == selectedIndexPath
        categoryCell.configure(with: title,
                               isFirstRow: isFirstRow,
                               isLastRow: isLastRow,
                               isSelected: isSelected)
        return categoryCell
    }
}

extension CategoryViewController: NewCategoryViewControllerDelegate {
    func updateCategoriesList(with category: TrackerCategory) {
        viewModel.addCategory(category)
    }

    func editCategory(with newTitle: String) {
        if let indexPath = selectedIndexPath {
            viewModel.editCategory(at: indexPath, with: newTitle)
        }
    }
}
