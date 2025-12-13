import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidUpdate()
}

final class TrackerCategoryStore: NSObject {

    // MARK: - Properties
    private let context: NSManagedObjectContext
    weak var delegate: TrackerCategoryStoreDelegate?

    // MARK: - Fetched Results Controller
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]

        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        controller.delegate = self

        try? controller.performFetch()

        return controller
    }()

    // MARK: - Init
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
        super.init()
    }

    // MARK: - Public Methods
    var categories: [TrackerCategoryCoreData] {
        return fetchedResultsController.fetchedObjects ?? []
    }

    func addCategory(title: String) throws -> TrackerCategoryCoreData {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title

        try context.save()

        return category
    }

    func deleteCategory(_ category: TrackerCategoryCoreData) throws {
        context.delete(category)
        try context.save()
    }

    func updateCategory(_ category: TrackerCategoryCoreData, newTitle: String) throws {
        category.title = newTitle
        try context.save()
    }

    func fetchCategory(by title: String) -> TrackerCategoryCoreData? {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.fetchLimit = 1

        return try? context.fetch(fetchRequest).first
    }

    var numberOfCategories: Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    func category(at index: Int) -> TrackerCategoryCoreData? {
        guard let categories = fetchedResultsController.fetchedObjects,
              index < categories.count else {
            return nil
        }
        return categories[index]
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerCategoryStoreDidUpdate()
    }
}
