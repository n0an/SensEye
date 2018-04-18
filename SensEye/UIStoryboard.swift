//
//  UIStoryboard.swift
//  SensEye
//
//  Created by Anton Novoselov on 03/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: MAIN_STORYBOARD, bundle: Bundle.main)
    }
    
    class func feedVC() -> FeedViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: VC_FEED) as? FeedViewController
    }
    
    class func postVC() -> PostViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: VC_POST) as? PostViewController
    }
    
    class func commentComposerVC() -> CommentComposerViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: VC_COMMENTCOMPOSER) as? CommentComposerViewController
    }
    
    class func landscapeVC() -> LandscapeViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: VC_GALLERY) as? LandscapeViewController
    }
    
    class func loginVC() -> LoginViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: VC_LOGIN) as? LoginViewController
    }
    
    class func signupVC() -> SignUpViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: VC_SIGNUP) as? SignUpViewController
    }
    
    class func resetPasswordVC() -> ResetPasswordViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: VC_RESETPASSWD) as? ResetPasswordViewController
    }
    
    class func recentVC() -> RecentViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: VC_RECENT) as? RecentViewController
    }
    
    class func chatVC() -> ChatViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: VC_CHAT) as? ChatViewController
    }
    
    class func aboutVC() -> AboutTableViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: VC_ABOUT) as? AboutTableViewController
    }
}
