//
//  JKCalendarMark.swift
//  JKCalendar-Sample
//
//  Created by Joe on 2017/3/16.
//  Copyright © 2017年 Joe. All rights reserved.
//

import UIKit

public enum JKCalendarMarkType{
    case circle
    case hollowCircle
    case underline
    case dot
}

public class JKCalendarMarkObject: NSObject {
    
    let type: JKCalendarMarkType
    let color: UIColor
    
    init(type: JKCalendarMarkType, color: UIColor){
        self.type = type
        self.color = color
        super.init()
    }
}

public class JKCalendarMark: JKCalendarMarkObject {
    
    public let day: JKDay
    
    public init(type: JKCalendarMarkType, day: JKDay, color: UIColor){
        self.day = day
        super.init(type: type, color: color)
    }
    
}

public class JKCalendarContinuousMark: JKCalendarMarkObject{
    public let start: JKDay
    public let end: JKDay
    public let days: [JKDay]
    
    public init(type: JKCalendarMarkType, start: JKDay, end: JKDay, color: UIColor){
        self.start = start
        self.end = end
        self.days = start.days(until: end)
        super.init(type: type, color: color)
    }
    
}
