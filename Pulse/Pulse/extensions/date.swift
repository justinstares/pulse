//
//  date.swift
//  Pulse
//
//  Created by Reilly Freret on 11/13/18.
//  Copyright © 2018 Reilly Freret. All rights reserved.
//

import Foundation

extension Date {
    
    
    /**
     For past dates, generates a string describing the elapsed time
     
     - Parameters: past date:Date from which time is mesured
     - Returns: String
    */
    func englishDateDiffToDate(date: Date) -> String {
        let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .month, .year])
        let dateString = Calendar.current.dateComponents(components, from: self)
        let diffs = Calendar.current.dateComponents(components, from: self, to: date)
        var message = "Unsure"
        guard let years = diffs.year, let months = diffs.month, let days = diffs.day, let hours = diffs.hour, let minutes = diffs.minute, let _ = diffs.second else { return message }
        guard let _ = dateString.hour, let _ = dateString.minute else { return message }
        if years > 0 {
            message = "Over a year ago"
        } else if months > 0 {
            message = "Over a month ago"
        } else if days > 7 {
            let weeks = days / 7
            message = weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
        } else if days > 1 {
            message = "\(self.englishWeekday()) at \(self.hoursMinutes12h())"
        } else if days > 1 {
            message = "Yesterday at \(self.hoursMinutes12h())"
        } else if days == 0 {
            if hours > 3 {
                message = "Today at \(self.hoursMinutes12h())"
            } else if hours > 0 {
                message = hours == 1 ? "1 hour ago" : "\(hours) hours ago"
            } else {
                if minutes < 1 {
                    message = "Just now"
                } else { message = minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago" }
            }
        }

        return message
    }
    
    
    /**
     Calls englishDateDiffToDate with the current date as the argument
     
     - Returns: String
    */
    func englishDateDiffToNow() -> String {
        let d = Date()
        return englishDateDiffToDate(date: d)
    }
    
    
    func englishWeekday() -> String {
        let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return weekdays[Calendar.current.component(.weekday, from: self)]
    }
    
    func hoursMinutes12h() -> String {
        let hour = Calendar.current.component(.hour, from: self)
        let minute = Calendar.current.component(.minute, from: self)
        return "\(hour > 12 ? hour % 12 : hour):\(minute) \(hour > 12 ? "pm" : "am")"
    }
    
}
