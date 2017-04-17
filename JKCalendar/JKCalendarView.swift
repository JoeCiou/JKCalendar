//
//  JKCalendarView.swift
//  JKCalendar-Sample
//
//  Created by Joe on 2017/3/16.
//  Copyright © 2017年 Joe. All rights reserved.
//

import UIKit

class JKCalendarView: UIView{
    
    let calendar: JKCalendar
    var month: JKMonth{
        didSet{
            setNeedsDisplay()
        }
    }
    
    fileprivate var infos: [JKDayInfo] = []
    fileprivate var panBeganDay: JKDay?
    fileprivate var panChangedDay: JKDay?
    
    var tapRecognizer: UITapGestureRecognizer!
    var panRecognizer: UIPanGestureRecognizer!
    
    init(calendar: JKCalendar, month: JKMonth){
        self.calendar = calendar
        self.month = month
        super.init(frame: CGRect.zero)
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        gestureRecognizers = [tapRecognizer, panRecognizer]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        infos = []
        let context = UIGraphicsGetCurrentContext()
        
        let firstDay = month.firstDay
        let week = firstDay.date.week - 1
        var offset = firstDay.previous(week)
        
        let calendarDaySize = CGSize(width: (bounds.width - 20) / 7, height: (bounds.height - 10) / 6)
        let continuousMarks = calendar.dataSource?.calendar?(calendar, continuousMarksWith: month)
        
        for weekIndex in 0 ..< 6{
            for dayIndex in 0 ..< 7{
                let dayRect = CGRect(x: 10 + CGFloat(dayIndex) * calendarDaySize.width,
                                     y: 5 + CGFloat(weekIndex) * calendarDaySize.height,
                                     width: calendarDaySize.width,
                                     height: calendarDaySize.height)
                var info = JKDayInfo(day: offset,
                                     location: dayRect)
                if let mark = calendar.dataSource?.calendar?(calendar, markWith: info.day){
                    info.mark = mark
                }
                if let continuousMarks = continuousMarks{
                    for continuousMark in continuousMarks{
                        if continuousMark.days.contains(offset){
                            if info.continuousMarks == nil{
                                info.continuousMarks = [continuousMark]
                            }else{
                                info.continuousMarks?.append(continuousMark)
                            }
                        }
                    }
                }
                
                infos.append(info)
                
                offset = offset.next()
            }
        }
        
        var continuousMarksPaths: [JKCalendarContinuousMark: [UIBezierPath]] = [:]
        
        if let continuousMarks = continuousMarks{
            for continuousMark in continuousMarks{
                var infoIndex = 0
                continuousMarksPaths[continuousMark] = []
                
                var markInfos: [JKContinuousMarkInfo] = []
                
                for info in infos where continuousMark.days.contains(info.day){
                    
                    if markInfos.count <= infoIndex{
                        markInfos.append(JKContinuousMarkInfo())
                    }
                    var markInfo = markInfos[infoIndex]
                    
                    if info.day == continuousMark.start && info.day == continuousMark.end{
                        markInfo.only = true
                    }else if info.day == continuousMark.start{
                        markInfo.begin = true
                    }else if info.day == continuousMark.end{
                        markInfo.end = true
                    }
                    markInfo.locations.append(info.location)
                    
                    markInfos[infoIndex] = markInfo
                    
                    if info.day.week == 7{
                        infoIndex += 1
                    }
                }
                
                for info in markInfos{
                    let path = UIBezierPath()
                    let beginLocation = info.locations[0]
                    let endLocation = info.locations.last!
                    switch continuousMark.type{
                        
                    case .circle:
                        let height = beginLocation.height * 5 / 6
                        let radius = height / 2
                        if info.only{
                            let center = CGPoint(x: beginLocation.origin.x + beginLocation.width / 2,
                                                 y: beginLocation.origin.y + beginLocation.height / 2)
                            path.addArc(withCenter: center,
                                        radius: radius,
                                        startAngle: 0,
                                        endAngle: 2 * CGFloat(M_PI), clockwise: true)
                        }else if info.begin && info.end{
                            let rect = CGRect(x: beginLocation.origin.x + beginLocation.width / 2,
                                              y: beginLocation.origin.y + (beginLocation.height - height) / 2,
                                              width: endLocation.origin.x + endLocation.width / 2 - beginLocation.origin.x - beginLocation.width / 2,
                                              height: height)
                            let leftCenter = CGPoint(x: beginLocation.origin.x + beginLocation.width / 2,
                                                     y: beginLocation.origin.y + beginLocation.height / 2)
                            let rightCenter = CGPoint(x: endLocation.origin.x + endLocation.width / 2,
                                                      y: endLocation.origin.y + endLocation.height / 2)
                            
                            path.addArc(withCenter: leftCenter,
                                        radius: radius,
                                        startAngle: 90 * CGFloat(M_PI) / 180,
                                        endAngle: 270 * CGFloat(M_PI) / 180,
                                        clockwise: true)
                            path.addLine(to: CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y))
                            path.addArc(withCenter: rightCenter,
                                        radius: radius,
                                        startAngle: 270 * CGFloat(M_PI) / 180,
                                        endAngle: 90 * CGFloat(M_PI) / 180,
                                        clockwise: true)
                            path.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.height))
                            
                        }else if info.begin{
                            let rect = CGRect(x: beginLocation.origin.x + beginLocation.width / 2,
                                              y: beginLocation.origin.y + (beginLocation.height - height) / 2,
                                              width: endLocation.origin.x + endLocation.width - beginLocation.origin.x - beginLocation.width / 2,
                                              height: height)
                            let leftCenter = CGPoint(x: beginLocation.origin.x + beginLocation.width / 2,
                                                     y: beginLocation.origin.y + beginLocation.height / 2)
                            
                            path.move(to: CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y + rect.height))
                            path.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.height))
                            path.addArc(withCenter: leftCenter,
                                        radius: radius,
                                        startAngle: 90 * CGFloat(M_PI) / 180,
                                        endAngle: 270 * CGFloat(M_PI) / 180,
                                        clockwise: true)
                            path.addLine(to: CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y))
                            
                        }else if info.end{
                            let rect = CGRect(x: beginLocation.origin.x,
                                              y: beginLocation.origin.y + (beginLocation.height - height) / 2,
                                              width: endLocation.origin.x + endLocation.width / 2 - beginLocation.origin.x,
                                              height: height)
                            let rightCenter = CGPoint(x: endLocation.origin.x + endLocation.width / 2,
                                                      y: endLocation.origin.y + endLocation.height / 2)
                            
                            path.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
                            path.addLine(to: CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y))
                            path.addArc(withCenter: rightCenter,
                                        radius: radius,
                                        startAngle: 270 * CGFloat(M_PI) / 180,
                                        endAngle: 90 * CGFloat(M_PI) / 180,
                                        clockwise: true)
                            path.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.height))
                            
                        }else{
                            let rect = CGRect(x: beginLocation.origin.x,
                                              y: beginLocation.origin.y + (beginLocation.height - height) / 2,
                                              width: endLocation.origin.x + endLocation.width - beginLocation.origin.x,
                                              height: height)
                            
                            path.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
                            path.addLine(to: CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y))
                            path.addLine(to: CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y + rect.height))
                            path.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.height))
                        }
                        
                        path.close()
                        context?.addPath(path.cgPath)
                        context?.setFillColor(continuousMark.color.cgColor)
                        context?.fillPath()
                        
                    case .hollowCircle:
                        let height = beginLocation.height * 5 / 6
                        let radius = height / 2
                        if info.only{
                            let center = CGPoint(x: beginLocation.origin.x + beginLocation.width / 2,
                                                 y: beginLocation.origin.y + beginLocation.height / 2)
                            path.addArc(withCenter: center,
                                        radius: radius,
                                        startAngle: 0,
                                        endAngle: 2 * CGFloat(M_PI), clockwise: true)
                        }else if info.begin && info.end{
                            let rect = CGRect(x: beginLocation.origin.x + beginLocation.width / 2,
                                              y: beginLocation.origin.y + (beginLocation.height - height) / 2,
                                              width: endLocation.origin.x + endLocation.width / 2 - beginLocation.origin.x - beginLocation.width / 2,
                                              height: height)
                            let leftCenter = CGPoint(x: beginLocation.origin.x + beginLocation.width / 2,
                                                     y: beginLocation.origin.y + beginLocation.height / 2)
                            let rightCenter = CGPoint(x: endLocation.origin.x + endLocation.width / 2,
                                                      y: endLocation.origin.y + endLocation.height / 2)
                            
                            path.addArc(withCenter: leftCenter,
                                        radius: radius,
                                        startAngle: 90 * CGFloat(M_PI) / 180,
                                        endAngle: 270 * CGFloat(M_PI) / 180,
                                        clockwise: true)
                            path.addLine(to: CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y))
                            path.addArc(withCenter: rightCenter,
                                        radius: radius,
                                        startAngle: 270 * CGFloat(M_PI) / 180,
                                        endAngle: 90 * CGFloat(M_PI) / 180,
                                        clockwise: true)
                            path.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.height))
                            
                        }else if info.begin{
                            let rect = CGRect(x: beginLocation.origin.x + beginLocation.width / 2,
                                              y: beginLocation.origin.y + (beginLocation.height - height) / 2,
                                              width: endLocation.origin.x + endLocation.width - beginLocation.origin.x - beginLocation.width / 2,
                                              height: height)
                            let leftCenter = CGPoint(x: beginLocation.origin.x + beginLocation.width / 2,
                                                     y: beginLocation.origin.y + beginLocation.height / 2)
                            
                            path.move(to: CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y + rect.height))
                            path.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.height))
                            path.addArc(withCenter: leftCenter,
                                        radius: radius,
                                        startAngle: 90 * CGFloat(M_PI) / 180,
                                        endAngle: 270 * CGFloat(M_PI) / 180,
                                        clockwise: true)
                            path.addLine(to: CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y))
                            
                        }else if info.end{
                            let rect = CGRect(x: beginLocation.origin.x,
                                              y: beginLocation.origin.y + (beginLocation.height - height) / 2,
                                              width: endLocation.origin.x + endLocation.width / 2 - beginLocation.origin.x,
                                              height: height)
                            let rightCenter = CGPoint(x: endLocation.origin.x + endLocation.width / 2,
                                                      y: endLocation.origin.y + endLocation.height / 2)
                            
                            path.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
                            path.addLine(to: CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y))
                            path.addArc(withCenter: rightCenter,
                                        radius: radius,
                                        startAngle: 270 * CGFloat(M_PI) / 180,
                                        endAngle: 90 * CGFloat(M_PI) / 180,
                                        clockwise: true)
                            path.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.height))
                            
                        }else{
                            let rect = CGRect(x: beginLocation.origin.x,
                                              y: beginLocation.origin.y + (beginLocation.height - height) / 2,
                                              width: endLocation.origin.x + endLocation.width - beginLocation.origin.x,
                                              height: height)
                            
                            path.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
                            path.addLine(to: CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y))
                            path.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.height))
                            path.addLine(to: CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y + rect.height))
                        }
                        
                        context?.addPath(path.cgPath)
                        context?.setLineWidth(1)
                        context?.setStrokeColor(continuousMark.color.cgColor)
                        context?.strokePath()
                        
                    case .underline:
                        let offsetY = beginLocation.origin.y + beginLocation.height - 2
                        let lineWidth = beginLocation.height * 3 / 4
                        if info.only{
                            let beginX = beginLocation.origin.x + (beginLocation.width - lineWidth) / 2
                            let endX = beginX + lineWidth
                            path.move(to: CGPoint(x: beginX, y: offsetY))
                            path.addLine(to: CGPoint(x: endX, y: offsetY))
                            
                        }else if info.begin && info.end{
                            let beginX = beginLocation.origin.x + (beginLocation.width - lineWidth) / 2
                            let endX = endLocation.origin.x + (endLocation.width - lineWidth) / 2 + lineWidth
                            path.move(to: CGPoint(x: beginX, y: offsetY))
                            path.addLine(to: CGPoint(x: endX, y: offsetY))
                            
                        }else if info.begin{
                            let beginX = beginLocation.origin.x + (beginLocation.width - lineWidth) / 2
                            let endX = endLocation.origin.x + endLocation.width
                            path.move(to: CGPoint(x: beginX, y: offsetY))
                            path.addLine(to: CGPoint(x: endX, y: offsetY))
                            
                        }else if info.end{
                            let beginX = beginLocation.origin.x
                            let endX = endLocation.origin.x + (endLocation.width - lineWidth) / 2 + lineWidth
                            path.move(to: CGPoint(x: beginX, y: offsetY))
                            path.addLine(to: CGPoint(x: endX, y: offsetY))
                            
                        }else{
                            let beginX = beginLocation.origin.x
                            let endX = endLocation.origin.x + endLocation.width
                            path.move(to: CGPoint(x: beginX, y: offsetY))
                            path.addLine(to: CGPoint(x: endX, y: offsetY))
                            
                        }
                        
                        context?.addPath(path.cgPath)
                        context?.setLineWidth(2)
                        context?.setStrokeColor(continuousMark.color.cgColor)
                        context?.strokePath()
                        
                    case .dot:
                        let offsetY = beginLocation.origin.y + beginLocation.height - 2
                        let radius: CGFloat = 2
                        if info.only{
                            let center = CGPoint(x: beginLocation.origin.x + beginLocation.width / 2,
                                                 y: offsetY)
                            path.addArc(withCenter: center,
                                        radius: radius,
                                        startAngle: CGFloat(M_PI),
                                        endAngle: 3 * CGFloat(M_PI),
                                        clockwise: true)
                            
                        }else if info.begin && info.end{
                            let leftCenter = CGPoint(x: beginLocation.origin.x + beginLocation.width / 2,
                                                     y: offsetY)
                            let rightCenter = CGPoint(x: endLocation.origin.x + endLocation.width / 2,
                                                      y: offsetY)
                            
                            path.addArc(withCenter: leftCenter,
                                        radius: radius,
                                        startAngle: CGFloat(M_PI),
                                        endAngle: 3 * CGFloat(M_PI),
                                        clockwise: true)
                            path.addLine(to: CGPoint(x: rightCenter.x - 2, y: rightCenter.y))
                            path.addArc(withCenter: rightCenter,
                                        radius: radius,
                                        startAngle: 0,
                                        endAngle: 2 * CGFloat(M_PI),
                                        clockwise: true)
                            
                        }else if info.begin{
                            let leftCenter = CGPoint(x: beginLocation.origin.x + beginLocation.width / 2,
                                                     y: offsetY)
                            
                            path.addArc(withCenter: leftCenter,
                                        radius: radius,
                                        startAngle: CGFloat(M_PI),
                                        endAngle: 3 * CGFloat(M_PI),
                                        clockwise: true)
                            path.addLine(to: CGPoint(x: endLocation.origin.x + endLocation.width, y: offsetY))
                            
                        }else if info.end{
                            let rightCenter = CGPoint(x: endLocation.origin.x + endLocation.width / 2,
                                                      y: offsetY)
                            
                            path.move(to: CGPoint(x: beginLocation.origin.x, y: offsetY))
                            path.addLine(to: CGPoint(x: rightCenter.x - 2, y: rightCenter.y))
                            path.addArc(withCenter: rightCenter,
                                        radius: radius,
                                        startAngle: 0,
                                        endAngle: 2 * CGFloat(M_PI),
                                        clockwise: true)
                        }else{
                            path.move(to: CGPoint(x: beginLocation.origin.x, y: offsetY))
                            path.addLine(to: CGPoint(x: endLocation.origin.x + endLocation.width, y: offsetY))
                        }
                        
                        context?.addPath(path.cgPath)
                        context?.setLineWidth(1)
                        context?.setStrokeColor(continuousMark.color.cgColor)
                        context?.strokePath()
                        
                        context?.addPath(path.cgPath)
                        context?.setFillColor(continuousMark.color.cgColor)
                        context?.fillPath()
                    }
                }
            }
            
        }
        
        // Draw mark
        for info in infos{
            if let mark = info.mark{
                switch mark.type{
                case .circle:
                    context?.setFillColor(mark.color.withAlphaComponent(alpha).cgColor)
                    let diameter = info.location.height * 5 / 6
                    let rect = CGRect(x: info.location.origin.x + (info.location.width - diameter) / 2,
                                      y: info.location.origin.y + (info.location.height - diameter) / 2,
                                      width: diameter,
                                      height: diameter)
                    context?.addEllipse(in: rect)
                    context?.fillPath()
                case .hollowCircle:
                    context?.setLineWidth(1)
                    context?.setStrokeColor(mark.color.withAlphaComponent(alpha).cgColor)
                    let diameter = info.location.height * 5 / 6
                    let rect = CGRect(x: info.location.origin.x + (info.location.width - diameter) / 2,
                                      y: info.location.origin.y + (info.location.height - diameter) / 2,
                                      width: diameter,
                                      height: diameter)
                    context?.addEllipse(in: rect)
                    context?.strokePath()
                case .underline:
                    context?.setLineWidth(2)
                    context?.setStrokeColor(mark.color.withAlphaComponent(alpha).cgColor)
                    let width = info.location.height * 3 / 4
                    let offsetY = info.location.height - 2
                    let startPoint = CGPoint(x: info.location.origin.x + (info.location.width - width) / 2,
                                             y: info.location.origin.y + offsetY)
                    let endPoint = CGPoint(x: info.location.origin.x + (info.location.width - width) / 2 + width,
                                           y: info.location.origin.y + offsetY)
                    context?.addLines(between: [startPoint, endPoint])
                    context?.strokePath()
                case .dot:
                    let context = UIGraphicsGetCurrentContext()
                    context?.setFillColor(mark.color.withAlphaComponent(alpha).cgColor)
                    let diameter: CGFloat = 4
                    let offsetY = info.location.height - 4
                    let rect = CGRect(x: info.location.origin.x + (info.location.width - diameter) / 2,
                                      y: info.location.origin.y + offsetY,
                                      width: diameter,
                                      height: diameter)
                    context?.addEllipse(in: rect)
                    context?.fillPath()
                }
            }
            
        }
        
        // Draw Text
        for info in infos{
            let dayString = "\(info.day.day)" as NSString
            let font = UIFont(name: "HelveticaNeue-Medium", size: 13)!
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            var unitStrAttrs = [NSFontAttributeName: font,
                                NSParagraphStyleAttributeName: paragraphStyle]
            
            if let mark = info.mark, mark.type == .circle{
                unitStrAttrs[NSForegroundColorAttributeName] = calendar.backgroundColor
            }else if let continuousMarks = info.continuousMarks,
                continuousMarks.contains(where: { return $0.type == .circle }){
                unitStrAttrs[NSForegroundColorAttributeName] = calendar.backgroundColor
            }else if info.day == month{
                unitStrAttrs[NSForegroundColorAttributeName] = calendar.textColor
            }else{
                unitStrAttrs[NSForegroundColorAttributeName] = calendar.textColor.withAlphaComponent(0.3)
            }
            
            let textSize = dayString.size(attributes: [NSFontAttributeName: font])
            let dy = (calendarDaySize.height - textSize.height) / 2
            
            let textRect = CGRect(x: info.location.origin.x,
                                  y: info.location.origin.y + dy,
                                  width: calendarDaySize.width,
                                  height: textSize.height)
            dayString.draw(in: textRect, withAttributes: unitStrAttrs)
        }
    
    }
    
    func handleTap(_ recognizer: UITapGestureRecognizer){
        let point = recognizer.location(in: self)
        if let info = infos.first(where: { (info) -> Bool in
            if point.x > info.location.origin.x &&
                point.x < info.location.origin.x + info.location.width &&
                point.y > info.location.origin.y &&
                point.y < info.location.origin.y + info.location.height{
                return true
            }else{
                return false
            }
        }){
            calendar.delegate?.calendar?(calendar, didTouch: info.day)
        }
    }
    
    func handlePan(_ recognizer: UIPanGestureRecognizer){
        let point = recognizer.location(in: self)
        if let info = infos.first(where: { (info) -> Bool in
            if point.x > info.location.origin.x &&
                point.x < info.location.origin.x + info.location.width &&
                point.y > info.location.origin.y &&
                point.y < info.location.origin.y + info.location.height{
                return true
            }else{
                return false
            }
        }){
            switch recognizer.state {
            case .began:
                calendar.delegate?.calendar?(calendar, didPan: [info.day])
                panBeganDay = info.day
                panChangedDay = info.day
            case .changed:
                if let changedDay = panChangedDay, changedDay == info.day{
                }else if let beganDay = panBeganDay{
                    calendar.delegate?.calendar?(calendar, didPan: beganDay.days(until: info.day))
                }
                panChangedDay = info.day
            case .ended:
                panBeganDay = nil
                panChangedDay = nil
            default:
                break
            }
        }
    }
    
    struct JKDayInfo {
        let day: JKDay
        let location: CGRect
        
        var mark: JKCalendarMark?
        var continuousMarks: [JKCalendarContinuousMark]?
        
        init(day: JKDay, location: CGRect){
            self.day = day
            self.location = location
        }
        
    }
    
    struct JKContinuousMarkInfo {
        var locations: [CGRect] = []
        var only: Bool = false
        var begin: Bool = false
        var end: Bool = false
        
        init(){
            
        }
    }
    
    /*
     func setup(){
     var verticalConstraintsFormat = "V:|"
     var views: [String: UIView] = [:]
     
     for index in 0 ..< 6{
     let calendarWeek = JKCalendarWeek()
     calendarWeek.translatesAutoresizingMaskIntoConstraints = false
     calendarWeeks.append(calendarWeek)
     addSubview(calendarWeek)
     
     DispatchQueue.global().async {
     let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[calendarWeek]|", options: .directionLeadingToTrailing, metrics: nil, views: ["calendarWeek": calendarWeek])
     DispatchQueue.main.async {
     self.addConstraints(horizontalConstraints)
     }
     }
     
     let viewName = "calendarWeek\(index)"
     verticalConstraintsFormat += "[\(viewName)]"
     views[viewName] = calendarWeek
     }
     verticalConstraintsFormat += "|"
     
     DispatchQueue.global().async {
     let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: verticalConstraintsFormat, options: .directionLeadingToTrailing, metrics: nil, views: views)
     DispatchQueue.main.async {
     self.addConstraints(verticalConstraints)
     }
     }
     
     }
     
     func loadCalendar(){
     //        weekViewHeight = weekViews[0].frame.height
     //        moveHeight = dateView.frame.height - weekViewHeight
     
     //        monthLabel.text = monthName(month: month.month)
     
     var offsetDate = month.fristDay.date
     var offsetComponents = DateComponents(day: -offsetDate.week - 1)
     
     let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
     offsetDate = calendar.date(byAdding: offsetComponents, to: offsetDate)!
     offsetComponents.day = 1
     
     for calendarWeek in calendarWeeks{
     for calendarDay in calendarWeek.calendarDays{
     
     let day = JKDay(date: offsetDate)!
     calendarDay.day = day
     calendarDay.enable = day == month
     
     //                if let markDays = monthMarkDays{
     //                    day.mark = markDays.contains(dayStr)
     //                }
     
     //                day.select = isSameDate(date!, ForDate: selectDate)
     //                if day.select{
     //                    selectDay = day
     //                    displayRow = dayViews.index(of: day)!/7
     //                    //                selectRow = dayViews.indexOf(day)!/7
     //                }
     
     //                dateFormatter.dateFormat = "Y-M"
     //                let isCurrentMonth = dateFormatter.string(from: date!) == identifier
     //                day.showDayStatus(isCurrentMonth)
     
     //                if !isCurrentMonth && dayStr == "1"{
     //                    let index = dayViews.index(of: day)!
     //                    nextMonthRow = index/7
     //                    if index == 35 || index == 28{
     //                        nextMonthRow -= 1
     //                    }
     //                }
     
     //                day.clickClosures = calendarDayClick
     
     offsetDate = calendar.date(byAdding: offsetComponents, to: offsetDate)!
     }
     }
     }
     */
    
}
