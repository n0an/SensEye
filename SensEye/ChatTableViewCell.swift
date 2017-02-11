//
//  ChatTableViewCell.swift
//  SensEye
//
//  Created by Anton Novoselov on 22/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit
import Firebase
import SAMCache

class ChatTableViewCell: UITableViewCell {

    // MARK: - OUTLETS
    @IBOutlet weak var featuredImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    @IBOutlet weak var unreadMessagesLabel: UILabel!

    // MARK: - PROPERTIES
    var chat: FRChat! {
        didSet {
            self.updateUI()
        }
    }
    
    var cache = SAMCache.shared()
    
    // MARK: - HELPER METHODS
    func updateUI() {
        self.titleLabel.text = chat.withUserName
        self.lastMessage.text = chat.lastMessage
        
        let timeInterval = chat.lastUpdate / 1000
        let lastUpdateDate = NSDate(timeIntervalSince1970: timeInterval)
        
        self.lastUpdateLabel.text = lastUpdateDate.stringFromDate(short: true)
        self.unreadMessagesLabel.text = "\(chat.messagesCount)"
        
        if chat.messagesCount > 0 {
            self.unreadMessagesLabel.textColor = UIColor.red
        } else {
            self.unreadMessagesLabel.textColor = UIColor.black
        }
     
        // Set featuredImage with caching
        self.featuredImageView.image = UIImage(named: "defaultProfileImage")
        
        let featuredImageCacheKey = chat.withUserUID
        
        if let cachedImage = cache?.object(forKey: featuredImageCacheKey) as? UIImage {
            self.featuredImageView.image = cachedImage
            
        } else {
            self.chat.downloadWithUserImage { [weak self] (image, error) in
                
                if let image = image {
                    self?.featuredImageView.image = image
                    self?.cache?.setObject(image, forKey: featuredImageCacheKey)
                }
            }
        }
        
        self.featuredImageView.layer.cornerRadius = self.featuredImageView.bounds.width / 2.0
        self.featuredImageView.layer.masksToBounds = true
    }
}
