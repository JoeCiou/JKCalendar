//
//  JKInfinitePageView.swift
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

private let reuseIdentifier = "InfinitePageCell"

public enum JKInfinitePageViewScrollDirection: Int {
    case vertical
    case horizontal
}

class JKInfinitePageCell: UICollectionViewCell {
    var pageView: UIView?{
        didSet{
            if let view = pageView{
                for subview in subviews{
                    subview.removeFromSuperview()
                }
                view.translatesAutoresizingMaskIntoConstraints = false
                addSubview(view)
                
                let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                  options: .directionLeadingToTrailing,
                                                                  metrics: nil,
                                                                  views: ["view": view])
                let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                  options: .directionLeadingToTrailing,
                                                                  metrics: nil,
                                                                  views: ["view": view])
                addConstraints(hConstraints)
                addConstraints(vConstraints)
            }
        }
    }
    
}

public class JKInfinitePageView: UIView {
    
    public private(set) var currentView: UIView?
    public weak var delegate: JKInfinitePageViewDelegate?
    public weak var dataSource: JKInfinitePageViewDataSource?

    fileprivate var collectionView: UICollectionView!
    fileprivate var currentIndexPath: IndexPath = IndexPath(item: Int(Int16.max/2), section: 0)
    fileprivate var willDisplayIndexPath: IndexPath!
    
    open var isScrollEnabled: Bool = true{
        didSet{
            collectionView.isScrollEnabled = isScrollEnabled
        }
    }
    
    open var scrollDirection: JKInfinitePageViewScrollDirection = .horizontal{
        didSet{
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.scrollDirection = scrollDirection == .horizontal ? .horizontal: .vertical
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = scrollDirection == .horizontal ? .horizontal: .vertical
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(JKInfinitePageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|",
                                                          options: .directionLeadingToTrailing,
                                                          metrics: nil,
                                                          views: ["collectionView": collectionView])
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|",
                                                          options: .directionLeadingToTrailing,
                                                          metrics: nil,
                                                          views: ["collectionView": collectionView])
        addConstraints(hConstraints)
        addConstraints(vConstraints)
    
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.itemSize = bounds.size
        flowLayout.invalidateLayout()
        
        layoutIfNeeded()
        collectionView.setContentOffset(CGPoint(x: CGFloat(currentIndexPath.item) * bounds.width, y: 0), animated: false)
        
        flowLayout.invalidateLayout()
    }
    
    public func setView(_ view: UIView) {
        currentView = view
        collectionView.reloadData()
    }
    
    public func nextPage() {
        let index = currentIndexPath.item + 1
        collectionView.setContentOffset(CGPoint(x: CGFloat(index) * bounds.width, y: 0), animated: true)
    }
    
    public func previousPage() {
        let index = currentIndexPath.item - 1
        collectionView.setContentOffset(CGPoint(x: CGFloat(index) * bounds.width, y: 0), animated: true)
    }
}

extension JKInfinitePageView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let view = currentView{
            let cell = cell as! JKInfinitePageCell
            if indexPath.item > currentIndexPath.item{
                cell.pageView = dataSource?.infinitePageView?(self, viewAfter: view)
            }else if indexPath.item < self.currentIndexPath.item{
                cell.pageView = dataSource?.infinitePageView?(self, viewBefore: view)
            }else{
                cell.pageView = view
            }
            willDisplayIndexPath = indexPath
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if willDisplayIndexPath.item > indexPath.item{ // 往右翻
            currentIndexPath = willDisplayIndexPath
            currentView = (collectionView.cellForItem(at: currentIndexPath) as? JKInfinitePageCell)?.pageView
        }else if willDisplayIndexPath.item < indexPath.item{ // 往左翻
            currentIndexPath = willDisplayIndexPath
            currentView = (collectionView.cellForItem(at: currentIndexPath) as? JKInfinitePageCell)?.pageView
        }else{ // 沒翻
            willDisplayIndexPath = currentIndexPath
        }
        
        if let view = currentView{
            delegate?.infinitePageView?(self, didDisplay: view)
        }
    }
 
}

extension JKInfinitePageView: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(Int16.max)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! JKInfinitePageCell
        return cell
    }

}

extension JKInfinitePageView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if willDisplayIndexPath != nil{
            if let view = (collectionView.cellForItem(at: willDisplayIndexPath!) as? JKInfinitePageCell)?.pageView{
                if willDisplayIndexPath.item > currentIndexPath.item{
                    let progress = Double((scrollView.contentOffset.x - CGFloat(currentIndexPath.item) * bounds.width) / bounds.width)
                    delegate?.infinitePageView?(self, afterWith: view, progress: progress > 1 ? 1: progress)
                }else if willDisplayIndexPath.item < currentIndexPath.item{
                    let progress = Double((CGFloat(currentIndexPath.item) * bounds.width - scrollView.contentOffset.x) / bounds.width)
                    delegate?.infinitePageView?(self, beforeWith: view, progress: progress > 1 ? 1: progress)
                }
            }
        }
    }
}

@objc public protocol JKInfinitePageViewDelegate {
    @objc optional func infinitePageView(_ infinitePageView: JKInfinitePageView, didDisplay view: UIView)
    
    @objc optional func infinitePageView(_ infinitePageView: JKInfinitePageView, beforeWith view: UIView, progress: Double)
    
    @objc optional func infinitePageView(_ infinitePageView: JKInfinitePageView, afterWith view: UIView, progress: Double)
}

@objc public protocol JKInfinitePageViewDataSource {
    @objc optional func infinitePageView(_ infinitePageView: JKInfinitePageView, viewBefore view: UIView) -> UIView
    
    @objc optional func infinitePageView(_ infinitePageView: JKInfinitePageView, viewAfter view: UIView) -> UIView
}


