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

    func editCategory(at indexPath: IndexPath, with newTitle: String) {
        let oldCategory = categoriesList[indexPath.row]
        do {
            try trackerCategoryStore.editTrackerCategory(oldCategory, with: newTitle)
        } catch {
            assertionFailure("Unable to edit category")
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

    func deleteCategory(at indexPath: IndexPath) {
        let category = categoriesList[indexPath.row]
        trackerCategoryStore.deleteTrackerCategory(category)
        getCategoriesList()
    }
}
