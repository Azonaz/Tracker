import UIKit

class TrackersViewController: UIViewController {
    var filterIndex: IndexPath?
    private let trackerStore: TrackerStoreProtocol = TrackerStore()
    private let trackerCategoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore()
    private let trackerRecordStore: TrackerRecordStoreProtocol = TrackerRecordStore()
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var currentDate: Date?
    private var dataSourсe: TrackerCollectionViewDataSourse?
    private var selectedIndexPath: IndexPath?

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.calendar.firstWeekday = 2
        datePicker.layer.cornerRadius = 8
        datePicker.clipsToBounds = true
        datePicker.addTarget(self, action: #selector(changeDatePicker), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()

    private lazy var addTrackerButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .ypBlack
        button.setImage(.plusTracker, for: .normal)
        button.addTarget(self, action: #selector(tapAddTrackerButton), for: .touchUpInside)
        return button
    }()

    private lazy var searchTextBar: TrackerSearchTextBar = {
        let searchText = TrackerSearchTextBar()
        searchText.delegate = self
        searchText.searchTextField.addTarget(self, action: #selector(tapSearchTextBar), for: .editingDidEndOnExit)
        return searchText
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = dataSourсe
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

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
        label.text = trackersPlaceholderText
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

    private lazy var filterButton: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 16
        button.backgroundColor = .ypBlue
        button.setTitle(filtersText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(tapFilterButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSourсe = TrackerCollectionViewDataSourse(viewController: self)
        createView()
        reloadData()
    }

    func getTrackersRecords(for tracker: Tracker) -> [TrackerRecord] {
        do {
            return try trackerRecordStore.fetchTrackerRecords(for: tracker)
        } catch {
            assertionFailure("Unaible to get trackers' records")
            return []
        }
    }

    func getVisibleCategories() -> [TrackerCategory] {
        visibleCategories
    }

    private func createView() {
        view.backgroundColor = .ypWhite
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        createNavigationBar()
        createSearchTextField()
        createTrackersCollectionView()
        createPlaceholderView()
        createFilterButton()
    }

    private func createNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.title = trackersTabTitile
        navigationController?.navigationBar.backgroundColor = .ypWhite
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func createSearchTextField() {
        view.addSubview(searchTextBar)
        NSLayoutConstraint.activate([
            searchTextBar.heightAnchor.constraint(equalToConstant: 36),
            searchTextBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchTextBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            searchTextBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ])
    }

    private func createTrackersCollectionView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchTextBar.bottomAnchor, constant: 34),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        collectionView.register(TrackerCollectionViewCell.self,
                                forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier)
        collectionView.register(SupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SupplementaryView.reuseIdentifier)
    }

    private func createPlaceholderView() {
        view.addSubview(placeholderStackView)
        NSLayoutConstraint.activate([
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func createFilterButton() {
        view.addSubview(filterButton)
        NSLayoutConstraint.activate([
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114)
        ])
    }

    private func updatePlaceholder() {
        if !categories.isEmpty && visibleCategories.isEmpty {
            placeholderImage.image = .notFounded
            placeholderText.text = notFoundedTrackersPlaceholderText
            placeholderStackView.isHidden = false
            filterButton.isHidden = true
            collectionView.isHidden = true
        } else if categories.isEmpty {
            placeholderStackView.isHidden = false
            filterButton.isHidden = true
        } else {
            placeholderStackView.isHidden = true
            collectionView.isHidden = false
            filterButton.isHidden = false
        }
        placeholderStackView.isHidden = !visibleCategories.isEmpty
    }

    private func reloadData() {
        do {
            categories = try trackerCategoryStore.getTrackerCategories()
        } catch {
            assertionFailure("Unable to get categories")
        }
        changeDatePicker()
    }

    private func applyFiltersToCategories() -> [TrackerCategory] {
        let selectedWeekday = Calendar.current.component(.weekday, from: datePicker.date)
        let searchText = searchTextBar.searchTextField.text?.lowercased() ?? ""
        return categories.compactMap { category in
            let filteredTrackers = filterTrackers(in: category, with: searchText, and: selectedWeekday)
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title,
                                                                    trackers: filteredTrackers)
        }
    }

    private func filterTrackers(in category: TrackerCategory, with searchText: String,
                                and selectedWeekday: Int) -> [Tracker] {
        return category.trackers.filter { tracker in
            let matchesSearchText = searchText.isEmpty || tracker.title.lowercased().contains(searchText)
            let matchesSelectedWeekday = tracker.schedule.contains { weekday in
                weekday.weekdayInNumber == selectedWeekday
            }
            return matchesSearchText && matchesSelectedWeekday
        }
    }

    private func reloadVisibleCategories() {
        visibleCategories = applyFiltersToCategories()
        updatePlaceholder()
        collectionView.reloadData()
    }

    private func alertForDeletingTracker(at indexPath: IndexPath) {
        let alert = UIAlertController(title: trackerDeleteAlertText, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: deleteText, style: .destructive) { _ in
            self.deleteTracker(at: indexPath)
        }
        let cancelAction = UIAlertAction(title: cancelButtonText, style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    private func deleteTracker(at indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        do {
            try trackerStore.deleteTracker(tracker)
        } catch {
            assertionFailure("Unable to delete tracker")
        }
        reloadVisibleCategories()
        updatePlaceholder()
    }

    private func openEditTracker() {
    }

    @objc
    private func tapAddTrackerButton() {
        let createTrackerViewController = TrackerTypeViewController()
        createTrackerViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: createTrackerViewController)
        present(navigationController, animated: true)
    }

    @objc
    private func changeDatePicker() {
        reloadVisibleCategories()
    }

    @objc
    private func tapSearchTextBar() {
        reloadVisibleCategories()
        searchTextBar.searchTextField.resignFirstResponder()
    }

    @objc
    private func handleTap() {
        view.endEditing(true)
    }

    @objc
    private func tapFilterButton() {
        let filtersViewController = FiltersViewController()
        filtersViewController.delegate = self
        filtersViewController.selectedFilterIndexPath = filterIndex
        let navigationController = UINavigationController(rootViewController: filtersViewController)
        present(navigationController, animated: true)
    }
}

extension TrackersViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        reloadVisibleCategories()
        searchBar.setShowsCancelButton(false, animated: true)
    }
}

extension TrackersViewController: TrackerCollectionViewCellDelegate {

    func getSelectedDate() -> Date {
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: datePicker.date)
        guard let currentDate = Calendar.current.date(from: dateComponents) else { return Date() }
        return currentDate
    }

    func updateTrackers() {
        reloadData()
        collectionView.reloadData()
    }

    func doneTracker(id: UUID, at indexPath: IndexPath) {
        let trackerRecord = TrackerRecord(id: id, date: getSelectedDate())
        try? trackerRecordStore.addTrackerRecord(for: trackerRecord.id, by: trackerRecord.date)
        collectionView.reloadItems(at: [indexPath])
    }

    func undoneTracker(id: UUID, at indexPath: IndexPath) {
        let trackerRecord = TrackerRecord(id: id, date: getSelectedDate())
        try? trackerRecordStore.deleteTrackerRecord(for: trackerRecord.id, by: trackerRecord.date)
        collectionView.reloadItems(at: [indexPath])
    }

    func isDoneTracker(id: UUID, tracker: Tracker) -> Bool {
        do {
            return try trackerRecordStore.fetchTrackerRecords(for: tracker).contains { trackerRecord in
                let date = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
                return trackerRecord.id == id && date
            }
        } catch {
            return false
        }
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - 37
        let cellWidth = availableWidth / CGFloat(2)
        let cellHeight: CGFloat = 148
        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 24)
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(title: deleteText, image: nil) { _ in
                self.alertForDeletingTracker(at: indexPath)
            }
            deleteAction.attributes = [.destructive]
            let editAction = UIAction(title: editText, image: nil) { _ in
                self.openEditTracker()
            }
            let pinAction = UIAction(title: pinAction, image: nil) { _ in
                self.openEditTracker()
            }
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        collectionView.performBatchUpdates {
            collectionView.insertSections(update.insertedSections)
            collectionView.insertItems(at: update.insertedIndexPaths)
        }
    }
}

extension TrackersViewController: FiltersViewControllerDelegate {
    func selectFilter(at indexPath: IndexPath) {
        filterIndex = indexPath
        let selectedFilter = indexPath.row
        switch selectedFilter {
        case 0:
            filterAllTrackers()
        case 1:
            filterTodayTrackers()
        case 2:
            filterDoneTrackers()
        case 3:
            filterUndoneTrackers()
        default:
            break
        }
    }

    private func filterAllTrackers() {
        reloadVisibleCategories()
    }

    private func filterTodayTrackers() {
        datePicker.date = Date()
        changeDatePicker()
    }

    private func filterDoneTrackers() {
        let selectedDate = datePicker.date
        let filteredCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let isDone = isDoneTracker(id: tracker.id, tracker: tracker)
                let dateMatches = Calendar.current.isDate(selectedDate, inSameDayAs: datePicker.date)
                return isDone && dateMatches
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        visibleCategories = filteredCategories
        updatePlaceholder()
        collectionView.reloadData()
    }

    private func filterUndoneTrackers() {
        let selectedDate = datePicker.date
        let filteredCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let isDone = isDoneTracker(id: tracker.id, tracker: tracker)
                let dateMatches = Calendar.current.isDate(selectedDate, inSameDayAs: datePicker.date)
                return !isDone && dateMatches
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        visibleCategories = filteredCategories
        updatePlaceholder()
        collectionView.reloadData()
    }
}
