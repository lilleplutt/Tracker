import Foundation

protocol StatisticsServiceDelegate: AnyObject {
    func statisticsDidUpdate()
}

final class StatisticsService {

    // MARK: - Properties
    static let shared = StatisticsService()

    private let recordStore: TrackerRecordStore
    weak var delegate: StatisticsServiceDelegate?

    // MARK: - Init
    init(recordStore: TrackerRecordStore = TrackerRecordStore()) {
        self.recordStore = recordStore
    }

    // MARK: - Public Methods
    func getFinishedTrackersCount() -> Int {
        return recordStore.getFinishedTrackersCount()
    }

    func notifyUpdate() {
        delegate?.statisticsDidUpdate()
    }
}
