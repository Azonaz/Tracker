import UIKit

class TrackersViewController: UIViewController {
    private let trackerStore: TrackerStoreProtocol = TrackerStore()
    private let trackerCategoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore()
    private let trackerRecordStore: TrackerRecordStoreProtocol = TrackerRecordStore()
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var currentDate: Date?
    private var delegate: TrackerCollectionViewDelegate?
    private var dataSourсe: TrackerCollectionViewDataSourse?

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
        collectionView.delegate = delegate
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
        label.text = "Что будем отслеживать?"
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

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSourсe = TrackerCollectionViewDataSourse(viewController: self)
        delegate = TrackerCollectionViewDelegate(viewController: self)
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
    }

    private func createNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.title = "Трекеры"
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

    private func updatePlaceholder() {
        if !categories.isEmpty && visibleCategories.isEmpty {
            placeholderImage.image = .notFounded
            placeholderText.text = "Ничего не найдено"
            placeholderStackView.isHidden = false
            collectionView.isHidden = true
        } else if categories.isEmpty {
            placeholderStackView.isHidden = false
        } else {
            placeholderStackView.isHidden = true
            collectionView.isHidden = false
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

extension TrackersViewController: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        collectionView.performBatchUpdates {
            collectionView.insertSections(update.insertedSections)
            collectionView.insertItems(at: update.insertedIndexPaths)
        }
    }
}
