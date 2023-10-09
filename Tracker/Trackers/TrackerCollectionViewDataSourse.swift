import UIKit

final class TrackerCollectionViewDataSourse: NSObject, UICollectionViewDataSource {
    private weak var viewController: TrackersViewController?

    init(viewController: TrackersViewController) {
        self.viewController = viewController
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let trackers = viewController?.getVisibleCategories()[section].trackers
        return trackers?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellData = viewController?.getVisibleCategories()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier,
                                                      for: indexPath)
        guard
            let tracker = cellData?[indexPath.section].trackers[indexPath.row],
            let trackerCell = cell as? TrackerCollectionViewCell,
            let isDoneToday = viewController?.isDoneTracker(id: tracker.id, tracker: tracker),
            let doneDays = viewController?.getTrackersRecords(for: tracker).filter({
                $0.id == tracker.id
            }).count
        else {
            return UICollectionViewCell()
        }
        trackerCell.delegate = viewController
        let isPinned = tracker.isPinned
        trackerCell.configure(with: tracker,
                              isDoneToday: isDoneToday,
                              isPinned: isPinned,
                              doneDays: doneDays,
                              at: indexPath)
        return trackerCell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewController?.getVisibleCategories().count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let headerData = viewController?.getVisibleCategories()
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:
                                                                    SupplementaryView.reuseIdentifier, for: indexPath)
        guard let headerView = view as? SupplementaryView, let categoryTitle = headerData?[indexPath.section].title
        else { return UICollectionReusableView() }
        headerView.configure(from: categoryTitle)
        return headerView
    }
}
