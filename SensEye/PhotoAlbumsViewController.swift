//
//  PhotoAlbumsViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 28/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

class PhotoAlbumsViewController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var currentUserProfileImageButton: UIButton!
    @IBOutlet weak var currentUserFullNameButton: UIButton!
    
    // MARK: - PROPERTIES
    fileprivate struct Storyboard {
        static let cellID = "AlbumCell"
        
    }
    
    var albums: [PhotoAlbum] = []

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIScreen.main.bounds.size.height == 480.0 {
            let flowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            flowLayout.itemSize = CGSize(width: 250.0, height: 300.0)
        }


        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getAlbumsFromServer()
    }

    
    
    func getAlbumsFromServer() {
        ServerManager.sharedManager.getPhotoAlbums(forGroupID: groupID) { (result) in
            
            guard let albums = result as? [PhotoAlbum] else { return }
            
            self.albums = albums
            
            self.collectionView.reloadData()
            
        }
    }
   

}



extension PhotoAlbumsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.cellID, for: indexPath) as! PhotoAlbumCell
        
        cell.album = self.albums[indexPath.row]
        
        return cell
        
    }
    
    
}

extension PhotoAlbumsViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
        
    }

    
}


extension PhotoAlbumsViewController: UICollectionViewDelegate {
    
    
    
}


























