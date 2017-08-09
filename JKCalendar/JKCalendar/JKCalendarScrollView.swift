//
//  JKCalendarScrollView.swift
//  JKCalendar-Sample
//
//  Created by Joe on 2017/5/26.
//  Copyright © 2017年 Joe. All rights reserved.
//

import UIKit

public class JKCalendarScrollView: UIScrollView {

    public let calendar: JKCalendar = JKCalendar(frame: CGRect.zero)
    
    override public var delegate: UIScrollViewDelegate?{
        set{
            _delegate = newValue
        }
        get{
            return _delegate
        }
    }
    
    var _delegate: UIScrollViewDelegate?
    
    private var first = true
    private var rotating = false
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup(){
        super.delegate = self
        calendar.backgroundColor = UIColor.white
        calendar.interactionObject = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layoutSubviewsHandler()
    }
    
    func layoutSubviewsHandler(){
        if first || rotating{
            var calendarSize: CGSize!
            if frame.width > frame.height{
                calendarSize = CGSize(width: frame.width,
                                      height: (frame.width / 2).rounded())
            }else{
                calendarSize = CGSize(width: frame.width,
                                      height: (frame.width / 1.2).rounded())
            }
            
            calendar.frame = CGRect(x: 0,
                                    y: frame.origin.y,
                                    width: calendarSize.width,
                                    height: calendarSize.height)
            contentInset = UIEdgeInsets(top: calendarSize.height,
                                        left: 0,
                                        bottom: 0,
                                        right: 0)
            contentOffset = CGPoint(x: 0, y: -calendarSize.height)
            rotating = false
            
            if first{
                superview?.insertSubview(calendar, aboveSubview: self)
                first = false
            }
        }
    }
    
    func rotated(){
        if !first{
            rotating = true
            layoutSubviewsHandler()
        }
    }
}

extension JKCalendarScrollView: UIScrollViewDelegate{
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _delegate?.scrollViewDidScroll?(scrollView)
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        _delegate?.scrollViewDidZoom?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        _delegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        _delegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        let value = (targetContentOffset.pointee.y + calendar.bounds.height) / calendar.foldMaxValue
        
        if value < 1{
            targetContentOffset.pointee.y = (value > 0.5 ? calendar.foldMaxValue: 0) - calendar.bounds.height
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        _delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        _delegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        _delegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        _delegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return _delegate?.viewForZooming?(in: scrollView)
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        _delegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        _delegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return _delegate?.scrollViewShouldScrollToTop?(scrollView) != nil ? _delegate!.scrollViewShouldScrollToTop!(scrollView): true
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        _delegate?.scrollViewDidScrollToTop?(scrollView)
    }
}
