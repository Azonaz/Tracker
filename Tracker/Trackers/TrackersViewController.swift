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
    private let analyticsService = AnalyticsService()

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
        collectionView.register(TrackerCollectionViewCell.self,
                                forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier)
        collectionView.register(SupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SupplementaryView.reuseIdentifier)
        collectionView.dataSource = dataSourсe
        collectionView.delegate = self
        return collectionView
    }()

    private lazy var placeholderImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    private lazy var placeholderText: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
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
        return button
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(event: .open, parameters: ["screen": "Main"])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSourсe = TrackerCollectionViewDataSourse(viewController: self)
        createView()
        reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: .close, parameters: ["screen": "Main"])
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.title = trackersTabTitile
        navigationController?.navigationBar.backgroundColor = .ypWhite
        navigationController?.navigationBar.prefersLargeTitles = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        [searchTextBar, collectionView, placeholderStackView, filterButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        activateConstraints()
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            searchTextBar.heightAnchor.constraint(equalToConstant: 36),
            searchTextBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchTextBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            searchTextBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            collectionView.topAnchor.constraint(equalTo: searchTextBar.bottomAnchor, constant: 34),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114)
        ])
    }

    private func updatePlaceholder() {
        if visibleCategories.isEmpty && searchTextBar.searchTextField.text?.isEmpty == false {
            showNotFoundedTrackersPlaceholder()
        } else if visibleCategories.isEmpty {
            showEmptyTrackersPlaceholder()
        } else {
            hidePlaceholder()
        }
    }

    private func showEmptyTrackersPlaceholder() {
        placeholderStackView.isHidden = false
        placeholderImage.image = .emptyTrackers
        placeholderText.text = trackersPlaceholderText
        filterButton.isHidden = true
        collectionView.isHidden = true
    }

    private func showNotFoundedTrackersPlaceholder() {
        placeholderStackView.isHidden = false
        placeholderImage.image = .notFounded
        placeholderText.text = notFoundedTrackersPlaceholderText
        filterButton.isHidden = true
        collectionView.isHidden = true
    }

    private func hidePlaceholder() {
        placeholderStackView.isHidden = true
        filterButton.isHidden = false
        collectionView.isHidden = false
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
        let pinnedTrackers = categories.flatMap { category in
            filterTrackers(in: category, with: searchText, and: selectedWeekday)
                .filter { tracker in
                    return tracker.isPinned
                }
        }
        var resultCategories: [TrackerCategory] = []
        for category in categories {
            let filteredTrackers = filterTrackers(in: category, with: searchText, and: selectedWeekday)
                .filter { tracker in
                    return !tracker.isPinned
                }
            if !filteredTrackers.isEmpty {
                let filteredCategory = TrackerCategory(title: category.title, trackers: filteredTrackers)
                resultCategories.append(filteredCategory)
            }
        }
        if !pinnedTrackers.isEmpty {
            let pinnedCategory = TrackerCategory(title: pinnedCategoryText, trackers: pinnedTrackers)
            resultCategories.insert(pinnedCategory, at: 0)
        }
        return resultCategories
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
        reloadData()
        updatePlaceholder()
    }

    private func openEditTracker(tracker: Tracker) {
        let editTrackerViewController = CreateNewTrackerViewController(isHabit: true)
        editTrackerViewController.delegate = self
        editTrackerViewController.trackerToEdit = tracker
        editTrackerViewController.categoryEditTracker = trackerStore.fetchCategoryForTracker(with: tracker.id)
        let selectTrackerRecords = getTrackersRecords(for: tracker).filter({ $0.id == tracker.id }).count
        let selectTrackerRecordsText = String.localizedStringWithFormat(NSLocalizedString("daysAmount", comment: ""),
                                                                        selectTrackerRecords)
        editTrackerViewController.recordsLabel = selectTrackerRecordsText
        let navigationController = UINavigationController(rootViewController: editTrackerViewController)
        present(navigationController, animated: true)
    }

    @objc
    private func tapAddTrackerButton() {
        analyticsService.report(event: .click, parameters: ["screen": "Main", "item": Item.add_track.rawValue])
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
        analyticsService.report(event: .click, parameters: ["screen": "Main", "item": Item.filter.rawValue])
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

    func pinTracker(id: UUID) {
        if let trackerToPin = categories.flatMap({ $0.trackers }).first(where: { $0.id == id }) {
            do {
                try trackerStore.pinTracker(trackerToPin)
            } catch {
                assertionFailure("Unable to pin tracker")
            }
            reloadData()
        }
    }

    func unpinTracker(id: UUID) {
        if let trackerToUnpin = categories.flatMap({ $0.trackers }).first(where: { $0.id == id }) {
            do {
                try trackerStore.unpinTracker(trackerToUnpin)
            } catch {
                assertionFailure("Unable to unpin tracker")
            }
            reloadData()
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
                self.analyticsService.report(event: .click,
                                             parameters: ["screen": "Main", "item": Item.delete.rawValue])
                self.alertForDeletingTracker(at: indexPath)
            }
            deleteAction.attributes = [.destructive]
            let editAction = UIAction(title: editText, image: nil) { _ in
                self.analyticsService.report(event: .click, parameters: ["screen": "Main", "item": Item.edit.rawValue])
                self.openEditTracker(tracker: self.visibleCategories[indexPath.section].trackers[indexPath.row])
            }
            let pinActionTitle = self.visibleCategories[indexPath.section].trackers[indexPath.row].isPinned
            ? unpinAction : pinAction
            let pinAction = UIAction(title: pinActionTitle, image: nil) { _ in
                if self.visibleCategories[indexPath.section].trackers[indexPath.row].isPinned {
                    self.unpinTracker(id: self.visibleCategories[indexPath.section].trackers[indexPath.row].id)
                } else {
                    self.pinTracker(id: self.visibleCategories[indexPath.section].trackers[indexPath.row].id)
                }
            }
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func didUpdate() {
        reloadData()
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
        if filteredCategories.isEmpty {
            showNotFoundedTrackersPlaceholder()
            filterButton.isHidden = false
        } else {
            visibleCategories = filteredCategories
            updatePlaceholder()
            collectionView.reloadData()
        }
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
        if filteredCategories.isEmpty {
            showNotFoundedTrackersPlaceholder()
            filterButton.isHidden = false
        } else {
            visibleCategories = filteredCategories
            updatePlaceholder()
            collectionView.reloadData()
        }
    }
}
