//
//  PostCreatorTableViewCell.swift
//  monochrome-social
//
//  Created by Siew Mai Chan on 24/12/2015.
//  Copyright © 2015 Siew Mai Chan. All rights reserved.
//

import UIKit
import Firebase

class PostCreatorTableViewCell: UITableViewCell {
    
    var ref: Firebase!
    
    @IBOutlet weak var creatorImageView: ProfileImageView!
    @IBOutlet weak var creatorDisplayNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    let creatorImagePlaceholder = UIImage(named: "person")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ref = Firebase(url: "\(Config.firebaseUrl)")
    }

    func configure(post: Post) {
        ref.childByAppendingPath("profiles").childByAppendingPath(post.creator).observeEventType(.Value, withBlock: { snapshot in
            if let profile = snapshot.value as? Dictionary<String, String> {
                self.creatorDisplayNameLabel.text = profile["displayName"]!
                
                if let imageUrl = profile["imageUrl"] {
                    let url = NSURL(string: imageUrl)!
                    self.creatorImageView.af_setImageWithURL(url, placeholderImage: self.creatorImagePlaceholder, imageTransition: .CrossDissolve(0.2))
                }
            }
        })
        
        let date = NSDate(timeIntervalSince1970: post.timestamp / 1000)
        timestampLabel.text = date.toString(dateStyle: .MediumStyle, timeStyle: .ShortStyle, doesRelativeDateFormatting: true)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        creatorImageView.af_cancelImageRequest()
        creatorImageView.layer.removeAllAnimations()
        creatorImageView.image = nil
    }
}
