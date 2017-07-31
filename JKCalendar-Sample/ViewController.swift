//
//  ViewController.swift
//  JKCalendar-Sample
//
//  Created by Joe on 2017/3/10.
//  Copyright © 2017年 Joe. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var selectDay: JKDay = JKDay(date: Date())
    
    var markColor = UIColor(red: 40/255, green: 178/255, blue: 253/255, alpha: 1)
    
    var firstMarkDays: [JKDay] = [JKDay(year: 2017, month: 3, day: 24)!,
                                  JKDay(year: 2017, month: 4, day: 5)!,
                                  JKDay(year: 2017, month: 3, day: 11)!]
    
    var secondMarkDays: [JKDay] = [JKDay(year: 2017, month: 3, day: 18)!,
                                   JKDay(year: 2017, month: 4, day: 3)!,
                                   JKDay(year: 2017, month: 3, day: 16)!]
    var continuousMarkStartDay: JKDay = JKDay(year: 2017, month: 4, day: 13)!
    var continuousMarkEndDay: JKDay = JKDay(year: 2017, month: 4, day: 14)!
    
//    var selectDays: [JKDay]?
    
    @IBOutlet weak var calendarScrollView: JKCalendarScrollView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        calendarScrollView.calendar.delegate = self
        calendarScrollView.calendar.dataSource = self
        
        calendarScrollView.calendar.textColor = UIColor(red: 60/255,
                                                        green: 60/255,
                                                        blue: 60/255,
                                                        alpha: 1)
        calendarScrollView.calendar.backgroundColor = UIColor.white
//        calendar.isScrollEnabled = false
        
        calendarScrollView.calendar.foldWeekIndex = calendarScrollView.calendar.month.weeks().index(where: { (week) -> Bool in
            return week.contains(selectDay)
        })!
        
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        dateLabel.text = formatter.string(from: selectDay.date)
        
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        timeLabel.text = formatter.string(from: selectDay.date)
        
        textview.textContainerInset = UIEdgeInsets.zero
        textview.textContainer.lineFragmentPadding = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: JKCalendarDelegate{
    
    func calendar(_ calendar: JKCalendar, didTouch day: JKDay){
        selectDay = day
        calendar.foldWeekIndex = calendar.month.weeks().index(where: { (week) -> Bool in
            return week.contains(day)
        })!
        calendar.reloadData()
    }
    /*
    func calendar(_ calendar: JKCalendar, didPan days: [JKDay]) {
        selectDays = days
        calendar.reloadData()
    }
    */
}

extension ViewController: JKCalendarDataSource{
    
    func calendar(_ calendar: JKCalendar, markWith day: JKDay) -> JKCalendarMark? {
        
        if day == selectDay{
            return JKCalendarMark(type: .circle,
                                  day: day,
                                  color: markColor)
        }else if firstMarkDays.contains(day) {
            return JKCalendarMark(type: .underline,
                                  day: day,
                                  color: markColor)
        }else if secondMarkDays.contains(day) {
            return JKCalendarMark(type: .dot,
                                  day: day,
                                  color: markColor)
        }
        
        return nil
    }
    
    func calendar(_ calendar: JKCalendar, continuousMarksWith month: JKMonth) -> [JKCalendarContinuousMark]?{
        /*
        if let days = selectDays,
            let start = days.first,
            let end = days.last{
            return [JKCalendarContinuousMark(type: .circle, start: start, end: end, color: markColor)]
        }
        */
        
        return [JKCalendarContinuousMark(type: .dot,
                                         start: continuousMarkStartDay,
                                         end: continuousMarkEndDay,
                                         color: markColor)]
    }
    
}


