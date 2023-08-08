import UIKit

class TrackersViewController: UIViewController {
    private let mockData = MockData.shared
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var doneTrackers: [TrackerRecord] = []
    private var currentDay: Date?
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

    private lazy var searchTextBar: TrackerSearchBar = {
        let searchText = TrackerSearchBar()
        searchText.delegate = self
        searchText.searchTextField.addTarget(self, action: #selector(tapSearchTextBar), for: .editingDidEndOnExit)
        return searchText
    }()

    private lazy var tapGesture: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        recognizer.cancelsTouchesInView = false
        return recognizer
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
        createNavigationBar()
        createSearchTrackersTextField()
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

    private func createSearchTrackersTextField() {
        view.addSubview(searchTextBar)
        view.addGestureRecognizer(tapGesture)
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

    func createPlaceholderView(_ placeholder: UIView) {
        view.addSubview(placeholder)
        NSLayoutConstraint.activate([
            placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func updatePlaceholderViews() {
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
        currentDay = datePicker.date
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: currentDay ?? Date())
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
        updatePlaceholderViews()
        collectionView.reloadData()
    }

    func getVisibleCategories() -> [TrackerCategory] {
        visibleCategories
    }

    func getCompletedTrackers() -> [TrackerRecord] {
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
    private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc
    private func tapSearchTextBar() {
        reloadVisibleCategories()
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

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        reloadVisibleCategories()
        searchBar.resignFirstResponder()
    }
}

extension TrackersViewController: UICollectionViewDelegate {

}

extension TrackersViewController: TrackerCollectionViewCellDelegate {

    func getSelectedDate() -> Date? {
        currentDay = datePicker.date
        return currentDay
    }

    func updateTrackers() {
        reloadData()
        collectionView.reloadData()
    }

    func completeTracker(id: UUID, at indexPath: IndexPath) {
        currentDay = datePicker.date
        let trackerRecord = TrackerRecord(id: id, date: currentDay ?? Date())
        doneTrackers.append(trackerRecord)
        collectionView.reloadItems(at: [indexPath])
    }

    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        doneTrackers.removeAll { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
        collectionView.reloadItems(at: [indexPath])
    }

    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        currentDay = datePicker.date
        let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: currentDay ?? Date())
        return trackerRecord.id == id && isSameDay
    }

    func isTrackerCompletedToday(id: UUID) -> Bool {
        doneTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }
}
