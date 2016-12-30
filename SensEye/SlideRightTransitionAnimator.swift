//
//  SlideRightTransitionAnimator.swift
//  Taggs
//
//  Created by nag on 24/09/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

class SlideRightTransitionAnimator: NSObject {
    var duration = 0.5
    fileprivate var isPresenting = false
}

extension SlideRightTransitionAnimator : UIViewControllerTransitioningDelegate {
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
}

extension SlideRightTransitionAnimator : UIViewControllerAnimatedTransitioning {
    
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
        
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        let containerView = transitionContext.containerView
        
        let offScreenLeft = CGAffineTransform(translationX: -containerView.frame.width, y: 0)
        let minimize = CGAffineTransform(scaleX: 0, y: 0)
        let shiftDown = CGAffineTransform(translationX: 0, y: 15)
        let scaleDown = shiftDown.scaledBy(x: 0.8, y: 0.8)
        
        if isPresenting {
            let minimizeAndOffScreenLeft = minimize.concatenating(offScreenLeft)
            toView.transform = minimizeAndOffScreenLeft
        }
        
        if isPresenting {
            containerView.addSubview(fromView)
            containerView.addSubview(toView)
        } else {
            containerView.addSubview(toView)
            containerView.addSubview(fromView)
        }
        
        // animate
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: [], animations: { () -> Void in
            
            if self.isPresenting {
                
                fromView.transform = scaleDown
                fromView.alpha = 0.5
                toView.transform = .identity
                
            } else {
                
                fromView.transform = offScreenLeft
                toView.alpha = 1.0
                toView.transform = .identity
                
            }
            
        }) { (finished) -> Void in
            
            if finished {
                transitionContext.completeTransition(true)
            }
        }
    }
}




