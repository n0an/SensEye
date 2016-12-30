//
//  SlideRightThenPopTransitionAnimator.swift
//  Taggs
//
//  Created by Anton Novoselov on 24/09/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

class SlideRightThenPopTransitionAnimator: NSObject {
    var duration = 0.5
    fileprivate var isPresenting = false
}

extension SlideRightThenPopTransitionAnimator : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
}

extension SlideRightThenPopTransitionAnimator : UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
        
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        let containerView = transitionContext.containerView
        
        // transforms
        
        let offScreenLeft = CGAffineTransform(translationX: -containerView.frame.width, y: 0)
        let offScreenRight = CGAffineTransform(translationX: containerView.frame.width, y: 0)
        let minimize = CGAffineTransform(scaleX: 0.5, y: 0.5)
        let minimizeAndOffScreenLeft = minimize.concatenating(offScreenLeft)
        
        if isPresenting {
            toView.transform = minimizeAndOffScreenLeft
        }
        
        if isPresenting {
            containerView.addSubview(fromView)
            containerView.addSubview(toView)
        } else {
            containerView.addSubview(toView)
            containerView.addSubview(fromView)
        }
        
        UIView.animate(withDuration: duration/2.0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: [], animations: { () -> Void in
            
            let backToMainScreen = CGAffineTransform(translationX: 0, y: 0)
            if self.isPresenting {
                toView.transform = minimize.concatenating(backToMainScreen)
                fromView.transform = offScreenRight
            } else {
                fromView.transform = minimize.concatenating(offScreenRight)
            }
            
            }, completion: nil)
        
        UIView.animate(withDuration: duration/2.0, delay: duration/2.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: [], animations: { () -> Void in
            
            if self.isPresenting {
                toView.transform = .identity
            } else {
                fromView.transform = minimizeAndOffScreenLeft
                toView.transform = .identity
            }
            
        }) { (finished) -> Void in
            if finished {
                transitionContext.completeTransition(true)
            }
        }

        
        
        
        
    }
}
