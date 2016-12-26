//
//  FeedViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    enum Storyboard {
        static let cellId = "FeedCell"
        static let rowHeight: CGFloat = 365
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        
        tableView.estimatedRowHeight = Storyboard.rowHeight
        
        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.rowHeight = Storyboard.rowHeight

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}


extension FeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellId, for: indexPath) as! FeedCell
        
//        cell.mainPhotoImageView.image = UIImage(named: "space")
//        cell.minorPhotoOneImageView.image = UIImage(named: "ufo")
//        cell.minorPhotoTwoImageView.image = UIImage(named: "pyramid")
//        cell.minorPhotoThreeImageView.image = UIImage(named: "space")
        
        return cell
        
    }
    
    
}

extension FeedViewController: UITableViewDelegate {
    
    
    
}














