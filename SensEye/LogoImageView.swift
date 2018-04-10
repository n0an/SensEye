//
//  LogoImageView.swift
//  SensEye
//
//  Created by Anton Novoselov on 10/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

class LogoImageView: CircleImageView {

    func animateLogo(withVC vc: FeedViewController) {
        UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveLinear, animations: {
            let transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.transform = transform
            self.alpha = 0.0
            
        }) { (finished) in
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveLinear, animations: {
                self.transform = .identity
                self.alpha = 1.0
                
            }, completion: { (finished) in
                if vc.refreshControl.isRefreshing {
                    vc.animateRefresh()
                    
                } else {
                    vc.isLogoAnimating = false
                    self.transform = .identity
                    self.alpha = 0.0
                    
                    GeneralHelper.sharedHelper.hideDGSpinner(onView: vc.customRefreshView)
                }
            })
        }
    }
}
