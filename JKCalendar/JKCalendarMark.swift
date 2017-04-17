//
//  JKCalendarMark.swift
//  JKCalendar-Sample
//
//  Created by Joe on 2017/3/16.
//  Copyright © 2017年 Joe. All rights reserved.
//

import UIKit

enum JKCalendarMarkType{
    case circle
    case hollowCircle
    case underline
    case dot
}

class JKCalendarMark: NSObject {
    
    let type: JKCalendarMarkType
    let color: UIColor
    
    init(type: JKCalendarMarkType, color: UIColor){
        self.type = type
        self.color = color
        super.init()
    }
}

class JKCalendarContinuousMark: JKCalendarMark{
    let start: JKDay
    let end: JKDay
    let days: [JKDay]
    
    init(type: JKCalendarMarkType, start: JKDay, end: JKDay, color: UIColor){
        self.start = start
        self.end = end
        self.days = start.days(until: end)
        super.init(type: type, color: color)
    }
    
}
