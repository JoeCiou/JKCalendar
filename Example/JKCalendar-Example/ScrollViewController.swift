//
//  ScrollViewController.swift
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
import JKCalendar

class ScrollViewController: UIViewController {

    let markColor = UIColor(red: 40/255, green: 178/255, blue: 253/255, alpha: 1)
    var selectDay: JKDay = JKDay(date: Date())
    
    @IBOutlet weak var statusButtonItem: UIBarButtonItem!
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

        calendarScrollView.calendar.focusWeek = JKCalendar.calendar.component(.weekOfMonth, from: selectDay.date) - 1
        calendarScrollView.calendar.isInitializationCollapsed = true
        
        setupTextView()
    }
    
    func setupTextView(){
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
    
    
    @IBAction func handleStatusButtonClick(_ sender: Any) {
        if calendarScrollView.calendar.status == .collapse{
            calendarScrollView.calendar.expand(animated: true)
        }else if calendarScrollView.calendar.status == .expand{
            calendarScrollView.calendar.collapse(animated: true)
        }
    }
    
    @IBAction func handleBackButtonClick(_ sender: Any) {
        let _ = navigationController?.popViewController(animated: true)
    }
    
}

extension ScrollViewController: JKCalendarDelegate{
    
    func calendar(_ calendar: JKCalendar, didTouch day: JKDay){
        selectDay = day
        calendar.focusWeek = day < calendar.month ? 0: day > calendar.month ? calendar.month.weeksCount - 1: day.weekOfMonth - 1
        calendar.reloadData()
    }
    
    func calendar(_ calendar: JKCalendar, didChanged status: JKCalendarViewStatus) {
        statusButtonItem.image = UIImage(named: status == .collapse ? "ic_down": "ic_up")
    }
    
    func heightOfFooterView(in claendar: JKCalendar) -> CGFloat{
        return 10
    }
    
    func viewOfFooter(in calendar: JKCalendar) -> UIView?{
        let view = UIView()
        let line = UIView(frame: CGRect(x: 8, y: 9, width: calendar.frame.width - 16, height: 1))
        line.backgroundColor = UIColor.lightGray
        view.addSubview(line)
        return view
    }
}

extension ScrollViewController: JKCalendarDataSource{
    
    func calendar(_ calendar: JKCalendar, marksWith month: JKMonth) -> [JKCalendarMark]? {
        
        let firstMarkDay: JKDay = JKDay(year: 2018, month: 1, day: 9)!
        let secondMarkDay: JKDay = JKDay(year: 2018, month: 1, day: 20)!
        
        var marks: [JKCalendarMark] = []
        if selectDay == month{
            marks.append(JKCalendarMark(type: .circle,
                                        day: selectDay,
                                        color: markColor))
        }
        if firstMarkDay == month{
            marks.append(JKCalendarMark(type: .underline,
                                        day: firstMarkDay,
                                        color: markColor))
        }
        if secondMarkDay == month{
            marks.append(JKCalendarMark(type: .hollowCircle,
                                        day: secondMarkDay,
                                        color: markColor))
        }
        return marks
    }
    
    func calendar(_ calendar: JKCalendar, continuousMarksWith month: JKMonth) -> [JKCalendarContinuousMark]?{
        let startDay: JKDay = JKDay(year: 2018, month: 1, day: 17)!
        let endDay: JKDay = JKDay(year: 2018, month: 1, day: 18)!
        
        return [JKCalendarContinuousMark(type: .dot,
                                         start: startDay,
                                         end: endDay,
                                         color: markColor)]
    }
    
}

