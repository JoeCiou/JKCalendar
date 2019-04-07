//
//  JKCalendar.swift
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
import JKInfinitePageView

public class JKCalendar: UIView {
    
    /**
         A gregorian calendar
     */
    static public let calendar = Calendar(identifier: .gregorian)
    
    /**
         The object that acts as the delegate of the calendar view.
     
         The delegate must adopt the JKCalendarDelegate protocol. The calendar view maintains a weak reference to the delegate object.
     */
    public weak var delegate: JKCalendarDelegate?
    
    /**
         The object that provides the marks data for the calendar view.
     
         The data source must adopt the JKCalendarDataSource protocol. The calendar view maintains a weak reference to the data source object.
     */
    public weak var dataSource: JKCalendarDataSource?
    
    /**
         The status of the calendar view.
     */
    public var status: JKCalendarViewStatus {
        if collapsedValue == collapsedMaximum {
            return .collapse
        } else if collapsedValue == 0 {
            return .expand
        } else {
            return .between
        }
    }

    /**
        The color of the day text. Default value for this property is a black color.
     */
    public var textColor: UIColor = UIColor.black {
        didSet {
            reloadData()
        }
    }
    
    /**
        A Boolean value that determines whether scrolling is enabled. The default is true.
     */
    public var isScrollEnabled: Bool = true {
        didSet {
            calendarPageView.isScrollEnabled = isScrollEnabled
            if let calendarView = calendarPageView.currentView as? JKCalendarView {
                calendarView.panRecognizer.isEnabled = !isScrollEnabled
            }
        }
    }
    
    /**
         This Boolean determines whether the calendar status is collapsed at initialization. The default is false.
     */
    public var isInitializationCollapsed: Bool = false
    
    /**
         This Boolean determines whether the top view is displayed. The default is true.
     */
    public var isTopViewDisplayed: Bool = true {
        didSet{
            topView.isHidden = !isTopViewDisplayed
            weekViewTopConstraint.constant = isTopViewDisplayed ? 44: 0
        }
    }
    
    /**
         This Boolean determines whether nearby month button is displayed. The default is true.
     */
    public var isNearbyMonthButtonDisplayed: Bool = true {
        didSet {
            previousButton.isHidden = !isNearbyMonthButtonDisplayed
            nextButton.isHidden = !isNearbyMonthButtonDisplayed
        }
    }
    
    /**
         A Boolean value that determines whether nearby month name is displayed. The default is true.
     */
    public var isNearbyMonthNameDisplayed: Bool = true {
        didSet {
            previousButton.setTitle(isNearbyMonthNameDisplayed ? month.previous.name : nil, for: .normal)
            nextButton.setTitle(isNearbyMonthNameDisplayed ? month.next.name : nil, for: .normal)
        }
    }
    
    /**
        The calendar view is background color. The default value is nil, which results in a transparent background color.
     */
    public override var backgroundColor: UIColor? {
        set {
            topView?.backgroundColor = newValue
            weekView?.backgroundColor = newValue
            calendarPageView?.backgroundColor = newValue
            calendarPageView?.currentView?.backgroundColor = newValue
            footerView?.backgroundColor = newValue
        }

        get {
            return calendarPageView?.backgroundColor
        }
    }
    
    /**
        The month object of the calendar view. The default is the current month.
     */
    public var month: JKMonth {
        set {
            if let calendarView = calendarPageView.currentView as? JKCalendarView {
                calendarView.month = newValue
            }
            _month = newValue
        }

        get {
            return _month
        }
    }
    
    /**
        The property is the display week index of the calendar view in the folded state.
     */
    public var focusWeek: Int{
        set {
            if let calendarView = calendarPageView.currentView as? JKCalendarView {
                calendarView.focusWeek = newValue
            }
        }
        get {
            if let calendarView = calendarPageView.currentView as? JKCalendarView {
                return calendarView.focusWeek
            } else {
                return 0
            }
        }
    }
    
    var _month: JKMonth = JKMonth()! {
        didSet {
            let weekCount = month.weeksCount
            collapsedMaximum = pageViewHeightConstraint.constant * CGFloat(weekCount - 1) / CGFloat(weekCount)
            setupLabels()
            delegate?.calendar?(self, didChangedMonth: _month)
        }
    }
    
    var collapsedValue: CGFloat = 0 {
        didSet{
            if let calendarView = calendarPageView.currentView as? JKCalendarView,
                calendarView.collapsedValue != collapsedValue {
                calendarView.collapsedValue = collapsedValue
                contentViewBottomConstraint.constant = collapsedValue
                
                previousButton.setTitleColor(previousButton.titleColor(for: .normal)!.withAlphaComponent(1 - collapsedValue / collapsedMaximum), for: .normal)
                nextButton.setTitleColor(nextButton.titleColor(for: .normal)!.withAlphaComponent(1 - collapsedValue / collapsedMaximum), for: .normal)
                
                if collapsedValue == 0 && oldValue != collapsedValue {
                    delegate?.calendar?(self, didChangedStatus: .expand)
                    calendarPageView.isScrollEnabled = true
                } else if collapsedValue == collapsedMaximum && oldValue != collapsedValue {
                    delegate?.calendar?(self, didChangedStatus: .collapse)
                    calendarPageView.isScrollEnabled = true
                } else if (collapsedValue != 0 && oldValue == 0) || (collapsedValue != collapsedMaximum && oldValue == collapsedMaximum) {
                    delegate?.calendar?(self, didChangedStatus: .between)
                    calendarPageView.isScrollEnabled = false
                }
            }
        }
    }
    
    var collapsedMaximum: CGFloat = 0
    
    fileprivate var contentViewBottomConstraint: NSLayoutConstraint!
    
    private var first = true
    
    weak var interactionObject: UIScrollView?
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var calendarPageView: JKInfinitePageView!
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var leftContentView: UIView!
    @IBOutlet weak var rightContentView: UIView!
    
    @IBOutlet weak var pageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var weekViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var footerViewHeightConstraint: NSLayoutConstraint!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentViewUI()
        setupCalendarView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupContentViewUI()
        setupCalendarView()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let footerHeight = delegate?.heightOfFooterView?(in: self) ?? 0
        footerViewHeightConstraint.constant = footerHeight
        
        if let view = delegate?.viewOfFooter?(in: self),
            footerView.subviews.count == 0 {
            footerView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: .directionLeadingToTrailing, metrics: nil, views: ["view": view])
            let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: .directionLeadingToTrailing, metrics: nil, views: ["view": view])
            addConstraints(horizontalConstraints)
            addConstraints(verticalConstraints)
        }
        
        let pageViewHeight = frame.height - weekViewTopConstraint.constant - weekView.frame.height - footerHeight
        pageViewHeightConstraint.constant = pageViewHeight > 0 ? pageViewHeight: 0
        
        let weekCount = month.weeksCount
        let maximum = pageViewHeightConstraint.constant * CGFloat(weekCount - 1) / CGFloat(weekCount)
        if first {
            collapsedMaximum = maximum
            if isInitializationCollapsed {
                if let object = interactionObject {
                    object.setContentOffset(CGPoint(x: 0, y: collapsedMaximum - bounds.height), animated: false)
                } else {
                    collapsedValue = maximum
                }
            }
            first = false
        }else{
            // handle changed of collapsed maximum
            if maximum != collapsedMaximum && collapsedValue == collapsedMaximum {
                if let object = interactionObject{
                    object.setContentOffset(CGPoint(x: 0, y: collapsedMaximum - bounds.height), animated: false)
                } else {
                    collapsedValue = maximum
                }
            }
            collapsedMaximum = maximum
        }
        
        if let view = calendarPageView.currentView as? JKCalendarView {
            view.setNeedsDisplay()
        }
    }
    
    func setupContentViewUI() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "JKCalendar", bundle: bundle)

        let contentView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = backgroundColor
        addSubview(contentView)
        
        let topConstraint = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        contentViewBottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0)
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["contentView": contentView])

        addConstraint(topConstraint)
        addConstraint(contentViewBottomConstraint)
        addConstraints(horizontalConstraints)
    }
    
    func setupCalendarView() {
        calendarPageView.delegate = self
        calendarPageView.dataSource = self
        
        let calendarView = JKCalendarView(calendar: self, month: month)
        calendarView.backgroundColor = backgroundColor
        calendarView.panRecognizer.isEnabled = !isScrollEnabled
        calendarPageView.setView(calendarView)
        
        setupLabels()
    }

    func setupLabels() {
        monthLabel.text = month.name
        yearLabel.text = "\(month.year)"

        previousButton.setTitle(isNearbyMonthNameDisplayed ? month.previous.name : nil, for: .normal)
        nextButton.setTitle(isNearbyMonthNameDisplayed ? month.next.name : nil, for: .normal)
    }
    
    public func setLeftCustomView(_ view: UIView) {
        isNearbyMonthButtonDisplayed = false
        
        leftContentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(view.centerXAnchor.constraint(equalTo: leftContentView.centerXAnchor))
        addConstraint(view.centerYAnchor.constraint(equalTo: leftContentView.centerYAnchor))
        
        let widthConstraint = view.widthAnchor.constraint(equalTo: leftContentView.widthAnchor)
        widthConstraint.priority = UILayoutPriority.defaultHigh
        addConstraint(widthConstraint)
        
        let heightConstraint = view.heightAnchor.constraint(equalTo: leftContentView.heightAnchor)
        heightConstraint.priority = UILayoutPriority.defaultHigh
        addConstraint(heightConstraint)
    }
    
    public func setRightCustomView(_ view: UIView) {
        isNearbyMonthButtonDisplayed = false
        
        rightContentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(view.centerXAnchor.constraint(equalTo: rightContentView.centerXAnchor))
        addConstraint(view.centerYAnchor.constraint(equalTo: rightContentView.centerYAnchor))
        
        let widthConstraint = view.widthAnchor.constraint(equalTo: rightContentView.widthAnchor)
        widthConstraint.priority = UILayoutPriority.defaultHigh
        addConstraint(widthConstraint)
        
        let heightConstraint = view.heightAnchor.constraint(equalTo: rightContentView.heightAnchor)
        heightConstraint.priority = UILayoutPriority.defaultHigh
        addConstraint(heightConstraint)
    }
    
    /**
        Reloads all of the marks data for the calendar view.
     */
    public func reloadData() {
        if let calendarView = calendarPageView.currentView as? JKCalendarView{
            calendarView.resetWeeksInfo()
            calendarView.setNeedsDisplay()
        }
    }
    
    /**
         Collapsed up the calendar view.
     
         - Parameters:
         - animated: True to animate the transition at a constant velocity to the collapsed status, false to make the transition immediate.
     */
    public func collapse(animated: Bool) {
        if let object = interactionObject{
            object.setContentOffset(CGPoint(x: 0, y: collapsedMaximum - bounds.height), animated: animated)
        }else{
            if animated{
                continuouslyChangeCollapsedValue(destination: collapsedMaximum, duration: 0.2)
            } else {
                collapsedValue = collapsedMaximum
            }
        }
    }
    
    /**
         expanded up the calendar view.
     
         - Parameters:
         - animated: True to animate the transition at a constant velocity to the expanded status, false to make the transition immediate.
     */
    public func expand(animated: Bool) {
        if let object = interactionObject{
            object.setContentOffset(CGPoint(x: 0, y: -bounds.height), animated: animated)
        }else{
            if animated {
                continuouslyChangeCollapsedValue(destination: 0, duration: 0.2)
            } else {
                collapsedValue = 0
            }
        }
    }
    
    func continuouslyChangeCollapsedValue(destination: CGFloat, duration: Double){
        let timer = Timer(timeInterval: 0.02,
                          target: self,
                          selector: #selector(handleStatusChangeTimer(_:)),
                          userInfo: ["source": collapsedValue,
                                     "destination": destination,
                                     "duration": duration,
                                     "startDate": Date()],
                          repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
    }
    
    @objc
    func handleStatusChangeTimer(_ timer: Timer){
        if let userInfo = timer.userInfo as? [String: Any],
            let source = userInfo["source"] as? CGFloat,
            let destination = userInfo["destination"] as? CGFloat,
            let duration = userInfo["duration"] as? Double,
            let startDate = userInfo["startDate"] as? Date {
            
            let elapsing = Date().timeIntervalSince1970 - startDate.timeIntervalSince1970
            collapsedValue = source + (destination - source) * CGFloat(elapsing >= duration ? 1: elapsing / duration)
            
            if collapsedValue == destination{
                timer.invalidate()
            }
        } else {
            timer.invalidate()
        }
    }
    
    /**
        Move the calendar view to the next month or week
     */
    public func next() {
        calendarPageView.nextPage()
    }
    
    /**
        Move the calendar view to the previous month or week
     */
    public func previous() {
        calendarPageView.previousPage()
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        if result == self { return nil }
        return result
    }
    
    @IBAction func handleNextButtonClick(_ sender: Any) {
        next()
    }
    
    @IBAction func handlePreviousButtonClick(_ sender: Any) {
        previous()
    }
}

extension JKCalendar: JKInfinitePageViewDelegate {
    public func infinitePageView(_ infinitePageView: JKInfinitePageView, afterWith view: UIView, progress: Double) {
        let calendarView = view as! JKCalendarView
        let currentCalendarView = infinitePageView.currentView! as! JKCalendarView
        
        if status == .collapse && calendarView.month == currentCalendarView.month{
            return
        }
        
        let nextMonth = calendarView.month
        let acrossYear = nextMonth.previous.year != nextMonth.year
        let centerX = self.frame.width / 2
        
        if progress < 0.5{
            _month = nextMonth.previous
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
            _month = nextMonth
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
    }
    
    public func infinitePageView(_ infinitePageView: JKInfinitePageView, beforeWith view: UIView, progress: Double) {
        let calendarView = view as! JKCalendarView
        let currentCalendarView = infinitePageView.currentView! as! JKCalendarView
        
        if status == .collapse && calendarView.month == currentCalendarView.month{
            return
        }
        
        let previousMonth = calendarView.month
        let acrossYear = previousMonth.next.year != previousMonth.year
        let centerX = self.frame.width / 2
        
        if progress < 0.5{
            _month = previousMonth.next
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
            _month = previousMonth
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
    }
}

extension JKCalendar: JKInfinitePageViewDataSource{
    
    public func infinitePageView(_ infinitePageView: JKInfinitePageView, viewBefore view: UIView) -> UIView {
        let view = view as! JKCalendarView
        
        var calendarView: JKCalendarView!
        if status == .expand {
            calendarView = JKCalendarView(calendar: self, month: view.month.previous)
            calendarView.focusWeek = focusWeek >= calendarView.month.weeksCount ? calendarView.month.weeksCount - 1: focusWeek
        } else if focusWeek - 1 >= 0 {
            calendarView = JKCalendarView(calendar: self, month: view.month)
            calendarView.focusWeek = focusWeek - 1
        } else {
            calendarView = JKCalendarView(calendar: self, month: view.month.previous)
            calendarView.focusWeek = view.month.previous.weeksCount - 1
        }
        calendarView.backgroundColor = backgroundColor
        calendarView.collapsedValue = collapsedValue
        calendarView.panRecognizer.isEnabled = !isScrollEnabled
        
        return calendarView
    }
    
    public func infinitePageView(_ infinitePageView: JKInfinitePageView, viewAfter view: UIView) -> UIView {
        let view = view as! JKCalendarView
        
        var calendarView: JKCalendarView!
        if status == .expand {
            calendarView = JKCalendarView(calendar: self, month: view.month.next)
            calendarView.focusWeek = focusWeek >= calendarView.month.weeksCount ? calendarView.month.weeksCount - 1: focusWeek
        } else if focusWeek + 1 < view.month.weeksCount {
            calendarView = JKCalendarView(calendar: self, month: view.month)
            calendarView.focusWeek = focusWeek + 1
        } else {
            calendarView = JKCalendarView(calendar: self, month: view.month.next)
            calendarView.focusWeek = 0
        }

        calendarView.backgroundColor = backgroundColor
        calendarView.collapsedValue = collapsedValue
        calendarView.panRecognizer.isEnabled = !isScrollEnabled
        
        return calendarView
    }
}

@objc public protocol JKCalendarDelegate {
    
    @objc optional func calendar(_ calendar: JKCalendar, didTouch day: JKDay)
    
    @objc optional func calendar(_ calendar: JKCalendar, didPan days: [JKDay])
    
    @objc optional func calendar(_ calendar: JKCalendar, didChangedStatus status: JKCalendarViewStatus)
    
    @objc optional func calendar(_ calendar: JKCalendar, didChangedMonth month: JKMonth)
    
    @objc optional func heightOfFooterView(in calendar: JKCalendar) -> CGFloat
    
    @objc optional func viewOfFooter(in calendar: JKCalendar) -> UIView?
}

@objc public protocol JKCalendarDataSource{
    
    @objc optional func calendar(_ calendar: JKCalendar, marksWith month: JKMonth) -> [JKCalendarMark]?
    
    @objc optional func calendar(_ calendar: JKCalendar, continuousMarksWith month: JKMonth) -> [JKCalendarContinuousMark]?
}

