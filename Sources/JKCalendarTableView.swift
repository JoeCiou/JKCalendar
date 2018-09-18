//
//  JKCalendarTableView.swift
//  JKCalendar
//
//  Created by Joe on 2017/9/7.
//  Copyright © 2017年 Joe. All rights reserved.
//

import UIKit

open class JKCalendarTableView: UITableView {
    
    public let calendar: JKCalendar = JKCalendar(frame: CGRect.zero)
    
    override open var delegate: UITableViewDelegate?{
        set{
            _delegate = newValue
        }
        get{
            return _delegate
        }
    }
    
    var _delegate: UITableViewDelegate?
    
    private var first = true
    private var rotating = false
    
    override public init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        layoutSubviewsHandler()
    }
    
    func layoutSubviewsHandler(){
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
            
            if first{
                superview?.insertSubview(calendar, aboveSubview: self)
                first = false
            }
        }
    }
    
    @objc
    func rotated(){
        if !first{
            rotating = true
            layoutSubviewsHandler()
        }
    }

}

extension JKCalendarTableView: UITableViewDelegate{
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        var value = calendar.frame.height + contentOffset.y
        if value > calendar.collapsedMaximum {
            value = calendar.collapsedMaximum
        }else if value < 0{
            value = 0
        }
        
        calendar.collapsedValue = value
        
        _delegate?.scrollViewDidScroll?(scrollView)
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        _delegate?.scrollViewDidZoom?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        _delegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let value = (targetContentOffset.pointee.y + calendar.bounds.height) / calendar.collapsedMaximum
        
        if value < 1{
            targetContentOffset.pointee.y = (value > 0.5 ? calendar.collapsedMaximum: 0) - calendar.bounds.height
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
    
    // MARK: Table View Delegate
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        _delegate?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        _delegate?.tableView?(tableView, willDisplayHeaderView: view, forSection: section)
    }
    
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int){
        _delegate?.tableView?(tableView, willDisplayFooterView: view, forSection: section)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath){
        _delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int){
        _delegate?.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int){
        _delegate?.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return _delegate?.tableView?(tableView, heightForRowAt: indexPath) ?? tableView.rowHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return _delegate?.tableView?(tableView, heightForHeaderInSection: section) ?? tableView.sectionHeaderHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return _delegate?.tableView?(tableView, heightForFooterInSection: section) ?? tableView.sectionFooterHeight
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat{
        return _delegate?.tableView?(tableView, estimatedHeightForRowAt: indexPath) ?? tableView.estimatedRowHeight
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat{
        return _delegate?.tableView?(tableView, estimatedHeightForHeaderInSection: section) ?? tableView.estimatedSectionHeaderHeight
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat{
        return _delegate?.tableView?(tableView, estimatedHeightForFooterInSection: section) ?? tableView.estimatedSectionFooterHeight
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        return _delegate?.tableView?(tableView, viewForHeaderInSection: section) ?? tableView.tableHeaderView
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?{
        return _delegate?.tableView?(tableView, viewForFooterInSection: section) ?? tableView.tableFooterView
    }
    
    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath){
        _delegate?.tableView?(tableView, accessoryButtonTappedForRowWith: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool{
        return _delegate?.tableView?(tableView, shouldHighlightRowAt: indexPath) ?? true
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath){
        _delegate?.tableView?(tableView, didHighlightRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath){
        _delegate?.tableView?(tableView, didUnhighlightRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?{
        return _delegate?.tableView?(tableView, willSelectRowAt: indexPath) ?? nil
    }
    
    public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath?{
        return _delegate?.tableView?(tableView, willDeselectRowAt: indexPath) ?? nil
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        _delegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        _delegate?.tableView?(tableView, didDeselectRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle{
        return _delegate?.tableView?(tableView, editingStyleForRowAt: indexPath) ?? (tableView.isEditing ? .delete: .none)
    }
    
    public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?{
        return _delegate?.tableView?(tableView, titleForDeleteConfirmationButtonForRowAt: indexPath) ?? nil
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        return _delegate?.tableView?(tableView, editActionsForRowAt: indexPath) ?? nil
    }
    
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool{
        return _delegate?.tableView?(tableView, shouldIndentWhileEditingRowAt: indexPath) ?? true
    }
    
    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath){
        _delegate?.tableView?(tableView, willBeginEditingRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?){
        _delegate?.tableView?(tableView, didEndEditingRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath{
        return _delegate?.tableView?(tableView, targetIndexPathForMoveFromRowAt: sourceIndexPath, toProposedIndexPath: proposedDestinationIndexPath) ?? proposedDestinationIndexPath
    }
    
    public func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int{
        return _delegate?.tableView?(tableView, indentationLevelForRowAt: indexPath) ?? 0
    }
    
    public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool{
        return _delegate?.tableView?(tableView, shouldShowMenuForRowAt: indexPath) ?? false
    }
    
    public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool{
        return _delegate?.tableView?(tableView, canPerformAction: action, forRowAt: indexPath, withSender: sender) ?? false
    }
    
    public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?){
        _delegate?.tableView?(tableView, performAction: action, forRowAt: indexPath, withSender: sender)
    }
    
    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool{
        return _delegate?.tableView?(tableView, canFocusRowAt: indexPath) ?? false
    }
    
    public func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool{
        return _delegate?.tableView?(tableView, shouldUpdateFocusIn: context) ?? false
    }
    
    public func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator){
        _delegate?.tableView?(tableView, didUpdateFocusIn: context, with: coordinator)
    }
    
    public func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath?{
        return _delegate?.indexPathForPreferredFocusedView?(in: tableView) ?? nil
    }
}
