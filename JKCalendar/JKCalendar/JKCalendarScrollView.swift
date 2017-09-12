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
    
    override public var delegate: UIScrollViewDelegate? {
        set {
            _delegate = newValue
        }

        get {
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
    
    func setup() {
        super.delegate = self
        calendar.interactionObject = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layoutSubviewsHandler()
    }
    
    func layoutSubviewsHandler() {
        if first || rotating{
            var calendarSize: CGSize!
            if frame.width > frame.height {
                calendarSize = CGSize(width: frame.width,
                                      height: (frame.width / 2).rounded())
            } else {
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
    
    @objc
    func rotated() {
        if !first{
            rotating = true
            layoutSubviewsHandler()
        }
    }
}

extension JKCalendarScrollView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if contentOffset.y >= -118.0 { // TODO: Get this value programmatically
            contentOffset.y = -118.0
        }

        var value = calendar.frame.height + contentOffset.y
        if value > calendar.foldMaxValue {
            value = calendar.foldMaxValue
        } else if value < 0 {
            value = 0
        }

        calendar.foldValue = value
        
        _delegate?.scrollViewDidScroll?(scrollView)
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        _delegate?.scrollViewDidZoom?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        _delegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let value = (targetContentOffset.pointee.y + calendar.bounds.height) / calendar.foldMaxValue
        
        if value < 1 {
            targetContentOffset.pointee.y = (value > 0.5 ? calendar.foldMaxValue: 0) - calendar.bounds.height
        }
        
        _delegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
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
