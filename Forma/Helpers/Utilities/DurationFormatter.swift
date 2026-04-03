import Foundation

enum DurationFormatter {
    static func format(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        
        switch (h, m) {
        case (0, let m): return "\(m) min"
        case (let h, 0): return "\(h) hr"
        case (let h, let m): return "\(h) hr \(m) min"
        }
    }
    
    static func formatCompact(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        
        switch (h, m) {
        case (0, let m): return "\(m)m"
        case (let h, 0): return "\(h)h"
        case (let h, let m): return "\(h)h \(m)m"
        }
    }
    
    static func formatCompact(_ minutes: Double) -> String {
        let h = Int(minutes) / 60
        let m = Int(minutes) % 60
        
        if h == 0 { return "\(m)m" }
        if m == 0 { return "\(h)h" }
        return "\(h)h \(m)m"
    }
    
    static func formatCompactFromSeconds(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        
        if h > 0 && m > 0 { return "\(h)h \(m)m" }
        if h > 0 { return "\(h)h" }
        return "\(m)m"
    }
    
    static func formatFromSeconds(_ seconds: CGFloat) -> String {
        let ti = Int(seconds)
        let minutes = (ti / 60) % 60
        let hours = ti / 3600
        return String(format: "%02d:%02d", hours, minutes)
    }
}
