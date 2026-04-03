import Foundation

final class DateManager {
    
    static let shared = DateManager()
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    private init() {}
    
    func getTodayTimeString() -> String {
        timeFormatter.string(from: Date())
    }
    
    func getTodayDateString(isWeekday: Bool = false) -> String {
        let format = isWeekday ? "EEEE" : "MMMM d"
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: Date())
    }
    
    func convertToSeconds(date: Date? = nil, string: String? = nil) -> CGFloat {
        var dateBuffer = "00:00"
        
        if let date {
            dateBuffer = timeFormatter.string(from: date)
        } else if let string {
            dateBuffer = string
        }
        
        guard let targetDate = timeFormatter.date(from: dateBuffer),
              let zeroDate = timeFormatter.date(from: "00:00") else {
            return 0
        }
        
        return targetDate.timeIntervalSince(zeroDate)
    }
    
    func formatMinutes(_ total: Int) -> String {
        DurationFormatter.format(total)
    }
    
    func convertToDateString(_ dateInSeconds: CGFloat) -> String {
        DurationFormatter.formatFromSeconds(dateInSeconds)
    }
    
    func dateToString(_ date: Date, format: String = "HH:mm") -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func stringToDate(_ string: String, dateFormat: String = "HH:mm") -> Date? {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = dateFormat
        return formatter.date(from: string)
    }
}
