import UIKit

class TrackersViewController: UIViewController {

    static var selectDay: Date?
    
    enum PlacelolderType {
        case noTrackers
        case notFoundTrackers
    }
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var visibleCategoriesForSearch: [TrackerCategory] = []
    private var doneTrackers: Set<TrackerRecord> = []
    private var currentDay: Date = Date()

    private lazy var datePicker: UIDatePicker = {
       let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ru_RU")
        datePicker.calendar = calendar
        datePicker.layer.cornerRadius = 8
        datePicker.clipsToBounds = true
        datePicker.addTarget(self, action: #selector(changeDatePicker), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()

    private lazy var searchTextController: UISearchController = {
       let searchText = UISearchController(searchResultsController: nil)
        searchText.searchResultsUpdater = self
        searchText.obscuresBackgroundDuringPresentation = false
        searchText.searchBar.placeholder = "Поиск"
        searchText.hidesNavigationBarDuringPresentation = false
        return searchText
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .ypWhite
        collectionView.register(TrackerCollectionViewCell.self,
                                forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier)
        collectionView.register(SupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SupplementaryView.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var placeholderImage: UIImageView = {
        let placeholderImage = UIImageView()
        placeholderImage.image = .emptyTrackers
        return placeholderImage
    }()

    private lazy var placeholderText: UILabel = {
        let placeholderText = UILabel()
        placeholderText.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        placeholderText.textColor = .ypBlack
        placeholderText.text = "Что будем отслеживать?"
        return placeholderText
    }()

    private lazy var placeholderStackView: UIStackView = {
       let placeholderStack = UIStackView()
        placeholderStack.axis = .vertical
        placeholderStack.spacing = 10
        placeholderStack.alignment = .center
        placeholderStack.distribution = .equalSpacing
        placeholderStack.addArrangedSubview(placeholderImage)
        placeholderStack.addArrangedSubview(placeholderText)
        placeholderStack.translatesAutoresizingMaskIntoConstraints = false
        return placeholderStack
    }()
    
    private let dateFormmater: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
    }

    private func createView() {
        view.backgroundColor = .ypWhite
        view.addSubview(collectionView)
        view.addSubview(placeholderStackView)
        activateConstraints()
        createNavigationBar()
       
    }

    private func createNavigationBar() {
        let leftButton = UIBarButtonItem(image: .plusTracker, style: .done,
                                         target: self, action: #selector(tapAddTrackerButton))
        let rightButton = UIBarButtonItem(customView: datePicker)
        leftButton.tintColor = .ypBlack
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.title = "Трекеры"
        navigationItem.searchController = searchTextController
        navigationController?.navigationBar.backgroundColor = .ypWhite
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    private func showPlaceholder(for type: PlacelolderType) {
        if visibleCategories.isEmpty {
            collectionView.isHidden = true
            placeholderStackView.isHidden = false
            switch type {
            case .noTrackers:
                placeholderImage.image = .emptyTrackers
                placeholderText.text = "Что будем отслеживать?"
            case .notFoundTrackers:
                placeholderImage.image = .notFounded
                placeholderText.text = "Ничего не найдено"
            }
        } else {
                    collectionView.isHidden = false
            placeholderStackView.isHidden = true
        }
    }
    
    private func configViewModel(for indexPath: IndexPath) -> TrackerCellView {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let counter = doneTrackers.filter({ $0.id == tracker.id }).count
        let trackerIsChecked = doneTrackers.contains(TrackerRecord(id: tracker.id, date: dateFormmater.string(from: currentDay)))
        _ = Calendar.current.compare(currentDay, to: Date(), toGranularity: .day)
        let checkButtonEnable = true
        return TrackerCellView(dayCounter: counter, buttonIsChecked: trackerIsChecked, buttonIsEnable: checkButtonEnable, tracker: tracker, indexPath: indexPath)
    }
    
    @objc
    private func tapAddTrackerButton() {
        let newHabitVC = NewHabitViewController()
        newHabitVC.delegate = self
        let newEventVC = NewEventViewController()
        newEventVC.delegate = self
        let trackerTypeVC = TrackerTypeViewController(newHabitVC: newHabitVC, newEventVC: newEventVC)
        let monavigationController = UINavigationController(rootViewController: trackerTypeVC)
        navigationController?.present(monavigationController, animated: true)
    }
    
    @objc
    private func changeDatePicker(_ sender: UIDatePicker) {
        TrackersViewController.selectDay = sender.date
        reloadVisibleCategories()
    }
    
    private func reloadVisibleCategories() {
        currentDay = datePicker.date
        let calendar = Calendar.current
        let filterDayOfWeek = calendar.component(.weekday, from: currentDay) - 1
        let filterText = (searchTextController.searchBar.text ?? "").lowercased()
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = filterText.isEmpty ||
                tracker.title.lowercased().contains(filterText)
                let dateCondition = tracker.schedule.contains(where: {$0 == filterDayOfWeek})
                return textCondition && dateCondition
            }
            if trackers.isEmpty {
                return nil
            }
            return TrackerCategory(title: category.title, trackers: trackers)
        }
        collectionView.reloadData()
        showPlaceholder(for: .noTrackers)
    }
    
    @objc
    private func editSearchTextField() {
        currentDay = datePicker.date
        let calendar = Calendar.current
        let filterDayOfWeek = calendar.component(.weekday, from: currentDay) - 1
        let filterText = (searchTextController.searchBar.text ?? "").lowercased()
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = filterText.isEmpty ||
                tracker.title.lowercased().contains(filterText)
                let dateCondition = tracker.schedule.contains(where: {$0 == filterDayOfWeek})
                return textCondition && dateCondition
            }
            if trackers.isEmpty {
                return nil
            }
            return TrackerCategory(title: category.title, trackers: trackers)
        }
        collectionView.reloadData()
        showPlaceholder(for: .noTrackers)
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 9 - 16 - 16), height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//
//        let indexPath = IndexPath(row: 0, section: section)
//        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
//
//        var height = CGFloat()
//        if section == 0 {
//            height = 42
//        } else {
//            height = 34
//        }
        
//        return headerView.systemLayoutSizeFitting(
//            CGSize(width: collectionView.frame.width,
//                   height: height),
//            withHorizontalFittingPriority: .required,
//            verticalFittingPriority: .fittingSizeLevel
//        )
//    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier,
                                                            for: indexPath) as? TrackerCollectionViewCell else { return UICollectionViewCell() }
        cell.delegate = self
       let viewModel = configViewModel(for: indexPath)
        cell.configCell(viewModel:viewModel)
        return cell
    }
}

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func dayCheckButtonTapped(viewModel: TrackerCellView) {
        if viewModel.buttonIsChecked {
            doneTrackers.insert(TrackerRecord(id: viewModel.tracker.id, date: dateFormmater.string(from: currentDay)))
        } else {
            doneTrackers.remove(TrackerRecord(id: viewModel.tracker.id, date: dateFormmater.string(from: currentDay)))
        }
        collectionView.reloadItems(at: [viewModel.indexPath])
    }
    
    
}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearch(searchController.searchBar.text!)
    }
    
    func filterContentForSearch(_ searchText: String) {
        var searchCategories: [TrackerCategory] = []
        var trackers: [Tracker] = []
        for category in visibleCategoriesForSearch {
            for tracker in category.trackers {
                if tracker.title.lowercased().contains(searchText.lowercased()) || searchText == "" {
                    trackers.append(tracker)
                }
                if !trackers.isEmpty {
                    let newCategory = TrackerCategory(title: category.title, trackers: trackers)
                    searchCategories.append(newCategory)
                }
                trackers = []
            }
            visibleCategories = searchCategories
          
            if visibleCategories.isEmpty && !visibleCategoriesForSearch.isEmpty {
                showPlaceholder(for: .notFoundTrackers)
            }
            collectionView.reloadData()
        }
    }
    
}

extension TrackersViewController: NewHabitViewControllerDelegate, NewEventViewControllerDelegate {
    func addNewHabit(_ trackerCategory: TrackerCategory) {
        var newCategory: [TrackerCategory] = []
        if let categoryIndex = categories.firstIndex(where: { $0.title == trackerCategory.title}) {
            for (index, category) in categories.enumerated() {
                var trackers = category.trackers
                if index == categoryIndex {
                    trackers.append(contentsOf: trackerCategory.trackers)
                }
                newCategory.append(TrackerCategory(title: category.title, trackers: trackers))
            }
        } else {
            newCategory = categories
            newCategory.append(trackerCategory)
        }
        categories = newCategory
        
        collectionView.reloadData()
    }
    
    func addNewEvent(_ trackerCategory: TrackerCategory) {
        
    }
    
}
