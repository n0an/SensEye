//
//  ActionMenuViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 29/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit

protocol ActionMenuViewControllerDelegate: class {
    func actionTwitterSelected()
    func actionFacebookSelected()
    func actionOtherSelected()
}

class ActionMenuViewController: UITableViewController {

    weak var delegate: ActionMenuViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            delegate?.actionTwitterSelected()
        case 1:
            delegate?.actionFacebookSelected()
        case 2:
            delegate?.actionOtherSelected()
        default:
            break
        }
        
        
    }
    
    
    
}
