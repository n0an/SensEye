//
//  GalleriesCarouselViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 28/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import iCarousel

class GalleriesCarouselViewController: UIViewController {

    var albums: [PhotoAlbum] = []
    @IBOutlet var carousel: iCarousel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for i in 0 ... 99 {
            items.append(i)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        carousel.type = .linear
    }
    

    
}



extension GalleriesCarouselViewController: iCarouselDataSource {
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return self.albums.count
    }
    
}


extension GalleriesCarouselViewController: iCarouselDelegate {
    
    
}
