//
//  RecentViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 22/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit
import Firebase

class RecentViewController: UIViewController, Alertable {
    
    // MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - PROPERTIES
    var chats: [FRChat] = []
    
    var currentUser: FRUser!
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredChats: [FRChat] = []

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = false
        self.tableView.tableHeaderView = searchController.searchBar
        
        self.tabBarController?.delegate = self

        self.currentUser = FRAuthManager.sharedManager.currentUser
        
        let backButton = UIBarButtonItem(title: NSLocalizedString("Logout", comment: "Logout"),
                                         style: .done,
                                         target: self,
                                         action: #selector(logoutButtonTapped))

        self.navigationItem.leftBarButtonItem = backButton
        
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            self.tableView.estimatedRowHeight = 80
        } else {
            self.tableView.estimatedRowHeight = 65
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.hidesBarsOnSwipe = false

        self.fetchChats()
    }
    
    
    // MARK: - HELPER METHODS
    func fetchChats() {
        
        let chatRef = FRDataManager.sharedManager.REF_CHATS
        
        chatRef.observe(.childAdded, with: { (snapshot) in
            let chatId = snapshot.key
            
            let chat = FRChat(uid: chatId, dictionary: snapshot.value as! [String: Any])
            
            if !self.alreadyAddedChat(chat) {
                self.chats.append(chat)
                let indexPath = IndexPath(row: self.chats.count - 1, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
                
            } else {
                if let index = self.chats.index(of: chat) {
                    self.chats[index] = chat
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        })
    }
    
    func alreadyAddedChat(_ chat: FRChat) -> Bool {
        return self.chats.contains(chat)
    }
    
    // MARK: - ACTIONS
    @objc func logoutButtonTapped() {
        
        GeneralHelper.sharedHelper.showLogoutView(onViewController: self) { (success) in
            if success == true {
                let _ = self.navigationController?.popToRootViewController(animated: false)
                
                FRAuthManager.sharedManager.logOut(onComplete: { (error) in
                    if let error = error {
                        self.alertError(error: error as NSError)
                    }
                })
            }
        }
    }
    
    // MARK: - NAVIGATION
    func transitToChatVC(withChat chat: FRChat) {
  
        let chatVC = UIStoryboard.chatVC()
        
        chatVC?.currentUser = currentUser
        chatVC?.chat = chat
        chatVC?.senderId = currentUser.uid
        chatVC?.senderDisplayName = currentUser.username
        chatVC?.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(chatVC!, animated: true)
        
    }

}

// MARK: - UITableViewDataSource
extension RecentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredChats.count
        } else {
            return chats.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let chatCell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellIdChat, for: indexPath) as! ChatTableViewCell
        
        var chat: FRChat
        
        if searchController.isActive && searchController.searchBar.text != "" {
            chat = self.filteredChats[indexPath.row]
        } else {
            chat = self.chats[indexPath.row]
        }
        
        chatCell.chat = chat
        
        return chatCell
    }
}

// MARK: - UITableViewDelegate
extension RecentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var selectedChat: FRChat
        
        if searchController.isActive && searchController.searchBar.text != "" {
            selectedChat = self.filteredChats[indexPath.row]
            self.searchController.isActive = false
        } else {
            selectedChat = self.chats[indexPath.row]
        }
        
        self.transitToChatVC(withChat: selectedChat)
    }
}

// MARK: - UITabBarControllerDelegate
extension RecentViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if tabBarController.selectedIndex == TabBarIndex.chat.rawValue {
            if let index = tabBarController.viewControllers?.index(of: viewController), index == TabBarIndex.chat.rawValue {
                return false
            }
        }
        
        return true
    }
}

// MARK: - UISearchResultsUpdating
extension RecentViewController: UISearchResultsUpdating {
    func filteredContentForSearchText(searchText: String) {
        filteredChats = chats.filter({ (chat) -> Bool in
            return chat.withUserName.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
}




