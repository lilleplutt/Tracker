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

        try? controller.performFetch()

        return controller
    }()

    // MARK: - Init
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
        super.init()
    }

    // MARK: - Public Methods
    var records: [TrackerRecordCoreData] {
        return fetchedResultsController.fetchedObjects ?? []
    }

    func addRecord(trackerId: UUID, date: Date) throws {
        let record = TrackerRecordCoreData(context: context)
        record.trackerId = trackerId
        record.date = date

        try context.save()
        StatisticsService.shared.notifyUpdate()
    }

    func deleteRecord(_ record: TrackerRecordCoreData) throws {
        context.delete(record)
        try context.save()
        StatisticsService.shared.notifyUpdate()
    }

    func deleteRecord(trackerId: UUID, date: Date) throws {
        if let record = fetchRecord(trackerId: trackerId, date: date) {
            context.delete(record)
            try context.save()
            StatisticsService.shared.notifyUpdate()
        }
    }

    func fetchRecord(trackerId: UUID, date: Date) -> TrackerRecordCoreData? {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()

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

    func fetchRecords(for trackerId: UUID) -> [TrackerRecordCoreData] {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        return (try? context.fetch(fetchRequest)) ?? []
    }

    func completedCount(for trackerId: UUID) -> Int {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)

        return (try? context.count(for: fetchRequest)) ?? 0
    }

    func isTrackerCompleted(trackerId: UUID, date: Date) -> Bool {
        return fetchRecord(trackerId: trackerId, date: date) != nil
    }

    func getFinishedTrackersCount() -> Int {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()

        guard let records = try? context.fetch(fetchRequest) else {
            return 0
        }

        let uniqueTrackerIds = Set(records.compactMap { $0.trackerId })
        return uniqueTrackerIds.count
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerRecordStoreDidUpdate()
    }
}

// MARK: - TrackerRecordCoreData Mapping
extension TrackerRecordCoreData {
    func toTrackerRecord() -> TrackerRecord? {
        guard let trackerId = trackerId,
              let date = date else {
            return nil
        }

        return TrackerRecord(trackerId: trackerId, date: date)
    }
}
