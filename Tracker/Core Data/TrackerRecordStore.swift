import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStoreDidUpdate()
}

final class TrackerRecordStore: NSObject {

    // MARK: - Properties
    private let context: NSManagedObjectContext
    weak var delegate: TrackerRecordStoreDelegate?

    // MARK: - Fetched Results Controller
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()

        // Сортируем записи по дате (новые сверху)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false)
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

    /// Получить все записи
    var records: [TrackerRecordCoreData] {
        return fetchedResultsController.fetchedObjects ?? []
    }

    /// Добавить новую запись о выполнении трекера
    func addRecord(trackerId: UUID, date: Date) throws {
        let record = TrackerRecordCoreData(context: context)
        record.trackerId = trackerId
        record.date = date

        try context.save()
    }

    /// Удалить запись
    func deleteRecord(_ record: TrackerRecordCoreData) throws {
        context.delete(record)
        try context.save()
    }

    /// Удалить запись по trackerId и дате
    func deleteRecord(trackerId: UUID, date: Date) throws {
        if let record = fetchRecord(trackerId: trackerId, date: date) {
            context.delete(record)
            try context.save()
        }
    }

    /// Получить запись по trackerId и дате
    func fetchRecord(trackerId: UUID, date: Date) -> TrackerRecordCoreData? {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()

        // Создаем предикат для поиска по trackerId и дате
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date

        fetchRequest.predicate = NSPredicate(
            format: "trackerId == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        fetchRequest.fetchLimit = 1

        return try? context.fetch(fetchRequest).first
    }

    /// Получить все записи для конкретного трекера
    func fetchRecords(for trackerId: UUID) -> [TrackerRecordCoreData] {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        return (try? context.fetch(fetchRequest)) ?? []
    }

    /// Получить количество выполнений для конкретного трекера
    func completedCount(for trackerId: UUID) -> Int {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)

        return (try? context.count(for: fetchRequest)) ?? 0
    }

    /// Проверить, выполнен ли трекер в конкретную дату
    func isTrackerCompleted(trackerId: UUID, date: Date) -> Bool {
        return fetchRecord(trackerId: trackerId, date: date) != nil
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Уведомляем делегата об изменениях в данных
        delegate?.trackerRecordStoreDidUpdate()
    }
}
