import Foundation

enum ScheduleHelper {
    
    static let daySymbols = [
        NSLocalizedString("schedule.monday_short", comment: "Short Monday"),
        NSLocalizedString("schedule.tuesday_short", comment: "Short Tuesday"),
        NSLocalizedString("schedule.wednesday_short", comment: "Short Wednesday"),
        NSLocalizedString("schedule.thursday_short", comment: "Short Thursday"),
        NSLocalizedString("schedule.friday_short", comment: "Short Friday"),
        NSLocalizedString("schedule.saturday_short", comment: "Short Saturday"),
        NSLocalizedString("schedule.sunday_short", comment: "Short Sunday")
    ]
    
    static func scheduleWeekday(from index: Int) -> Int {
        return index
    }
    
    static func scheduleIndex(from weekday: Int) -> Int {
        return weekday
    }
    
    static func formattedSchedule(from schedules: [Schedule]) -> String {
        guard !schedules.isEmpty else { return "" }
        
        let weekdays = Set(schedules.map { $0.weekday })
        
        if weekdays.count == 7 {
            return NSLocalizedString("schedule.every_day_case", comment: "Every day case")
        }
        
        let sortedWeekdays = weekdays.sorted()
        let symbols = sortedWeekdays.map { ScheduleHelper.daySymbols[$0] }
        
        return symbols.joined(separator: ", ")
    }
    
    static func formattedSchedule(from indices: [Int]) -> String {
        guard !indices.isEmpty else { return "" }
        
        if indices.count == 7 {
            return NSLocalizedString("schedule.every_day_case", comment: "Every day case")
        }
        
        let sortedIndices = indices.sorted()
        let symbols = sortedIndices.map { ScheduleHelper.daySymbols[$0] }
        
        return symbols.joined(separator: ", ")
    }
}
