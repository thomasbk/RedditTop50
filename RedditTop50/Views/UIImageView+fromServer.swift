//
//  imageView+fromServer.swift
//  RedditTop50
//
//  Created by Thomas Baltodano on 7/14/17.
//  Copyright © 2017 Thomas Baltodano. All rights reserved.
//

import UIKit
import Foundation

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func loadImageUsingCacheWithUrl(urlString: String) {
        self.image = nil
        
        // check for cache
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        // download image from url
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
            
            guard let image = UIImage(data: data!)
                else { return }
            
            DispatchQueue.main.async(execute: { () -> Void in
                imageCache.setObject(image, forKey: urlString as AnyObject)
                self.image = image
            })
        }).resume()
    }
}
