import Foundation
import CoreData

protocol StatisticsServiceDelegate: AnyObject {
    func statisticsDidUpdate()
}

final class StatisticsService {

    // MARK: - Properties
    static let shared = StatisticsService()

    private let context: NSManagedObjectContext
    weak var delegate: StatisticsServiceDelegate?

    // MARK: - Init
    private init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }

    // MARK: - Public Methods
    func getFinishedTrackersCount() -> Int {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()

        // Получаем все записи
        guard let records = try? context.fetch(fetchRequest) else {
            return 0
        }

        // Группируем по trackerId и считаем уникальные трекеры
        let uniqueTrackerIds = Set(records.compactMap { $0.trackerId })
        return uniqueTrackerIds.count
    }

    func notifyUpdate() {
        delegate?.statisticsDidUpdate()
    }
}
