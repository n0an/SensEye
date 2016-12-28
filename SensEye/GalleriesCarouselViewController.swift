//
//  GalleriesCarouselViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 28/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import iCarousel
import AlamofireImage

class GalleriesCarouselViewController: UIViewController {

    var albums: [PhotoAlbum] = []
    @IBOutlet var carousel: iCarousel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAlbums()

        carousel.type = .coverFlow2
    }
    
    
    func getAlbums() {
        
        ServerManager.sharedManager.getPhotoAlbums(forGroupID: groupID) { (result) in
            
            guard let albums = result as? [PhotoAlbum] else { return }
            
            self.albums = albums
            
            self.carousel.reloadData()
            
        }
        
    }

    
}



extension GalleriesCarouselViewController: iCarouselDataSource {
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return albums.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let album = self.albums[index]
        
        var label: UILabel
        var itemView: UIImageView
        
        //reuse view if available, otherwise create a new view
        if let view = view as? UIImageView {
            itemView = view
            //get a reference to the label in the recycled view
            label = itemView.viewWithTag(1) as! UILabel
        } else {
            //don't do anything specific to the index within
            //this `if ... else` statement because the view will be
            //recycled and used with other index values later
            itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 250, height: 400))
            
            if let imageURLString = album.albumThumbImageURL {
                
                let imageURL = URL(string: imageURLString)
                
                itemView.af_setImage(withURL: imageURL!)
                
//                itemView.image = UIImage(named: "page.png")
                
            } else {
                
                itemView.image = UIImage(named: "page.png")
            }
            
            
            itemView.contentMode = .scaleAspectFit
            
            label = UILabel(frame: itemView.bounds)
            label.backgroundColor = .clear
            label.textAlignment = .center
            label.font = label.font.withSize(10)
            label.tag = 1
            itemView.addSubview(label)
        }
        
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        label.text = album.albumTitle
        
        return itemView

        
    }
    
}


extension GalleriesCarouselViewController: iCarouselDelegate {
    
    
}













