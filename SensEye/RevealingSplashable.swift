//
//  RevealingSplashable.swift
//  SensEye
//
//  Created by Anton Novoselov on 04/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit
import RevealingSplashView

protocol RevealingSplashable {
    
    var revealingSplashView: RevealingSplashView { get set }
    
    func addRevealingSplashView(toView view: UIView)
    
    func stopRevealingSplashView()
}

extension RevealingSplashable {
    func addRevealingSplashView(toView view: UIView) {
        view.addSubview(revealingSplashView)
        revealingSplashView.animationType = .heartBeat
        revealingSplashView.startAnimation()
    }
    
    func stopRevealingSplashView() {
        revealingSplashView.heartAttack = true
    }
}
