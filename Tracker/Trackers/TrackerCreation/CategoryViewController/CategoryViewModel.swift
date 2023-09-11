import Foundation

class CategoryViewModel {
    var categoriesDidChange: (([TrackerCategory]) -> Void)?

    private var categoriesList: [TrackerCategory] = [] {
        didSet {
            categoriesDidChange?(categoriesList)
        }
    }

    private let trackerCategoryStore: TrackerCategoryStore

    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
    }

    func addCategory(_ category: TrackerCategory) {
        do {
            try trackerCategoryStore.addTrackerCategory(category)
        } catch {
            assertionFailure("Unable to add category")
        }
        getCategoriesList()
    }

    func getCategoriesList() {
        do {
            categoriesList = try trackerCategoryStore.getTrackerCategories()
        } catch {
            assertionFailure("Unable to get categories' list")
        }
    }

    func getCategory(at indexPath: IndexPath) -> TrackerCategory {
        return categoriesList[indexPath.row]
    }

    func numberOfCategories() -> Int {
        return categoriesList.count
    }

    func didUpdateCategories(_ update: TrackerCategoryStoreUpdate) {
            getCategoriesList()
            categoriesDidChange?(categoriesList)
        }
}
