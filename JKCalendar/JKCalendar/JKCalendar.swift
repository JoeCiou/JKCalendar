//
//  JKCalendar.swift
//  JKCalendar-Sample
//
//  Created by Joe on 2017/3/10.
//  Copyright © 2017年 Joe. All rights reserved.
//

import UIKit

@IBDesignable public class JKCalendar: UIView {
    
    static let calendar = Calendar(identifier: .gregorian)
    
    public var textColor: UIColor = UIColor.black{
        didSet{
            reloadData()
        }
    }
    
    public var isScrollEnabled: Bool = true{
        didSet{
            calendarPageView.isScrollEnabled = isScrollEnabled
        }
    }
    
    public var mode: JKCalendarViewMode{
        return (foldValue / foldMaxValue) > 0.5 ? .week: .month
    }
    
    public var delegate: JKCalendarDelegate?
    public var dataSource: JKCalendarDataSource?
    
    var interactionObject: UIScrollView?{
        didSet{
            if let object = interactionObject{
                object.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: nil)
            }
        }
    }
    
    public override var backgroundColor: UIColor?{
        set{
            super.backgroundColor = UIColor.clear
            calendarPageView.backgroundColor = newValue
            calendarPageView.currentView?.backgroundColor = newValue
        }
        get{
            return calendarPageView.backgroundColor
        }
    }
    
    public fileprivate(set) var month: JKMonth = JKMonth(year: Date().year, month: Date().month)!{
        didSet{
            if foldWeekIndex >= month.weeksCount{
                foldWeekIndex = month.weeksCount - 1
            }
            
            let weekCount = month.weeksCount
            foldMaxValue = calendarPageView.frame.height * CGFloat(weekCount - 1) / CGFloat(weekCount)
        }
    }
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var calendarPageView: JKInfinitePageView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageViewHeightConstraint: NSLayoutConstraint!
    
    public var foldWeekIndex: Int = 0
    
    var foldValue: CGFloat = 0{
        didSet{
            if let calendarView = calendarPageView.currentView as? JKCalendarView,
                calendarView.foldValue != foldValue{
                calendarView.foldValue = foldValue
                contentViewBottomConstraint.constant = foldValue
            }
        }
    }
    var foldMaxValue: CGFloat = 0
    fileprivate var contentViewBottomConstraint: NSLayoutConstraint!
    
    public override init(frame: CGRect){
        super.init(frame: frame)
        setupContentViewUI()
        setupCalendarView()
        
        pageViewHeightConstraint.constant = frame.height - 67 > 0 ? frame.height - 67: 0
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupContentViewUI()
        setupCalendarView()
    }
    
    public override func layoutSubviews() {
        pageViewHeightConstraint.constant = frame.height - 67 > 0 ? frame.height - 67: 0
        super.layoutSubviews()
        
        let weekCount = month.weeksCount
        foldMaxValue = calendarPageView.frame.height * CGFloat(weekCount - 1) / CGFloat(weekCount)
    }
    
    func setupContentViewUI(){
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "JKCalendar", bundle: bundle)
        let contentView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        
        let topConstraint = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        contentViewBottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0)
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["contentView": contentView])

        addConstraint(topConstraint)
        addConstraint(contentViewBottomConstraint)
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
            calendarView.resetWeeksInfo()
            calendarView.setNeedsDisplay()
        }
    }
    
    public func fold(){
        
    }
    
    public func unfold(){
        
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let change = change{
            if let keyPath = keyPath,
                keyPath == "contentOffset",
                let contentOffset = change[NSKeyValueChangeKey.newKey] as? CGPoint{
                
                var value = frame.height + contentOffset.y
                if value > foldMaxValue {
                    value = foldMaxValue
                }else if value < 0{
                    value = 0
                }
                
                foldValue = value
            }
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

@objc public protocol JKCalendarDelegate {
    
    @objc optional func calendar(_ calendar: JKCalendar, didTouch day: JKDay)
    
    @objc optional func calendar(_ calendar: JKCalendar, didPan days: [JKDay])
    
}

@objc public protocol JKCalendarDataSource{
    
    @objc optional func calendar(_ calendar: JKCalendar, markWith day: JKDay) -> JKCalendarMark?
    
    @objc optional func calendar(_ calendar: JKCalendar, continuousMarksWith month: JKMonth) -> [JKCalendarContinuousMark]?
}

