import Foundation

enum ScheduleHelper {
    // ScheduleViewController использует индексы 0-6 (0 = Понедельник, 6 = Воскресенье)
    // Schedule.weekday использует ту же систему 0-6 (0 = Понедельник, 6 = Воскресенье)
    // Это видно из TrackersViewController.getWeekday, где weekday из Date конвертируется в 0-6
    
    static let daySymbols = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    // Конвертация из ScheduleViewController индексов (0-6) в Schedule.weekday (0-6)
    // Они используют одну и ту же систему, так что просто возвращаем индекс
    static func scheduleWeekday(from index: Int) -> Int {
        return index
    }
    
    // Конвертация из Schedule.weekday (0-6) в ScheduleViewController индексы (0-6)
    // Они используют одну и ту же систему, так что просто возвращаем weekday
    static func scheduleIndex(from weekday: Int) -> Int {
        return weekday
    }
    
    // Форматирование расписания для отображения
    static func formattedSchedule(from schedules: [Schedule]) -> String {
        guard !schedules.isEmpty else { return "" }
        
        let weekdays = Set(schedules.map { $0.weekday })
        
        if weekdays.count == 7 {
            return "Каждый день"
        }
        
        // Порядок дней: Пн, Вт, Ср, Чт, Пт, Сб, Вс (индексы 0-6)
        let sortedWeekdays = weekdays.sorted()
        let symbols = sortedWeekdays.map { ScheduleHelper.daySymbols[$0] }
        
        return symbols.joined(separator: ", ")
    }
    
    // Форматирование расписания из ScheduleViewController индексов
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

