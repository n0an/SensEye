//
//  AboutTableViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 07/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit
import SafariServices

class AboutTableViewController: UITableViewController {
    
    // MARK: - PROPERTIES
    
    var sectionTitles = ["Контакты", "Обо мне"]
    
    var contacts = [
        Contact(imageName: "icon-facebook", labelText: "Facebook", link: "facebook.com/elena.senseye"),
        Contact(imageName: "icon-email", labelText: "Email", link: "senseye.ru@gmail.com"),
        Contact(imageName: "icon-email", labelText: "Skype: elena.senseye", link: ""),
        Contact(imageName: "icon-twitter", labelText: "instagram.com/elena.senseye", link: "instagram.com/elena.senseye"),
        Contact(imageName: "icon-twitter", labelText: "vk.com/elena_senseye", link: "vk.com/elena_senseye")
                    ]
    
    var sectionContent = [["Facebook", "Email", "Instagram", "Skype"],
                          ["Twitter", "Facebook", "Pinterest"]]
    
    var links = ["https://twitter.com/appcodamobile", "https://facebook.com/appcodamobile", "https://www.pinterest.com/appcoda/"]
    
    // MARK: - ENUMS
    
    enum Storyboard {
        static let cellIdContacts = "AboutCellContacts"
        static let cellIdInfo = "AboutCellInfo"

        static let rowHeightContacts: CGFloat = 93
        static let rowHeightInfo: CGFloat = 200

        
        static let seguePhotoDisplayer = "showPhoto"
        static let seguePostVC = "showPost"
        
        static let viewControllerIdPhotoDisplayer = "PhotoNavViewController"
    }
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return self.contacts.count
        case 1:
            return 1
        default:
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellIdContacts, for: indexPath) as! AboutCellContacts
            
            let contact = self.contacts[indexPath.row]
            
            cell.contactLabel.text = contact.labelText
            cell.iconImageView.image = UIImage(named: contact.imageName)
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellIdInfo, for: indexPath) as! AboutCellInfo
            
            return cell
        }
        
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 1 {
            return Storyboard.rowHeightInfo
        } else {
            return UITableViewAutomaticDimension
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
            
        // Leave us feedback section
        case 0:
            if indexPath.row == 0 {
                if let url = URL(string: "http://www.apple.com/itunes/charts/paid-apps/") {
                    UIApplication.shared.open(url)
                }
            } else if indexPath.row == 1 {
                performSegue(withIdentifier: "showWebView", sender: self)
            }
            
        // Follow us section
        case 1:
            if let url = URL(string: links[indexPath.row]) {
                let safariController = SFSafariViewController(url: url)
                present(safariController, animated: true, completion: nil)
            }
            
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    
}
