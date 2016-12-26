//
//  FeedCell.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {

    @IBOutlet weak var profileImageVIew: UIImageView!
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var postTextLabel: UILabel!
    
    @IBOutlet weak var mainPhotoImageView: UIImageView!
    
    @IBOutlet weak var minorPhotoOneImageView: UIImageView!
    
    @IBOutlet weak var minorPhotoTwoImageView: UIImageView!
    
    @IBOutlet weak var minorPhotoThreeImageView: UIImageView!
    
    
    
    
    @IBOutlet weak var likeButton: UIButton!
    
    
    @IBOutlet weak var commentButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
