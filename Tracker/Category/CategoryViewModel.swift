import Foundation

final class CategoryViewModel {

    // MARK: - Bindings (Closures)
    var onCategoriesUpdated: (([String]) -> Void)?
    var onCategorySelected: ((String) -> Void)?
    var onError: ((String) -> Void)?

    // MARK: - Properties
    private let categoryStore: TrackerCategoryStore
    private(set) var categories: [String] = []
    private(set) var selectedCategory: String?

    // MARK: - Initializer
    init(categoryStore: TrackerCategoryStore = TrackerCategoryStore(), selectedCategory: String? = nil) {
        self.categoryStore = categoryStore
        self.selectedCategory = selectedCategory
        self.categoryStore.delegate = self
        loadCategories()
    }

    // MARK: - Public Methods
    func loadCategories() {
        let coreDataCategories = categoryStore.categories
        categories = coreDataCategories.compactMap { $0.title }
        onCategoriesUpdated?(categories)
    }

    func addCategory(title: String) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            onError?("Название категории не может быть пустым")
            return
        }

        do {
            _ = try categoryStore.addCategory(title: title)
            loadCategories()
        } catch {
            onError?("Ошибка при добавлении категории: \(error.localizedDescription)")
        }
    }

    func selectCategory(at index: Int) {
        guard index < categories.count else { return }
        selectedCategory = categories[index]
        onCategorySelected?(categories[index])
    }

    func updateCategory(at index: Int, newTitle: String) {
        guard index < categories.count,
              !newTitle.trimmingCharacters(in: .whitespaces).isEmpty else {
            onError?("Название категории не может быть пустым")
            return
        }

        guard let category = categoryStore.category(at: index) else { return }

        do {
            try categoryStore.updateCategory(category, newTitle: newTitle)
            loadCategories()
        } catch {
            onError?("Ошибка при обновлении категории: \(error.localizedDescription)")
        }
    }

    func deleteCategory(at index: Int) {
        guard let category = categoryStore.category(at: index) else { return }

        do {
            try categoryStore.deleteCategory(category)
            loadCategories()
        } catch {
            onError?("Ошибка при удалении категории: \(error.localizedDescription)")
        }
    }

    func numberOfCategories() -> Int {
        return categories.count
    }

    func category(at index: Int) -> String? {
        guard index < categories.count else { return nil }
        return categories[index]
    }

    func isSelected(at index: Int) -> Bool {
        guard index < categories.count else { return false }
        return categories[index] == selectedCategory
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidUpdate() {
        loadCategories()
    }
}
