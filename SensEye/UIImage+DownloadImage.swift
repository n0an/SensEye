//
//  UIImage+DownloadImage.swift
//  SensEye
//
//  Created by Anton Novoselov on 25/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func loadImageWithURL(url: URL) -> URLSessionDownloadTask {
        
        let session = URLSession.shared
        
        let downloadTask = session.downloadTask(with: url) { [weak self] (localFile, response, error) -> Void in
            if error == nil && localFile != nil {
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        
                        DispatchQueue.main.async {
                            if let strongSelf = self {
                                strongSelf.image = image
                            }
                        }
                        
                        
//                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                            if let strongSelf = self {
//                                strongSelf.image = image
//                            }
//                        })
                    }
                }
            }
        }
        
        downloadTask.resume()
        
        
        
        return downloadTask
    }
    
    
    
}


