//
//  PostHeaderView.swift
//  SensEye
//
//  Created by Anton Novoselov on 05/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit

// MARK: - DELEGATE
protocol PostHeaderViewDelegate: class {
    func closeButtonTapped()
    func logoutFromVKButtonTapped()
}

class PostHeaderView: UIView {
    
    // MARK: - OUTLETS
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var pullDownToCloseLabel: UILabel!
    @IBOutlet weak var closeButtonBackgroundView: UIView!

   // MARK: - PROPERTIES
    weak var delegate: PostHeaderViewDelegate?
    
    // MARK: - layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        closeButtonBackgroundView.layer.cornerRadius = closeButtonBackgroundView.bounds.width / 2
        closeButtonBackgroundView.layer.masksToBounds = true
    }
    
    // MARK: - HELPER METHODS
    public func updateUI(withPost wallPost: WallPost, andImage image: UIImage?) {
        pullDownToCloseLabel.text! = NSLocalizedString("Pull down to close", comment: "Pull down to close")
        pullDownToCloseLabel.isHidden = true
        self.backgroundImageView.image = image
    }
  
    // MARK: - ACTIONS
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        delegate?.closeButtonTapped()
    }
    
    @IBAction func logoutFromVKButtonTapped() {
        delegate?.logoutFromVKButtonTapped()
    }
}
