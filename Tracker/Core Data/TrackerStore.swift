import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidUpdate()
}

final class TrackerStore: NSObject {

    // MARK: - Properties
    private let context: NSManagedObjectContext
    weak var delegate: TrackerStoreDelegate?

    // MARK: - Fetched Results Controller
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()

        // Сортируем трекеры по названию
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

        // Выполняем первоначальную загрузку данных
        try? controller.performFetch()

        return controller
    }()

    // MARK: - Init
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
        super.init()
    }

    // MARK: - Public Methods

    /// Получить все трекеры
    var trackers: [TrackerCoreData] {
        return fetchedResultsController.fetchedObjects ?? []
    }

    /// Добавить новый трекер
    func addTracker(id: UUID, title: String, emoji: String, colorHex: String, schedule: String, category: TrackerCategoryCoreData) throws {
        let tracker = TrackerCoreData(context: context)
        tracker.id = id
        tracker.title = title
        tracker.emoji = emoji
        tracker.colorHex = colorHex
        tracker.scheduleData = schedule
        tracker.category = category

        try context.save()
    }

    /// Удалить трекер
    func deleteTracker(_ tracker: TrackerCoreData) throws {
        context.delete(tracker)
        try context.save()
    }

    /// Обновить трекер
    func updateTracker(_ tracker: TrackerCoreData) throws {
        try context.save()
    }

    /// Получить трекер по ID
    func fetchTracker(by id: UUID) -> TrackerCoreData? {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1

        return try? context.fetch(fetchRequest).first
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Уведомляем делегата об изменениях в данных
        delegate?.trackerStoreDidUpdate()
    }
}
