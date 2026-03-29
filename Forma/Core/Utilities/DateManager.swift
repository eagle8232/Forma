//
//  DateManager.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/25/26.
//

import Foundation

final class DateManager {
    
    static let shared = DateManager()
    
    private init () {}
    
    func getTodayTimeString() -> String {
        let todayDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let todayDateString = dateFormatter.string(from: todayDate)
        return todayDateString
    }
    
    func getTodayDateString(isWeekday: Bool = false) -> String {
        let todayDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = isWeekday ? "EEEE" : "MMMM d"
        
        let weekdayString = dateFormatter.string(from: todayDate)
        let monthDateString = dateFormatter.string(from: todayDate)
        
        return isWeekday ? weekdayString : monthDateString
        
    }
    
    func convertToSeconds(date: Date? = nil, string: String? = nil) -> CGFloat {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        var dateBuffer: String = "00:00" // - By default
        
        /// - We use this method to get difference between 00:00 and date, to get a positive result
        let zeroDateString: String = "00:00"
        guard let zeroDate = dateFormatter.date(from: zeroDateString) else { return 0 }
        
        if let date {
            dateBuffer = dateFormatter.string(from: date)
        } else if let string {
            dateBuffer = string
        }
        
        guard let date = dateFormatter.date(from: dateBuffer) else { return 0 }
        
        let dateInSeconds = date.timeIntervalSince(zeroDate)
        return dateInSeconds
    }
    
    func formatMinutes(_ total: Int) -> String {
        let h = total / 60, m = total % 60
        switch (h, m) {
        case (0, let m): return "\(m) min"
        case (let h, 0): return "\(h) hr"
        default:         return "\(h) hr \(m) min"
        }
    }
    
    func convertToDateString(_ dateInSeconds: CGFloat) -> String {
        let ti = Int(dateInSeconds)
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        return String(format: "%02d:%02d", hours, minutes)
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
