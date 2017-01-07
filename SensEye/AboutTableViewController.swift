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
    
    var sectionTitles = ["Связаться со мной", "Соцсети", "Обо мне"]
    
    var connections = ["Напишите мне письмо", "Skype: elena.senseye"]
    
    var socNet = [
        Contact(imageName: "icon-facebook", labelText: "Facebook", link: "https://facebook.com/elena.senseye"),
        Contact(imageName: "icon-twitter", labelText: "Instagram", link: "https://instagram.com/elena.senseye"),
        Contact(imageName: "icon-twitter", labelText: "VK", link: "https://vk.com/elena_senseye")
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

        static let seguePhotoDisplayer = "showPhoto"
        static let seguePostVC = "showPost"
        
    }
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case TableViewSection.connections.rawValue:
            return 2
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
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellConnection, for: indexPath)
            
            let connection = self.connections[indexPath.row]
            
            cell.textLabel?.text = connection
            cell.imageView?.image = UIImage(named: "icon-email")
            
            return cell
            
        case TableViewSection.socNet.rawValue:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellIdSocNet, for: indexPath) as! AboutCellSocnet
            
            let contact = self.socNet[indexPath.row]
            
            cell.contactLabel.text = contact.labelText
            cell.iconImageView.image = UIImage(named: contact.imageName)
            
            return cell

        case TableViewSection.info.rawValue:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellIdInfo, for: indexPath) as! AboutCellInfo
            
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
            if let url = URL(string: "www.ru") {
                let safariController = SFSafariViewController(url: url)
                present(safariController, animated: true, completion: nil)
            }
            
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    
}
