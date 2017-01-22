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
        
    }
    
    
    var chats: [FRChat] = []
    
    var currentUser: FRUser!

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        self.currentUser = FRAuthManager.sharedManager.currentUser
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        
        self.fetchChats()
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
    
    

}


// MARK: - UITableViewDataSource
extension RecentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let chatCell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellIdChat, for: indexPath) as! ChatTableViewCell
        
        let chat = self.chats[indexPath.row]
        
        chatCell.chat = chat
        
        return chatCell
        
    }
    
}



// MARK: - UITableViewDelegate
extension RecentViewController: UITableViewDelegate {
    
}


























