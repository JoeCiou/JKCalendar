//
//  common.swift
//
//  Copyright © 2017 Joe Ciou. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

public class JKYear: NSObject, Comparable {
    public let year: Int
    
    public init?(year: Int) {
        if year < 0{
            return nil
        }
        self.year = year
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        if let object = object as? JKYear{
            return object == self
        }else{
            return false
        }
    }
    
    public static func == (lhs: JKYear, rhs: JKYear) -> Bool {
        return lhs.year == rhs.year
    }
    
    public static func != (lhs: JKYear, rhs: JKYear) -> Bool {
        return lhs.year != rhs.year
    }
    
    public static func < (lhs: JKYear, rhs: JKYear) -> Bool {
        return lhs.year < rhs.year
    }
    
    public static func <= (lhs: JKYear, rhs: JKYear) -> Bool {
        return lhs.year <= rhs.year
    }
    
    public static func > (lhs: JKYear, rhs: JKYear) -> Bool {
        return lhs.year > rhs.year
    }
    
    public static func >= (lhs: JKYear, rhs: JKYear) -> Bool {
        return lhs.year >= rhs.year
    }
}

public class JKMonth: JKYear {
    public let month: Int
    
    public init?(year: Int = Date().year, month: Int = Date().month) {
        if month < 0 || month > 12 {  return nil  }
        self.month = month
        super.init(year: year)
    }
    
    public var next: JKMonth {
        var year = self.year
        var month = self.month + 1
        if month > 12{
            year += 1
            month = 1
        }
        return JKMonth(year: year, month: month)!
    }
    
    public var previous: JKMonth {
        var year = self.year
        var month = self.month - 1
        if month < 1 {
            year -= 1
            month = 12
        }
        return JKMonth(year: year, month: month)!
    }
    
    public var firstDay: JKDay{
        return JKDay(year: year, month: month, day: 1)!
    }
    
    public var lastDay: JKDay{
        let date = JKCalendar.calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDay.date)!
        return JKDay(year: date.year, month: date.month, day: date.day)!
    }
    
    public var daysCount: Int {
        return lastDay.day
    }
    
    public var weeksCount: Int {
        return Int(ceil(Double(daysCount + firstDay.weekday - 1) / 7))
    }
    
    public func weeks() -> [JKWeek] {
        var weeks: [JKWeek] = []
        let weekday = firstDay.weekday - 1
        var offsetDay = firstDay.previous(weekday)
        while offsetDay <= self {
            weeks.append(offsetDay.week())
            offsetDay = offsetDay.next(7)
        }
        return weeks
    }
    
    public var name: String {
        guard let date = JKCalendar.calendar.date(from: DateComponents(year: year, month: month)) else {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"

        return dateFormatter.string(from: date)
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        if let object = object as? JKMonth{
            return object == self
        }else{
            return false
        }
    }
    
    public static func == (lhs: JKMonth, rhs: JKMonth) -> Bool {
        return lhs.year == rhs.year && lhs.month == rhs.month
    }
    
    public static func != (lhs: JKMonth, rhs: JKMonth) -> Bool {
        return lhs.year != rhs.year || lhs.month != rhs.month
    }
    
    public static func < (lhs: JKMonth, rhs: JKMonth) -> Bool {
        return lhs.year < rhs.year || (lhs.year == rhs.year && lhs.month < rhs.month)
    }
    
    public static func <= (lhs: JKMonth, rhs: JKMonth) -> Bool {
        return lhs.year < rhs.year || (lhs.year == rhs.year && lhs.month <= rhs.month)
    }
    
    public static func > (lhs: JKMonth, rhs: JKMonth) -> Bool {
        return lhs.year > rhs.year || (lhs.year == rhs.year && lhs.month > rhs.month)
    }
    
    public static func >= (lhs: JKMonth, rhs: JKMonth) -> Bool {
        return lhs.year > rhs.year || (lhs.year == rhs.year && lhs.month >= rhs.month)
    }
}

public class JKDay: JKMonth {
    public let day: Int
    
    public init?(year: Int, month: Int, day: Int) {
        guard let _ = JKCalendar.calendar.date(from: DateComponents(year: year,
                                                                    month: month,
                                                                    day: day)) else {
            return nil
        }
        self.day = day
        super.init(year: year, month: month)
    }
    
    convenience public init(date: Date) {
        let year = date.year
        let month = date.month
        let day = date.day
        self.init(year: year, month: month, day: day)!
    }
    
    public var date: Date {
        return JKCalendar.calendar.date(from: DateComponents(year: year,
                                                             month: month,
                                                             day: day))!
    }
    
    public var weekday: Int {
        return date.week
    }
    
    public var weekOfMonth: Int {
        return date.weekOfMonth
    }
    
    public var weekOfYear: Int {
        return date.weekOfYear
    }
    
    public func week() -> JKWeek{
        return JKWeek(sunday: self.previous(weekday - 1))
    }
    
    public func next(_ count: Int = 1) -> JKDay{
        let components = DateComponents(day: count)
        return JKDay(date: JKCalendar.calendar.date(byAdding: components, to: date)!)
    }
    
    public func previous(_ count: Int = 1) -> JKDay{
        let components = DateComponents(day: -count)
        return JKDay(date: JKCalendar.calendar.date(byAdding: components, to: date)!)
    }
    
    public func days(until: JKDay) -> [JKDay] {
        let (start, end) = self < until ? (self, until): (until, self)
        
        var days: [JKDay] = [start]
        var offsetDay = start
        
        while offsetDay != end {
            offsetDay = offsetDay.next()
            days.append(offsetDay)
        }
        return days
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        if let object = object as? JKDay{
            return object == self
        }else{
            return false
        }
    }
    
    public static func == (lhs: JKDay, rhs: JKDay) -> Bool {
        return lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day
    }
    
    public static func != (lhs: JKDay, rhs: JKDay) -> Bool {
        return lhs.year != rhs.year || lhs.month != rhs.month || lhs.day != rhs.day
    }
    
    public static func < (lhs: JKDay, rhs: JKDay) -> Bool {
        return lhs.year < rhs.year ||
            (lhs.year == rhs.year && (lhs.month < rhs.month || (lhs.month == rhs.month && lhs.day < rhs.day)))
    }
    
    public static func <= (lhs: JKDay, rhs: JKDay) -> Bool {
        return lhs.year < rhs.year ||
            (lhs.year == rhs.year && (lhs.month < rhs.month || (lhs.month == rhs.month && lhs.day <= rhs.day)))
    }
    
    public static func > (lhs: JKDay, rhs: JKDay) -> Bool {
        return lhs.year > rhs.year ||
            (lhs.year == rhs.year && (lhs.month > rhs.month || (lhs.month == rhs.month && lhs.day > rhs.day)))
    }
    
    public static func >= (lhs: JKDay, rhs: JKDay) -> Bool {
        return lhs.year > rhs.year ||
            (lhs.year == rhs.year && (lhs.month > rhs.month || (lhs.month == rhs.month && lhs.day >= rhs.day)))
    }
}

public class JKWeek{
    
    public let sunday: JKDay
    
    public var monday: JKDay{
        return sunday.next(1)
    }
    
    public var tuesday: JKDay{
        return sunday.next(2)
    }
    
    public var wednesday: JKDay{
        return sunday.next(3)
    }
    
    public var thursday: JKDay{
        return sunday.next(4)
    }
    
    public var friday: JKDay{
        return sunday.next(5)
    }
    
    public var staturday: JKDay{
        return sunday.next(6)
    }
    
    public init(sunday: JKDay) {
        self.sunday = sunday
    }
    
    public func contains(_ day: JKDay) -> Bool {
        return day >= sunday && day <= staturday
    }
}

public func == (lhs: JKWeek, rhs: JKWeek) -> Bool {
    return lhs.sunday == rhs.sunday
}

public func != (lhs: JKWeek, rhs: JKWeek) -> Bool {
    return lhs.sunday != rhs.sunday
}

@objc public enum JKCalendarViewStatus: Int {
    case collapse = 0
    case between
    case expand
}

public extension Date {
    var day: Int {
        return JKCalendar.calendar.component(.day, from: self)
    }
    
    var week: Int {
        return JKCalendar.calendar.component(.weekday, from: self)
    }
    
    var month: Int {
        return JKCalendar.calendar.component(.month, from: self)
    }
    
    var year: Int {
        return JKCalendar.calendar.component(.year, from: self)
    }
    
    var weekOfMonth: Int {
        return JKCalendar.calendar.component(.weekOfMonth, from: self)
    }
    
    var weekOfYear: Int {
        return JKCalendar.calendar.component(.weekOfYear, from: self)
    }
}

