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

class AboutTableViewController: UITableViewController {
    
    // MARK: - PROPERTIES
    
    
    var sectionTitles = [NSLocalizedString("Contacts", comment: "Contacts"), NSLocalizedString("Social Networks", comment: "Social Networks"), NSLocalizedString("About me", comment: "About me")]
    
    
    var connections = [
                Contact(imageName: "about-icon-chat", labelText: NSLocalizedString("InApp Chat", comment: "InApp Chat"), link: ""),
                Contact(imageName: "about-icon-email", labelText: NSLocalizedString("Email to me", comment: "Email to me"), link: ""),
                Contact(imageName: "about-icon-skypeColor", labelText: "Skype: elena.senseye", link: "")
    
    ]
    
    
    
    var socNet = [
        Contact(imageName: "about-icon-facebookColor", labelText: "Facebook", link: "https://facebook.com/elena.senseye"),
        Contact(imageName: "about-icon-instagramColor", labelText: "Instagram", link: "https://instagram.com/elena.senseye"),
        Contact(imageName: "about-icon-vkColor", labelText: NSLocalizedString("VK", comment: "Vkontakte"), link: "https://vk.com/elena_senseye")
    ]
    
    // MARK: - ENUMS
    
    enum TableViewSection: Int {
        case connections = 0
        case socNet
        case info
    }
    
    enum Storyboard {
        static let cellConnection = "ConnectCell"
        static let cellIdSocNet = "AboutCellSocnet"
        static let cellIdInfo = "AboutCellInfo"
        
        static let rowHeightInfo: CGFloat = 200
        
    }
    
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - HELPER METHODS
    
    func showSkype() {
        
        let skypeURL = URL(string: "skype:elena.senseye?chat")
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(skypeURL!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(skypeURL!)
            

        }
       

    }
    
    
    // MARK: - ANIMATIONS
    
    func animateIconImageView(iconImageView: DesignableImageView, delay: CGFloat) {
        iconImageView.animation = "fadeInLeft"
        iconImageView.curve = "spring"
        iconImageView.force = 2.0
        iconImageView.duration = 0.6
        iconImageView.delay = delay
        iconImageView.animate()
        
        
    }
    
    func animateLabel(contactLabel: DesignableLabel, delay: CGFloat) {
        contactLabel.animation = "squeezeLeft"
        contactLabel.curve = "spring"
        contactLabel.force = 2.0
        contactLabel.duration = 0.6
        contactLabel.delay = delay
        contactLabel.animate()
    }
    
    func animateInfoLabel(infoLabel: DesignableLabel) {
        infoLabel.animation = "fadeIn"
        infoLabel.curve = "easeIn"
        infoLabel.duration = 1.2
        infoLabel.delay = 0.5
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
        case TableViewSection.connections.rawValue:
            return self.connections.count
        case TableViewSection.socNet.rawValue:
            return self.socNet.count
        case TableViewSection.info.rawValue:
            return 1
        default:
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case TableViewSection.connections.rawValue:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellIdSocNet, for: indexPath) as! AboutCellSocnet
            
            let connection = self.connections[indexPath.row]
            
            cell.contactLabel.text = connection.labelText
            cell.iconImageView.image = UIImage(named: connection.imageName)
            
            
            return cell
            
         
            
        case TableViewSection.socNet.rawValue:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellIdSocNet, for: indexPath) as! AboutCellSocnet
            
            let socNet = self.socNet[indexPath.row]
            
            cell.contactLabel.text = socNet.labelText
            cell.iconImageView.image = UIImage(named: socNet.imageName)
            
            
            let delay = CGFloat(0.2 * Double(indexPath.row))
            
            self.animateIconImageView(iconImageView: cell.iconImageView, delay: delay)
            self.animateLabel(contactLabel: cell.contactLabel, delay: delay)
            
            return cell
            
        case TableViewSection.info.rawValue:
            
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
        
        if indexPath.section == TableViewSection.info.rawValue {
            return Storyboard.rowHeightInfo
        } else {
            return UITableViewAutomaticDimension
        }
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
            
        // Connections section
        case TableViewSection.connections.rawValue:
            
            
            if indexPath.row == 0 {
                
                let tabBarController = UIApplication.shared.keyWindow?.rootViewController as! UITabBarController
                tabBarController.selectedIndex = TabBarIndex.chat.rawValue
                
            } else if indexPath.row == 1 {
                self.showEmailComposer()
            } else {
                self.showSkype()
                //                self.sendSMS()
            }
            
            
        //Social networks section
        case TableViewSection.socNet.rawValue:
            
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
        
        if indexPath.section == TableViewSection.info.rawValue {
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
        
        switch result {
        case .cancelled:
            print("cancelled")
        case .saved:
            print("saved")
        case .failed:
            print("failed")
        case .sent:
            print("sent")
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
}




// MARK: - MFMessageComposeViewControllerDelegate
extension AboutTableViewController: MFMessageComposeViewControllerDelegate {
    
    func sendSMS() {
        
        guard MFMessageComposeViewController.canSendText() else {
            
            self.alert(title: NSLocalizedString("SMS Unavailable", comment: "SMS Unavailable"), message: NSLocalizedString("Your device is not capable of sending SMS", comment: "SMS Unavailable"))
            
            return
        }
        
        let messageController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = self
        messageController.recipients = ["79163410046"]
        
        present(messageController, animated: true, completion: nil)
        
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        
        
        
        
        
        switch result {
        case .cancelled:
            print(NSLocalizedString("SMS cancelled", comment: "SMS cancelled"))
        
        case .failed:
            print(NSLocalizedString("SMS failed", comment: "SMS failed"))
            self.alert(title: NSLocalizedString("Failure", comment: "Failure"), message: NSLocalizedString("Failed to send the message", comment: "Failed to send the message"))
            
        case .sent:
            print("SMS sent")
            
           
        }
        
        dismiss(animated: true, completion: nil)
        
        
    }
    
}




