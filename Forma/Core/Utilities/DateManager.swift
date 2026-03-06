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
    
    func convertToSeconds(_ dateString: String) -> CGFloat {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        /// - We use this method to get difference between 00:00 and date, to get a positive result
        let zeroDateString: String = "00:00"
        guard let zeroDate = dateFormatter.date(from: zeroDateString),
              let date = dateFormatter.date(from: dateString) else {
            print("No dates found")
            return 0
        }
        
        let dateInSeconds = date.timeIntervalSince(zeroDate)
        return dateInSeconds
    }
    
    func convertToDateString(_ dateInSeconds: CGFloat) -> String {
        let ti = Int(dateInSeconds)
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        return String(format: "%02d:%02d", hours, minutes)
    }
}
