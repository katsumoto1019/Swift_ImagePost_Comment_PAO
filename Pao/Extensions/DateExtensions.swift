//
//  DateExtensions.swift
//  Pao
//
//  Created by Parveen Khatkar on 3/2/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation

extension Date {
    func timeElapsedString(suffix: String = L10n.Date.ago, isShort: Bool = false) -> String {
        let date = Date();
        let interval = Double(date.timeIntervalSince(self));
        let seconds = Int(interval);
        
        if interval < 0 {
            return " ";
        }
        
        func createElapsedString(measurementType: String, seconds: Int) -> String {
            let format = "%.0f " + measurementType + " %@";
            return String(format: format, ceil(interval / Double(seconds)), suffix);
        }
        
        let minute = 60;
        if seconds < minute {
            return createElapsedString(measurementType: isShort ? L10n.Date.secsShort : L10n.Date.secs, seconds: 1);
        }
        
        let hour = 3600; // minute * 60
        if seconds < hour {
            return createElapsedString(measurementType: isShort ? L10n.Date.minsShort : L10n.Date.mins, seconds: minute);
        }
        
        let day = 86400; // hour * 24
        if seconds < day {
            return createElapsedString(measurementType: isShort ? L10n.Date.hoursShort : L10n.Date.hours, seconds: hour);
        }
        
        // NOTE: Different months contain different amount of days
        let daysInMonth = Calendar.current.range(of: .day, in: .month, for: date)!.count;
        let month = day * daysInMonth;
        if seconds < month {
            return createElapsedString(measurementType: isShort ? L10n.Date.daysShort : L10n.Date.days, seconds: day)
        }
        
        // NOTE: Leap years contain 366 days
        let daysInYear = Calendar.current.range(of: .day, in: .year, for: date)!.count;
        let year = day * daysInYear;
        let avgMonth = year / 12;
        if seconds < year {
            return createElapsedString(measurementType: isShort ? L10n.Date.monthsShort : L10n.Date.months, seconds: avgMonth);
        }
        
        let avgYear = 31536000; // day * 365
        return createElapsedString(measurementType: isShort ? L10n.Date.yearsShort : L10n.Date.years, seconds: avgYear);
    }
    
    func formateToString(dateFormat format: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func formateToISO8601String() -> String? {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.string(from: self)
    }
}

extension TimeZone {
    static var offsetStringFromGMT: String {
        var offsetSeconds = current.secondsFromGMT()
        var offsetSymbol = "+"
        
        if offsetSeconds < 0 {
            offsetSymbol = "-"
            offsetSeconds = (offsetSeconds * -1)
        }
        let offsetHours = Int(offsetSeconds / 3600)
        let offsetMinutes = (offsetSeconds - (offsetHours * 3600))  / 60
        
        let offsetString = String(format: "%@%02d:%02d", offsetSymbol, offsetHours, offsetMinutes)
        return offsetString
    }
}
