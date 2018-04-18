//
//  AboutTableViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 07/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI
import Spring

class AboutTableViewController: UITableViewController, Alertable {
      
    // MARK: - PROPERTIES
    var sectionTitles = [NSLocalizedString("Contacts", comment: "Contacts"),
                         NSLocalizedString("Social Networks", comment: "Social Networks"),
                         NSLocalizedString("About me", comment: "About me")]
    
    var connections = [
                Contact(imageName: "about-icon-website", labelText: "www.senseye.ru", link: ""),
                Contact(imageName: "about-icon-phone", labelText: "+7 916 341-00-46", link: ""),
                Contact(imageName: "about-icon-chat", labelText: NSLocalizedString("InApp Chat", comment: "InApp Chat"), link: ""),
                Contact(imageName: "about-icon-email", labelText: NSLocalizedString("Email to me", comment: "Email to me"), link: ""),
                Contact(imageName: "about-icon-skypeColor", labelText: "Skype: elena.senseye", link: "")
    ]
    
    var socNet = [
        Contact(imageName: "about-icon-facebookColor", labelText: "Facebook", link: "https://facebook.com/elena.senseye"),
        Contact(imageName: "about-icon-instagramColor", labelText: "Instagram", link: "https://www.instagram.com/elena.senseye.photo"),
        Contact(imageName: "about-icon-vkColor", labelText: NSLocalizedString("VK", comment: "Vkontakte"), link: "https://vk.com/elena_senseye")
    ]
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let profileImage = UIImage(named: "me")
        var profileImageView: UIImageView!
        
        if traitCollection.verticalSizeClass == .regular && traitCollection.horizontalSizeClass == .regular {
            profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 300))
            
        } else {
            profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 190))
        }
        
        profileImageView.image = profileImage
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        
        tableView.tableHeaderView = profileImageView
    }
    
    
    // MARK: - HELPER METHODS
    func showSkype() {
        openURLWith("skype:elena.senseye?chat")
    }
    
    func callToNumber() {
        openURLWith("tel://+79163410046")
    }
    
    func openURLWith(_ string: String) {
        let urlToOpen = URL(string: string)
        
        guard let url = urlToOpen else { return }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url)
        }
    }
    
    
    // MARK: - ANIMATIONS
    func animateIconImageView(iconImageView: DesignableImageView, delay: CGFloat) {
        iconImageView.animation = "fadeInLeft"
        iconImageView.curve     = "spring"
        iconImageView.force     = 2.0
        iconImageView.duration  = 0.6
        iconImageView.delay     = delay
        iconImageView.animate()
    }
    
    func animateLabel(contactLabel: DesignableLabel, delay: CGFloat) {
        contactLabel.animation  = "squeezeLeft"
        contactLabel.curve      = "spring"
        contactLabel.force      = 2.0
        contactLabel.duration   = 0.6
        contactLabel.delay      = delay
        contactLabel.animate()
    }
    
    func animateInfoLabel(infoLabel: DesignableLabel) {
        infoLabel.animation     = "fadeIn"
        infoLabel.curve         = "easeIn"
        infoLabel.duration      = 1.2
        infoLabel.delay         = 0.5
        infoLabel.animate()
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case AboutScreenTableViewSection.connections.rawValue:
            return self.connections.count
        case AboutScreenTableViewSection.socNet.rawValue:
            return self.socNet.count
        case AboutScreenTableViewSection.info.rawValue:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case AboutScreenTableViewSection.connections.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellIdSocNet, for: indexPath) as! AboutCellSocnet

            let connection = self.connections[indexPath.row]
            
            cell.contactLabel.text = connection.labelText
            cell.iconImageView.image = UIImage(named: connection.imageName)
            
            if indexPath.row == 0 {
                cell.iconImageView.borderWidth = 1
                cell.iconImageView.borderColor = UIColor.lightGray
                cell.iconImageView.cornerRadius = cell.iconImageView.bounds.width/2
            } else {
                cell.iconImageView.borderWidth = 0
                cell.iconImageView.cornerRadius = 0
            }
                        
            return cell
            
        case AboutScreenTableViewSection.socNet.rawValue:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellIdSocNet, for: indexPath) as! AboutCellSocnet
            
            let socNet = self.socNet[indexPath.row]
            
            cell.contactLabel.text = socNet.labelText
            cell.iconImageView.image = UIImage(named: socNet.imageName)
            
            let delay = CGFloat(0.2 * Double(indexPath.row))
            
            self.animateIconImageView(iconImageView: cell.iconImageView, delay: delay)
            self.animateLabel(contactLabel: cell.contactLabel, delay: delay)
            
            return cell
            
        case AboutScreenTableViewSection.info.rawValue:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellIdInfo, for: indexPath) as! AboutCellInfo
            
            cell.selectionStyle = .none
            
            self.animateInfoLabel(infoLabel: cell.infoLabel)
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == AboutScreenTableViewSection.info.rawValue {
            return Storyboard.rowHeightInfo
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        
        case AboutScreenTableViewSection.connections.rawValue:
            if indexPath.row == AboutScreenTableViewRowConnection.web.rawValue {
                if let url = URL(string: "http://www.senseye.ru") {
                    let safariController = SFSafariViewController(url: url)
                    present(safariController, animated: true, completion: nil)
                }
            } else if indexPath.row == AboutScreenTableViewRowConnection.phone.rawValue {
                self.callToNumber()
            } else if indexPath.row == AboutScreenTableViewRowConnection.chat.rawValue {
                let tabBarController = UIApplication.shared.keyWindow?.rootViewController as! UITabBarController
                tabBarController.selectedIndex = TabBarIndex.chat.rawValue
            } else if indexPath.row == 2 {
                self.showEmailComposer()
            } else {
                self.showSkype()
            }
            
        case AboutScreenTableViewSection.socNet.rawValue:
            let socNet = self.socNet[indexPath.row]
            
            if let url = URL(string: socNet.link) {
                let safariController = SFSafariViewController(url: url)
                present(safariController, animated: true, completion: nil)
            }
            
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if indexPath.section == AboutScreenTableViewSection.info.rawValue {
            return nil
        } else {
            return indexPath
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension AboutTableViewController: MFMailComposeViewControllerDelegate {
    
    func showEmailComposer() {
        
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        
        let messageSubject = NSLocalizedString("Hello", comment: "Hello mailSubject")
        
        let toRecipients = ["senseye.ru@gmail.com"]
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setSubject(messageSubject)
        mailComposer.setToRecipients(toRecipients)
        
        present(mailComposer, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        
        if let error = error {
            self.alertError(error: error as NSError)
        }
        
        dismiss(animated: true, completion: nil)
    }
}
