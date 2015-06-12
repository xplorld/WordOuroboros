//
//  SlidableView.swift
//  WordOuroboros
//
//  Created by Xplorld on 2015/6/10.
//  Copyright (c) 2015年 Xplorld. All rights reserved.
//

import UIKit

protocol SlidableViewDelegate : class {
    func viewOfDirection(direction:PanGestureDirection,slidableView:SlidableView,currentView:UIView) -> UIView?
}
class SlidableView: UIScrollView {
    /*
    * a slidable view is a paged view that can go up,down,left,right.
    layout:
    *upView*
    *leftView*   *currentView*   *rightView*
    *downView*
    */
    weak var slidableViewDelegate:SlidableViewDelegate?
    private var currentView:UIView! {
        didSet {
            
            oldValue?.removeFromSuperview()
            currentView.removeFromSuperview()
            self.addSubview(currentView)
            
            currentView.frame.origin = CGPointZero
            self.contentSize = currentView.frame.size
            self.contentOffset = CGPointZero
        }
    }
    private var nextView:UIView? {
        didSet {
            if let view = nextView {
                view.removeFromSuperview()
                self.addSubview(view)
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customSettings()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customSettings()
    }
    init() {
        super.init(frame:CGRectZero)
        self.customSettings()
    }
    private func customSettings() {
        self.pagingEnabled = true
        self.scrollsToTop = false
        
        self.alwaysBounceHorizontal = true
        self.alwaysBounceVertical = true
        
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.clipsToBounds = true
        self.delegate = self
    }
    
    var scrollStartPoint:CGPoint = CGPointZero
    var directionLocked:Bool = false
    
    //reuse machaism
    var unusedQueue:[UIView] = []
    var queueViewMaker:((SlidableView)->UIView) = {_ in UIView()}
    func dequeueView() -> UIView {
        
        if unusedQueue.isEmpty {
            let view = queueViewMaker(self)
            return view
        } else {
            return unusedQueue.removeAtIndex(0)
        }
    }
    func registerMaker(maker:(SlidableView)->UIView) {
        queueViewMaker = maker
    }
    
    func setCurrentView(view:UIView) {
        if currentView == nil {
            currentView = view
            return
        }
        
        view.removeFromSuperview()
        view.alpha = 0
        //visible frame
        view.frame = CGRect(origin: contentOffset, size: bounds.size)
        self.addSubview(view)
        UIView.animateWithDuration(0.2, animations: {view.alpha = 1}, completion: {_ in self.currentView = view})
    }
}

extension SlidableView : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.directionLocked {
            let offset = scrollView.contentOffset - self.scrollStartPoint
            let direction = directionFromVelocity(offset)
            if direction == .Up || direction == .Down {
                self.contentOffset.x = scrollStartPoint.x
                
            } else {
                self.contentOffset.y = scrollStartPoint.y
            }
        }
        if nextView != nil {
            if bounds.minX < 0 {
                contentOffset.x = 0
            }
            if bounds.maxX > contentSize.width {
                contentOffset.x = contentSize.width - bounds.width
            }
            if bounds.minY < 0 {
                contentOffset.y = 0
            }
            if bounds.maxY > contentSize.height {
                contentOffset.y = contentSize.height - bounds.height
            }
        }
    }
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        let velocity = scrollView.panGestureRecognizer.velocityInView(scrollView)
        let direction:PanGestureDirection = directionFromVelocity(velocity)
        
        nextView = self.slidableViewDelegate?.viewOfDirection(direction, slidableView: self, currentView: self.currentView)
        
        if let theView = nextView {
            let cw = currentView.frame.size.width
            let ch = currentView.frame.size.height
            let nw = theView.frame.size.width
            let nh = theView.frame.size.height
            
            let w =  cw + 2 * nw
            let h =  ch + 2 * nh
            self.contentSize = CGSize(width: w, height: h)
            
            switch direction {
            case .Up:
                theView.frame.origin = CGPoint(x: nw, y: ch+nh)
            case .Down:
                theView.frame.origin = CGPoint(x: nw, y: 0)
            case .Right:
                theView.frame.origin = CGPoint(x: 0, y: nh)
            case .Left:
                theView.frame.origin = CGPoint(x: cw+nw, y: nh)
            }
            
            let origin = CGPoint(x: nw,y: nh)
            currentView.frame.origin = origin
            self.setContentOffset(origin, animated: false)
            
        } else {
            //no next view
            currentView.frame.origin = CGPointZero
            self.contentSize = currentView.frame.size
            self.setContentOffset(CGPointZero, animated: false)
        }
        
        self.scrollStartPoint = self.contentOffset
        self.directionLocked = true
    }
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            self.scrollEnabled = false
        }else {
            didEndSwiping()
        }
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.scrollEnabled = true
        didEndSwiping()
    }
    func didEndSwiping() {
        self.directionLocked = false
        
        if nextView != nil && self.contentOffset != self.scrollStartPoint {
            unusedQueue.append(currentView)
            currentView = nextView
            nextView = nil
        } else {
            if let view = nextView {
                view.removeFromSuperview()
                unusedQueue.append(view)
                nextView = nil
            }
        }
    }
    func directionFromVelocity(velocity:CGPoint) -> PanGestureDirection {
        let direction:PanGestureDirection
        if abs(velocity.y) > abs(velocity.x) {
            //vertical
            if velocity.y > 0 {
                direction = .Down
            } else {
                direction = .Up
            }
        } else {
            //horizontal
            if velocity.x > 0 {
                direction = .Right
            } else {
                direction = .Left
            }
        }
        return direction
    }
    
}

enum PanGestureDirection {
    case Right
    case Left
    case Up
    case Down
    func isVertical() -> Bool {
        switch self {
        case .Up, .Down:
            return true
        case .Right, .Left:
            return false
        }
    }
}

func -(lhs:CGPoint,rhs:CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x-rhs.x, y: lhs.y-rhs.y)
}