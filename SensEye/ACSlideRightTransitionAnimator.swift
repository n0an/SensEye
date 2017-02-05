//
//  SlideRightTransitionAnimator.swift
//  NavTransition
//
//  Created by Anton Novoselov on 18/12/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class ACSlideRightTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    
    let duration = 0.5
    var isPresenting = false
    
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresenting = false
        return self
    }
    
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // Get reference to our fromView, toView and the container view
        
        guard let fromView = transitionContext.view(forKey: .from) else {
            return
        }
        
        guard let toView = transitionContext.view(forKey: .to) else {
            return
        }
        
        // Set up the transform we'll use in the animation
        let container = transitionContext.containerView
        
        let offScreenLeft = CGAffineTransform(translationX: -container.frame.width, y: 0)
//        let offScreenRight = CGAffineTransform(translationX: container.frame.width, y: 0)
        
        // Make the toView off screen if it is transition from main to detail view
        if isPresenting {
            toView.transform = offScreenLeft
        }
        
        // Add both views to the container view.
        // If the isPresenting == true , toView should be placed on top of fromView
        if isPresenting {
            container.addSubview(fromView)
            container.addSubview(toView)
        } else {
            container.addSubview(toView)
            container.addSubview(fromView)
        }
        
        
        // Perform the animation
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [], animations: {
            
            if self.isPresenting {
                
                toView.transform = .identity
                
            } else {
                
                fromView.transform = offScreenLeft
            }
            
            
            
            
        }) { (finished) in
            transitionContext.completeTransition(true)
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
