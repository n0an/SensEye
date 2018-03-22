//
//  FeedDataSource.swift
//  SensEye
//
//  Created by Anton Novoselov on 22/03/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

class FeedDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var wallPosts: [WallPost] = []
    
    weak var vc: FeedViewController?
    
    init(vc: FeedViewController) {
        self.vc = vc
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.feedCellId, for: indexPath) as! FeedCell
        
        let wallPost = self.wallPosts[indexPath.row]
        
        cell.wallPost = wallPost
        cell.delegate = vc?.cellDelegate
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as! FeedCell
        
        vc?.performSegue(withIdentifier: Storyboard.seguePostVC, sender: cell)
    }
    
}
