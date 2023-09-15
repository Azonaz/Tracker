import Foundation

class CategoryViewModel {
    var categoriesDidChange: (([TrackerCategory]) -> Void)?

    private(set) var categoriesList: [TrackerCategory] = [] {
        didSet {
            categoriesDidChange?(categoriesList)
        }
    }

    private let trackerCategoryStore: TrackerCategoryStore = TrackerCategoryStore()

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

    func didUpdateCategories(_ update: TrackerCategoryStoreUpdate) {
        categoriesDidChange?(categoriesList)
    }
}
