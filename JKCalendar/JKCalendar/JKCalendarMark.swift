//
//  JKCalendarMark.swift
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

public enum JKCalendarMarkType {
    case circle
    case hollowCircle
    case underline
    case dot
}

public class JKCalendarMarkObject: NSObject {
    
    let type: JKCalendarMarkType
    let color: UIColor
    
    init(type: JKCalendarMarkType, color: UIColor) {
        self.type = type
        self.color = color
        super.init()
    }
}

public class JKCalendarMark: JKCalendarMarkObject {
    
    public let day: JKDay
    
    public init(type: JKCalendarMarkType, day: JKDay, color: UIColor) {
        self.day = day
        super.init(type: type, color: color)
    }
}

public class JKCalendarContinuousMark: JKCalendarMarkObject {
    public let start: JKDay
    public let end: JKDay
    public let days: [JKDay]
    
    public init(type: JKCalendarMarkType, start: JKDay, end: JKDay, color: UIColor) {
        self.start = start
        self.end = end
        self.days = start.days(until: end)
        super.init(type: type, color: color)
    }
}
