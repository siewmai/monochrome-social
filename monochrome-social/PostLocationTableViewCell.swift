//
//  PostLocationTableViewCell.swift
//  monochrome-social
//
//  Created by Siew Mai Chan on 24/12/2015.
//  Copyright © 2015 Siew Mai Chan. All rights reserved.
//

import UIKit

class PostLocationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var locationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(post: Post) {
        locationLabel.text = post.location
    }
}
