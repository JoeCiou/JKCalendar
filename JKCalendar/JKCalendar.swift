//
//  JKCalendar.swift
//  JKCalendar-Sample
//
//  Created by Joe on 2017/3/10.
//  Copyright © 2017年 Joe. All rights reserved.
//

import UIKit

class JKCalendar: UIView {
    
    open var textColor: UIColor = UIColor.black{
        didSet{
            reloadData()
        }
    }
    
    open var isScrollEnabled: Bool = true{
        didSet{
            calendarPageView.isScrollEnabled = isScrollEnabled
        }
    }
    
    open var delegate: JKCalendarDelegate?
    open var dataSource: JKCalendarDataSource?
    
    fileprivate(set) var month = JKMonth(year: Date().year, month: Date().month)!

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var calendarPageView: JKInfinitePageView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupContentViewUI()
        setupCalendarView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupContentViewUI()
        setupCalendarView()
    }
    
    func setupContentViewUI(){
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "JKCalendar", bundle: bundle)
        let contentView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[contentView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["contentView": contentView])
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["contentView": contentView])
        addConstraints(verticalConstraints)
        addConstraints(horizontalConstraints)
    }
    
    func setupCalendarView(){
        calendarPageView.dataSource = self
        
        let calendarView = JKCalendarView(calendar: self, month: month)
        calendarView.backgroundColor = backgroundColor
        calendarView.panRecognizer.isEnabled = !isScrollEnabled
        calendarPageView.setView(calendarView)
        
        monthLabel.text = month.name
        yearLabel.text = "\(month.year)"
        previousButton.setTitle(month.previous.name, for: .normal)
        nextButton.setTitle(month.next.name, for: .normal)
    }
    
    public func reloadData() {
        if let calendarView = calendarPageView.currentView as? JKCalendarView{
            calendarView.setNeedsDisplay()
        }
    }
    
    @IBAction func handlePreviousButtonClick(_ sender: Any) {
        calendarPageView.previousPage()
    }
    
    @IBAction func handleNextButtonClick(_ sender: Any) {
        calendarPageView.nextPage()
    }
    
}

extension JKCalendar: JKInfinitePageViewDataSource{
    
    func infinitePageView(_ infinitePageView: JKInfinitePageView, viewBefore view: UIView) -> UIView {
        let view = view as! JKCalendarView
        
        let calendarView = JKCalendarView(calendar: self, month: view.month.previous)
        calendarView.backgroundColor = backgroundColor
        calendarView.panRecognizer.isEnabled = !isScrollEnabled
        return calendarView
    }
    
    func infinitePageView(_ infinitePageView: JKInfinitePageView, viewAfter view: UIView) -> UIView {
        let view = view as! JKCalendarView
        
        let calendarView = JKCalendarView(calendar: self, month: view.month.next)
        calendarView.backgroundColor = backgroundColor
        calendarView.panRecognizer.isEnabled = !isScrollEnabled
        return calendarView
    }
    
    func infinitePageView(_ infinitePageView: JKInfinitePageView, didDisplay view: UIView){
        previousButton.setTitle(month.previous.name, for: .normal)
        nextButton.setTitle(month.next.name, for: .normal)
    }
    
    func infinitePageView(_ infinitePageView: JKInfinitePageView, afterWith view: UIView, progress: Double) {
        let calendarView = view as! JKCalendarView
        let nextMonth = calendarView.month
        let acrossYear = nextMonth.previous.year != nextMonth.year
        let centerX = self.frame.width / 2
        
        if progress < 0.5{
            month = nextMonth.previous
            let newPositionX = centerX - monthLabel.frame.width * CGFloat(progress)
            let alpha = CGFloat(1 - progress * 2)
            
            monthLabel.alpha = alpha
            monthLabel.layer.position = CGPoint(x: newPositionX, y: monthLabel.center.y)
            
            if acrossYear{
                yearLabel.alpha = alpha
                yearLabel.layer.position = CGPoint(x: newPositionX, y: yearLabel.center.y)
            }else{
                yearLabel.alpha = 1
                yearLabel.layer.position = CGPoint(x: centerX, y: yearLabel.center.y)
            }
        }else{
            month = nextMonth
            let newPositionX = centerX + monthLabel.frame.width * CGFloat(1 - progress)
            let alpha = CGFloat((progress - 0.5) * 2)
            
            monthLabel.alpha = alpha
            monthLabel.layer.position = CGPoint(x: newPositionX, y: monthLabel.center.y)
            
            if acrossYear{
                yearLabel.alpha = alpha
                yearLabel.layer.position = CGPoint(x: newPositionX, y: yearLabel.center.y)
            }else{
                yearLabel.alpha = 1
                yearLabel.layer.position = CGPoint(x: centerX, y: yearLabel.center.y)
            }
        }
        
        monthLabel.text = month.name
        yearLabel.text = "\(month.year)"
    }
    
    func infinitePageView(_ infinitePageView: JKInfinitePageView, beforeWith view: UIView, progress: Double) {
        let calendarView = view as! JKCalendarView
        let previousMonth = calendarView.month
        let acrossYear = previousMonth.next.year != previousMonth.year
        let centerX = self.frame.width / 2
        
        if progress < 0.5{
            month = previousMonth.next
            let newPositionX = centerX + monthLabel.frame.width * CGFloat(progress)
            let alpha = CGFloat(1 - progress * 2)
            
            monthLabel.alpha = alpha
            monthLabel.layer.position = CGPoint(x: newPositionX, y: monthLabel.center.y)
            
            if acrossYear{
                yearLabel.alpha = alpha
                yearLabel.layer.position = CGPoint(x: newPositionX, y: yearLabel.center.y)
            }else{
                yearLabel.alpha = 1
                yearLabel.layer.position = CGPoint(x: centerX, y: yearLabel.center.y)
            }
        }else{
            month = previousMonth
            let newPositionX = centerX - monthLabel.frame.width * CGFloat(1 - progress)
            let alpha = CGFloat((progress - 0.5) * 2)
            
            monthLabel.alpha = alpha
            monthLabel.layer.position = CGPoint(x: newPositionX, y: monthLabel.center.y)
            
            if acrossYear{
                yearLabel.alpha = alpha
                yearLabel.layer.position = CGPoint(x: newPositionX, y: yearLabel.center.y)
            }else{
                yearLabel.alpha = 1
                yearLabel.layer.position = CGPoint(x: centerX, y: yearLabel.center.y)
            }
        }
        
        monthLabel.text = month.name
        yearLabel.text = "\(month.year)"
    }
}

@objc protocol JKCalendarDelegate {
    
    @objc optional func calendar(_ calendar: JKCalendar, didTouch day: JKDay)
    
    @objc optional func calendar(_ calendar: JKCalendar, didPan days: [JKDay])
    
}

@objc protocol JKCalendarDataSource{
    
    @objc optional func calendar(_ calendar: JKCalendar, markWith day: JKDay) -> JKCalendarMark?
    
    @objc optional func calendar(_ calendar: JKCalendar, continuousMarksWith month: JKMonth) -> [JKCalendarContinuousMark]?
}

