import UIKit

class TrackersViewController: UIViewController {

    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    
    
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
    
    private lazy var placeholderImage: UIView = {
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
        let leftButton = UIBarButtonItem(image: .plusTracker, style: .done, target: self, action: #selector(tapAddTrackerButton))
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
    
    private func showPlaceholder() {
        if visibleCategories.isEmpty {
            collectionView.isHidden = true
            placeholderStackView.isHidden = false
        } else {
            collectionView.isHidden = false
            placeholderStackView.isHidden = true
        }
    }
    
    @objc
    private func tapAddTrackerButton() {
        
    }
    
    @objc
    private func changeDatePicker() {
        
    }
    
    @objc
    private func editSearchTextField() {
        
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
        cell.setTracker(visibleCategories[indexPath.section].trackers[indexPath.row])
        let id = visibleCategories[indexPath.section].trackers[indexPath.row].id
        return cell
    }
}

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    
}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    
}
