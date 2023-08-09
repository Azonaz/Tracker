import UIKit

class TrackersViewController: UIViewController {
    private let mockData = MockData.shared
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var doneTrackers: [TrackerRecord] = []
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

    private lazy var placeholderView: UIView = {
        PlaceholderView(
            image: UIImage.emptyTrackers,
            title: "Что будем отслеживать?"
        )
    }()

    private lazy var notFoundedPlaceholderView: UIView = {
        PlaceholderView(
            image: UIImage.notFounded,
            title: "Ничего не найдено"
        )
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSourсe = TrackerCollectionViewDataSourse(viewController: self)
        delegate = TrackerCollectionViewDelegate(viewController: self)
        createView()
        reloadData()
    }

    private func createView() {
        view.backgroundColor = .ypWhite
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        createNavigationBar()
        createSearchTextField()
        createTrackersCollectionView()
        createPlaceholderView(placeholderView)
    }

    private func reloadData() {
        categories = mockData.categories
        changeDatePicker()
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

    private func createPlaceholderView(_ placeholder: UIView) {
        view.addSubview(placeholder)
        NSLayoutConstraint.activate([
            placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func updatePlaceholder() {
        if !categories.isEmpty && visibleCategories.isEmpty {
            createPlaceholderView(notFoundedPlaceholderView)
            placeholderView.isHidden = true
            collectionView.isHidden = true
        } else if categories.isEmpty {
            placeholderView.isHidden = false
            notFoundedPlaceholderView.isHidden = true
        } else {
            placeholderView.isHidden = true
            collectionView.isHidden = false
        }
        notFoundedPlaceholderView.isHidden = !visibleCategories.isEmpty
    }

    private func filterCategories() -> [TrackerCategory] {
        currentDate = datePicker.date
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: currentDate ?? Date())
        let filterText = (searchTextBar.searchTextField.text ?? "").lowercased()
        return categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = filterText.isEmpty || tracker.title.lowercased().contains(filterText)
                let dateCondition = tracker.schedule?.contains { weekday in
                    weekday.weekdayNumber == filterWeekday
                } ?? false
                return textCondition && dateCondition
            }
            if trackers.isEmpty {
                return nil
            }
            return TrackerCategory(title: category.title, trackers: trackers)
        }
    }

    private func reloadVisibleCategories() {
        visibleCategories = filterCategories()
        updatePlaceholder()
        collectionView.reloadData()
    }

    func getVisibleCategories() -> [TrackerCategory] {
        visibleCategories
    }

    func getDoneTrackers() -> [TrackerRecord] {
        doneTrackers
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

extension TrackersViewController: UICollectionViewDelegate {

}

extension TrackersViewController: TrackerCollectionViewCellDelegate {

    func getSelectedDate() -> Date? {
        currentDate = datePicker.date
        return currentDate
    }

    func updateTrackers() {
        reloadData()
        collectionView.reloadData()
    }

    func doneTracker(id: UUID, at indexPath: IndexPath) {
        currentDate = datePicker.date
        let trackerRecord = TrackerRecord(id: id, date: currentDate ?? Date())
        doneTrackers.append(trackerRecord)
        collectionView.reloadItems(at: [indexPath])
    }

    func undoneTracker(id: UUID, at indexPath: IndexPath) {
        doneTrackers.removeAll { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
        collectionView.reloadItems(at: [indexPath])
    }

    func isTrackerDoneToday(id: UUID) -> Bool {
        doneTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }

    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        currentDate = datePicker.date
        let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: currentDate ?? Date())
        return trackerRecord.id == id && isSameDay
    }
}
