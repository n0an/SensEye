//
//  RecentViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 22/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit
import Firebase

class RecentViewController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - PROPERTIES
    
    enum Storyboard {
        static let cellIdChat = "ChatCell"
        static let segueShowChatVC = "showChatViewController"
        static let segueUsersVC = "showUsersViewController"
    }
    
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
        
        let backButton = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logoutButtonTapped))

        
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
    
    deinit {
        print("===NAG=== DEINIT RecentViewController")
    }

    
    // MARK: - HELPER METHODS
    
    func fetchChats() {
        
        let userChatIdsRef = currentUser.userRef.child("chatIds")
        
        userChatIdsRef.observe(.childAdded, with: { (snapshot) in
            
            let chatId = snapshot.key
            
            FRDataManager.sharedManager.REF_CHATS.child(chatId).observeSingleEvent(of: .value, with: { (snapshot) in
                
                let chat = FRChat(uid: chatId, dictionary: snapshot.value as! [String: Any])
                
                if !self.alreadyAddedChat(chat) {
                    // adding new chat
                    
                    self.chats.append(chat)
                    
                    let indexPath = IndexPath(row: self.chats.count - 1, section: 0)
                    
                    self.tableView.insertRows(at: [indexPath], with: .automatic)
                    
                } else {
                    self.tableView.reloadData()
                }
            })
        })
    }
    
    func alreadyAddedChat(_ chat: FRChat) -> Bool {
        
        return self.chats.contains(chat)
        
    }
    
    
    // MARK: - ACTIONS
    
    func logoutButtonTapped() {
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.segueShowChatVC {
            
            let chatVC = segue.destination as! ChatViewController
            
            let selectedChat = sender as! FRChat
            
            chatVC.currentUser = currentUser
            
            chatVC.chat = selectedChat
            
            chatVC.senderId = currentUser.uid
            
            chatVC.senderDisplayName = currentUser.username
            
            chatVC.hidesBottomBarWhenPushed = true
            
        }
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
        
        
        
        performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: selectedChat)
        
        
        
    }
    
}

// MARK: - UITabBarControllerDelegate
extension RecentViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        
        if tabBarController.selectedIndex == 3 {
            
            
            if let index = tabBarController.viewControllers?.index(of: viewController), index == 3 {
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



















