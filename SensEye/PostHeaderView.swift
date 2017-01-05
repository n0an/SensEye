//
//  PostHeaderView.swift
//  SensEye
//
//  Created by Anton Novoselov on 05/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit

protocol PostHeaderViewDelegate: class {
    func closeButtonTapped()
}

class PostHeaderView: UIView {
    
    // MARK: - OUTLETS
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var postTitleLabel: UILabel!
    
    @IBOutlet weak var pullDownToCloseLabel: UILabel!
    
    @IBOutlet weak var closeButtonBackgroundView: UIView!

   // MARK: - PUBLIC
    
    public var wallPost: WallPost! {
        didSet {
//            updateUI()
        }
    }
    
    weak var delegate: PostHeaderViewDelegate?
    
    
    public func updateUI(withPost wallPost: WallPost, andImage image: UIImage?) {
        
        postTitleLabel.text = wallPost.postText
        
        pullDownToCloseLabel.text! = "Pull down to close"
        
        pullDownToCloseLabel.isHidden = true
        
        self.backgroundImageView.image = image
        
    }
    
    fileprivate func updateUI() {
        
//        interest.featuredImageFile.getDataInBackground { (imageData, error) in
//            
//            if error == nil {
//                
//                if let featuredImageData = imageData {
//                    self.backgroundImageView.image = UIImage(data: featuredImageData)!
//                }
//                
//            } else {
//                print("\(error?.localizedDescription)")
//            }
//            
//        }
        
        
        postTitleLabel.text = wallPost.postText
        
        pullDownToCloseLabel.text! = "Pull down to close"
        
        pullDownToCloseLabel.isHidden = true
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        closeButtonBackgroundView.layer.cornerRadius = closeButtonBackgroundView.bounds.width / 2
        closeButtonBackgroundView.layer.masksToBounds = true
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        delegate?.closeButtonTapped()
    }

}
