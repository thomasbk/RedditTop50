//
//  RedditTableViewCell.swift
//  RedditTop50
//
//  Created by Thomas Baltodano on 7/14/17.
//  Copyright © 2017 Thomas Baltodano. All rights reserved.
//

import UIKit

class RedditTableViewCell: UITableViewCell {

    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var commentsLabel: UILabel!
    @IBOutlet var myImageView: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
