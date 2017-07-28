//
//  JKCalendarScrollView.swift
//  JKCalendar-Sample
//
//  Created by Joe on 2017/5/26.
//  Copyright © 2017年 Joe. All rights reserved.
//

import UIKit

class JKCalendarScrollView: UIScrollView {

    let calendar: JKCalendar = JKCalendar(frame: CGRect.zero)
    
    private var first = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup(){
        calendar.backgroundColor = UIColor.white
        calendar.interactionObject = self
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let calendarSize = CGSize(width: frame.width,
                                  height: frame.width / 1.2)
        calendar.frame = CGRect(x: 0,
                                y: frame.origin.y/*-calendarSize.height*/,
                                width: calendarSize.width,
                                height: calendarSize.height)
        self.contentInset = UIEdgeInsets(top: calendarSize.height,
                                         left: 0,
                                         bottom: 0,
                                         right: 0)
        
        if first{
            superview?.insertSubview(calendar, aboveSubview: self)
            self.contentOffset = CGPoint(x: 0, y: -calendarSize.height)
            first = false
        }
    }

}
