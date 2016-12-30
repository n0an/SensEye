//
//  TransitionHelper.swift
//  SensEye
//
//  Created by Anton Novoselov on 30/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

//enum TransitionHelper {
//
//    case ducSlideRight
//    case ducPop
//    case ducSlideRightThenPop
//
//    case acSlideDown
//    case acRotate
//    case acSlideRight
//    case acPop
//
//
//    private var selectedAnimator:  UIViewControllerTransitioningDelegate {
//        switch self {
//        case .ducSlideRight:
//            return SlideRightTransitionAnimator()
//        case .ducPop:
//            return PopTransitionAnimator()
//        case .ducSlideRightThenPop:
//            return SlideRightThenPopTransitionAnimator()
//
//        case .acSlideDown:
//            return ACSlideDownTransitionAnimator()
//        case .acRotate:
//            return ACRotateTransitionAnimator()
//        case .acSlideRight:
//            return ACSlideRightTransitionAnimator()
//        case .acPop:
//            return ACPopTransitionAnimator()
//
//        }
//    }
//
//    func animator() -> UIViewControllerTransitioningDelegate {
//        return selectedAnimator
//    }
//
//
//
//}

class TransitionHelper {
    
    static let sharedHelper = TransitionHelper()
    
    let slideRightTransitionAnimator = SlideRightTransitionAnimator()
    let popTransitionAnimator = PopTransitionAnimator()
    let slideRightThenPopTransitionAnimator = SlideRightThenPopTransitionAnimator()
    
    let acSlideDownTransition = ACSlideDownTransitionAnimator()
    let acSlideRightTransition = ACSlideRightTransitionAnimator()
    let acPopTransition = ACPopTransitionAnimator()
    let acRotateTransition = ACRotateTransitionAnimator()
    
    
}
























