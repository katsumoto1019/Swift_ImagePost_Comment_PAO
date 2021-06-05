//
//  Date+Yesterday_Tomorrow.swift
//  SwiftCacher
//
//  Created by kant on 02.05.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import Foundation

extension Date {
    
    func sameTimeNextDay(
        inDirection direction: Calendar.SearchDirection = .forward,
        using calendar: Calendar = .current
    ) -> Date {
        let components = calendar.dateComponents(
            [.hour, .minute, .second, .nanosecond],
            from: self
        )
        
        return calendar.nextDate(
            after: self,
            matching: components,
            matchingPolicy: .nextTime,
            direction: direction
        )!
    }
    
    static var currentTimeTomorrow: Date {
        return Date().sameTimeNextDay()
    }
    
    static var currentTimeYesterday: Date {
        return Date().sameTimeNextDay(inDirection: .backward)
    }
}
