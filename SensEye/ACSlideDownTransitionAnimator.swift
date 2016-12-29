//
//  SlideDownTransitionAnimator.swift
//  NavTransition
//
//  Created by Anton Novoselov on 18/12/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit


class ACSlideDownTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
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
        
        let offScreenUp = CGAffineTransform(translationX: 0, y: -container.frame.height)
        let offScreenDown = CGAffineTransform(translationX: 0, y: container.frame.height)
        
        // Make the toView off screen if it is transition from main to detail view
        
        if isPresenting {
            toView.transform = offScreenUp
        }
        
        // Add both views to the container view
        container.addSubview(fromView)
        container.addSubview(toView)
        
        // Perform the animation
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [], animations: {
            
            if self.isPresenting {
                
                fromView.transform = offScreenDown
                fromView.alpha = 0.5
                
                toView.transform = .identity
                
                
            } else {
                
                fromView.transform = offScreenUp
                fromView.alpha = 1.0
                
                toView.transform = .identity
                toView.alpha = 1.0
            }
            
            
            
            
        }) { (finished) in
            transitionContext.completeTransition(true)
        }
        
        
    }
    
    
    
    
    
    
    
    
}













