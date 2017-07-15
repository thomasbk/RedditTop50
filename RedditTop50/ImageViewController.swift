//
//  ImageViewController.swift
//  RedditTop50
//
//  Created by Thomas Baltodano on 7/14/17.
//  Copyright © 2017 Thomas Baltodano. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    var imageURL:String?
    @IBOutlet var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if let image = imageURL {
            imageView.loadImageUsingCacheWithUrl(urlString: image)
        }
        
    }
    
    
    // Save image to photo album
    @IBAction func saveImage () {
    
        if let image = imageView.image {
            
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    // Finished saving the image
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    // MARK: -
    // MARK: State Restore Delegate Methods
    
    override func encodeRestorableState(with coder: NSCoder) {
        
        if let imageURL = imageURL {
            coder.encode(imageURL)
        }
        
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        
        imageURL = coder.decodeObject() as? String
        
        super.decodeRestorableState(with: coder)
    }
    
    override func applicationFinishedRestoringState() {
        //if let image = imageURL {
        //    imageView.loadImageUsingCacheWithUrl(urlString: image)
        //}
    }

}
