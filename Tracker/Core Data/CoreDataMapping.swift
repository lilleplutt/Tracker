import UIKit
import CoreData

// MARK: - TrackerCoreData Mapping
extension TrackerCoreData {
    /// Конвертация Core Data модели в UI модель
    func toTracker() -> Tracker? {
        guard let id = id,
              let title = title,
              let emoji = emoji,
              let colorHex = colorHex,
              let scheduleData = scheduleData else {
            return nil
        }

        let color = UIColor(hex: colorHex) ?? .ypRedIOS
        let schedule = scheduleData.split(separator: ",").compactMap { Int($0) }.map { Schedule(weekday: $0) }

        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
}

// MARK: - TrackerCategoryCoreData Mapping
extension TrackerCategoryCoreData {
    /// Конвертация Core Data модели в UI модель
    func toTrackerCategory() -> TrackerCategory? {
        guard let title = title else { return nil }

        let trackersArray = (trackers as? Set<TrackerCoreData>) ?? []
        let convertedTrackers = trackersArray.compactMap { $0.toTracker() }

        return TrackerCategory(
            title: title,
            trackers: convertedTrackers
        )
    }
}

// MARK: - TrackerRecordCoreData Mapping
extension TrackerRecordCoreData {
    /// Конвертация Core Data модели в UI модель
    func toTrackerRecord() -> TrackerRecord? {
        guard let trackerId = trackerId,
              let date = date else {
            return nil
        }

        return TrackerRecord(trackerId: trackerId, date: date)
    }
}

// MARK: - UIColor Hex Extension
extension UIColor {
    /// Инициализация UIColor из hex строки
    convenience init?(hex: String) {
        let r, g, b: CGFloat

        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if hexSanitized.count == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

            self.init(red: r, green: g, blue: b, alpha: 1.0)
        } else {
            return nil
        }
    }

    /// Конвертация UIColor в hex строку
    func toHex() -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])

        return String(format: "#%02lX%02lX%02lX",
                      lroundf(r * 255),
                      lroundf(g * 255),
                      lroundf(b * 255))
    }
}

// MARK: - Schedule Extension
extension Array where Element == Schedule {
    /// Конвертация массива Schedule в строку для хранения
    func toString() -> String {
        return self.map { String($0.weekday) }.joined(separator: ",")
    }
}
