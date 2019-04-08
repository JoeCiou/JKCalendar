//
//  JKCalendarScrollView.swift
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

public class JKCalendarScrollView: UIScrollView {
    
    public let calendar: JKCalendar = JKCalendar(frame: CGRect.zero)
    public weak var nativeDelegate: UIScrollViewDelegate?
    
    public var startsCollapsed: Bool = false
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
    
    func setup() {
        super.delegate = self
        calendar.interactionObject = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        layoutSubviewsHandler()
    }
    
    func layoutSubviewsHandler() {
        if first || rotating{
            var calendarSize: CGSize!
            let footerHeight = calendar.delegate?.heightOfFooterView?(in: calendar) ?? 0
            if frame.width > frame.height {
                let height = ((calendar.isTopViewDisplayed ? calendar.topView.frame.height: 0) + calendar.weekView.frame.height + frame.width * 0.35 + footerHeight).rounded()
                calendarSize = CGSize(width: frame.width,
                                      height: height)
            } else {
                let height = ((calendar.isTopViewDisplayed ? calendar.topView.frame.height: 0) + calendar.weekView.frame.height + frame.width * 0.65 + footerHeight).rounded()
                calendarSize = CGSize(width: frame.width,
                                      height: height)
            }
            
            calendar.frame = CGRect(x: 0,
                                    y: frame.origin.y,
                                    width: calendarSize.width,
                                    height: calendarSize.height)

            contentInset = UIEdgeInsets(top: calendarSize.height,
                                        left: 0,
                                        bottom: 0,
                                        right: 0)
            
            scrollIndicatorInsets = UIEdgeInsets(top: calendarSize.height,
                                                 left: 0,
                                                 bottom: 0,
                                                 right: 0)

            contentOffset = CGPoint(x: 0, y: -calendarSize.height)
            rotating = false
            
            if first {
                superview?.insertSubview(calendar, aboveSubview: self)
                first = false
            }
        }
    }
    
    @objc
    func rotated() {
        if !first {
            rotating = true
            layoutSubviewsHandler()
        }
    }
}

extension JKCalendarScrollView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        var value = calendar.frame.height + contentOffset.y
        if value > calendar.collapsedMaximum {
            value = calendar.collapsedMaximum
        } else if value < 0 {
            value = 0
        }

        calendar.collapsedValue = value
        
        nativeDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        nativeDelegate?.scrollViewDidZoom?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        nativeDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let value = (targetContentOffset.pointee.y + calendar.bounds.height) / calendar.collapsedMaximum
        
        if value < 1 {
            targetContentOffset.pointee.y = (value > 0.5 ? calendar.collapsedMaximum : 0) - calendar.bounds.height
        }
        
        nativeDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        nativeDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        nativeDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        nativeDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        nativeDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nativeDelegate?.viewForZooming?(in: scrollView)
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        nativeDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        nativeDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return nativeDelegate?.scrollViewShouldScrollToTop?(scrollView) != nil ? nativeDelegate!.scrollViewShouldScrollToTop!(scrollView): true
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        nativeDelegate?.scrollViewDidScrollToTop?(scrollView)
    }
}
