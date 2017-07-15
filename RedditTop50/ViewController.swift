//
//  ViewController.swift
//  RedditTop50
//
//  Created by Thomas Baltodano on 7/14/17.
//  Copyright © 2017 Thomas Baltodano. All rights reserved.
//

import UIKit


class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    var errorMessage = ""
    
    var after: String? = ""
    var list: [Dictionary<String, Any>] = []
    let redditURL: String = "https://www.reddit.com/top/.json"
    
    let MAX_COUNT = 50
    
    var selectedImageURL: String?
    
    
    @IBOutlet var tableView: UITableView!
    let cellIdentifier = "redditCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        getData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! ImageViewController
        viewController.imageURL = selectedImageURL
     }
 
    
    
    
    
    func getData () {
        
        guard let url = URL(string: "\(redditURL)\(String(describing: after!))" ) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling Reddit")
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON
            do {
                guard let topReddit = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
                    print("error trying to convert data to JSON")
                    return
                }
                
                guard let kind = topReddit["kind"] as? String else {
                    print("Could not get reddit kind from JSON")
                    return
                }
                
                print("The kind is: " + kind)
                
                let dataDictionary: Dictionary = topReddit["data"] as! Dictionary<String, Any>
                if(self.list.count > 0) {
                    self.list.append(contentsOf: dataDictionary["children"] as! Array)
                }
                else {
                    self.list = dataDictionary["children"] as! Array
                }
                // set the after text for next load
                self.after = "?after=\(String(describing: dataDictionary["after"] as! String))"
                
                // reload data on main thread
                DispatchQueue.main.async(execute: { () -> Void in
                    self.tableView.reloadData()
                })
                
                
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        
        task.resume()
        
    }
    
    
    
    
    
    
    
    // MARK: -
    // MARK: Table View Datasource Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = list.count
        return numberOfRows
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath) as! RedditTableViewCell
        
        let post = list[indexPath.row]
        let postData = post["data"] as? [String:Any]
        //print(postData!)
        
        
        cell.titleLabel.text = postData?["title"] as? String
        
        let time = getElapsedTime(postTime: (postData?["created"] as? NSNumber)!)
        cell.dateLabel.text = " \(time) ago by \(String(describing: postData?["author"] as! String))"
        
        cell.commentsLabel.text = "\(String(describing: postData?["num_comments"] as! NSNumber)) comments"
        
        if let image = (postData?["thumbnail"] as? String) { // check if it's a valid url
            if(verifyUrl(urlString: image)) {
                cell.myImageView.loadImageUsingCacheWithUrl(urlString: image)
            }
            else {
                //image == "default" || image == "nsfw" // this are other data types that aren't images
                cell.myImageView.image = nil
            }
        }
        
        // load next 25 until it reaches 50
        if(indexPath.row+1 == list.count && list.count < MAX_COUNT) {
            getData()
        }
        
        
        return cell
    }
    
    
    // Checks if a given string is a URL
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url  = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    
    // Gets elapsed time between given value and now
    func getElapsedTime (postTime: NSNumber) -> String {
        var result = "hour"
        var number = 0
        
        let date = NSDate()
        let timestamp = Int(floor(date.timeIntervalSince1970))
        
        number = timestamp - postTime.intValue
        
        number = number / 60 //minutes
        number = number / 24 //hours
        
        if(number > 1 || number < 1) {
            result = "hours"
        }
        
        print("\(timestamp) now")
        print("\(postTime) post time")
        
        print("\(number) \(result)")
        
        return "\(number) \(result)"
    }
    
    
    
    // MARK: -
    // MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let post = list[indexPath.row]
        let postData = post["data"] as? [String:Any]
        
        let postHint = postData?["post_hint"] as? String
        
        if(postHint == "image") {
            selectedImageURL = postData?["url"] as? String
            performSegue(withIdentifier: "imgSegue", sender: nil)
        }
        else {
            
            let optionMenu = UIAlertController(title: nil, message:
                "This post is not an image, would you like to open it in your browser?", preferredStyle: .actionSheet)
            optionMenu.popoverPresentationController?.sourceView = self.view
            
            
            let showBrowser = UIAlertAction(title: "Show in browser", style: .default) { action -> Void in
                
                let url = NSURL(string: (postData?["url"] as? String)!)!
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url as URL)
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert : UIAlertAction!) in
            }
            optionMenu.addAction(showBrowser)
            optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true, completion: nil)
        }
        
    }
    
    
    
    // MARK: -
    // MARK: State Restore Delegate Methods
    
    override func encodeRestorableState(with coder: NSCoder) {
        
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {

        super.decodeRestorableState(with: coder)
    }
    
    override func applicationFinishedRestoringState() {
        
    }


}

