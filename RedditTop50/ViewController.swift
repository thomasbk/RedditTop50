//
//  ViewController.swift
//  RedditTop50
//
//  Created by Thomas Baltodano on 7/14/17.
//  Copyright © 2017 Thomas Baltodano. All rights reserved.
//

import UIKit


class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    // Set up the URL request
    let redditURL: String = "https://www.reddit.com/top/.json"
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    var errorMessage = ""
    
    var after: String?
    var list: [Dictionary<String, Any>] = []
    //var list: Array<Dictionary> = [] as! Array<Dictionary>
    
    
    
    //var redditList = RedditList()
    
    
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
    
    
    
    
    
    
    
    
    func getData () {
        
        //
        guard let url = URL(string: redditURL) else {
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
            // parse the result as JSON, since that's what the API provides
            do {
                guard let topReddit = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
                    print("error trying to convert data to JSON")
                    return
                }
                // now we have the todo, let's just print it to prove we can access it
                //print("The topReddit is: " + topReddit.description)
                
                // the todo object is a dictionary
                // so we just access the title using the "title" key
                // so check for a title and print it if we have one
                guard let title = topReddit["kind"] as? String else {
                    print("Could not get todo title from JSON")
                    return
                }
                
                print("The title is: " + title)
                
                let dataDictionary: Dictionary = topReddit["data"] as! Dictionary<String, Any>
                self.after = dataDictionary["after"] as? String
                self.list = dataDictionary["children"] as! Array
                
                //print(self.after!)
                //print(self.list)
                
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
        
        let post = list[indexPath.row] //as! Dictionary<String,String>
        //print(post)
        let postData = post["data"] as? [String:Any]
        print("POOP")
        print(postData!)
        
        
        cell.titleLabel.text = postData?["title"] as? String
        
        let time = getElapsedTime(postTime: (postData?["created"] as? NSNumber)!)
        cell.dateLabel.text = " \(time) ago by \(String(describing: postData?["author"] as! String))"
        
        cell.commentsLabel.text = "\(String(describing: postData?["num_comments"] as! NSNumber)) comments"
        
        if let image = (postData?["thumbnail"] as? String) {
            if(image == "default" || image == "nsfw") {
                cell.myImageView.image = nil
            }
            else {
                cell.myImageView.loadImageUsingCacheWithUrl(urlString: image)
            }
        }
        
        
        return cell
    }
    
    
    
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
        
    }


}

