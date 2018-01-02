//
//  SelectorViewController.swift
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

class SelectorViewController: UIViewController {

    var selectDays: [JKDay]?{
        didSet{
            if let days = selectDays,
                days.count > 0{
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                
                if days.count == 1{
                    dateLabel.text = formatter.string(from: days.first!.date)
                }else{
                    dateLabel.text = formatter.string(from: days.first!.date) + "-" + formatter.string(from: days.last!.date)
                }
            }
        }
    }
    
    var markColor = UIColor(red: 40/255, green: 178/255, blue: 253/255, alpha: 1)
    
    @IBOutlet weak var calendar: JKCalendar!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.delegate = self
        calendar.dataSource = self
        
        calendar.textColor = UIColor(white: 0.25, alpha: 1)
        calendar.backgroundColor = UIColor.white
        
        calendar.isNearbyMonthNameDisplayed = false
        calendar.isScrollEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleBackButtonClick(_ sender: Any) {
        let _ = navigationController?.popViewController(animated: true)
    }

}

extension SelectorViewController: JKCalendarDelegate{
    
    func calendar(_ calendar: JKCalendar, didTouch day: JKDay) {
        selectDays = [day]
        calendar.reloadData()
    }
    
    func calendar(_ calendar: JKCalendar, didPan days: [JKDay]) {
        selectDays = days
        calendar.reloadData()
    }
}

extension SelectorViewController: JKCalendarDataSource{
    
    func calendar(_ calendar: JKCalendar, continuousMarksWith month: JKMonth) -> [JKCalendarContinuousMark]?{
        if let days = selectDays,
            let start = days.first,
            let end = days.last{
            return [JKCalendarContinuousMark(type: .circle, start: start, end: end, color: markColor)]
        }else{
            return nil
        }
    }
    
}
