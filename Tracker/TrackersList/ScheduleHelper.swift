import Foundation

enum ScheduleHelper {
    
    static let daySymbols = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
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
            return "Каждый день"
        }
        
        let sortedWeekdays = weekdays.sorted()
        let symbols = sortedWeekdays.map { ScheduleHelper.daySymbols[$0] }
        
        return symbols.joined(separator: ", ")
    }
    
    static func formattedSchedule(from indices: [Int]) -> String {
        guard !indices.isEmpty else { return "" }
        
        if indices.count == 7 {
            return "Каждый день"
        }
        
        let sortedIndices = indices.sorted()
        let symbols = sortedIndices.map { ScheduleHelper.daySymbols[$0] }
        
        return symbols.joined(separator: ", ")
    }
}

