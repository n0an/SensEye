//
//  AboutCellSocnet.swift
//  SensEye
//
//  Created by Anton Novoselov on 07/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit
import Spring

class AboutCellSocnet: UITableViewCell {
    
    
    @IBOutlet weak var iconImageView: DesignableImageView!
    
    @IBOutlet weak var contactLabel: DesignableLabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImageView.animation = "fadeInLeft"
        iconImageView.curve = "easeIn"
        iconImageView.duration = 1.0
        iconImageView.animate()
        
        
        contactLabel.animation = "squeezeLeft"
        contactLabel.curve = "easeIn"
        contactLabel.force = 2.0
        contactLabel.duration = 0.6
        contactLabel.animate()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
