//
//  PostStatusTableViewCell.swift
//  monochrome-social
//
//  Created by Siew Mai Chan on 24/12/2015.
//  Copyright © 2015 Siew Mai Chan. All rights reserved.
//

import UIKit
import ActiveLabel

protocol PostStatusTableViewCellDelegate: class {
    func handleHashtagTap(hashtag: String)
}

class PostStatusTableViewCell: UITableViewCell {

    weak var delegate : PostStatusTableViewCellDelegate?
    @IBOutlet weak var statusActiveLabel: ActiveLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        statusActiveLabel.hashtagColor = Constant.colorHighlight
        statusActiveLabel.handleHashtagTap { hashtag in
            self.delegate?.handleHashtagTap(hashtag)
        }
    }
    
    func configure(post: Post) {
        statusActiveLabel.text = post.status
    }
}
