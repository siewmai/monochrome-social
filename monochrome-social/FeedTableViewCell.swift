//
//  FeedTableViewCell.swift
//  monochrome-social
//
//  Created by Siew Mai Chan on 18/12/2015.
//  Copyright © 2015 Siew Mai Chan. All rights reserved.
//

import UIKit
import AlamofireImage
import AFDateHelper
import Firebase

class FeedTableViewCell: UITableViewCell {
    
    var ref: Firebase!
    
    @IBOutlet weak var creatorImageView: ProfileImageView!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var pictureContainerView: UIView!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var numberOfPictureView: UIView!
    @IBOutlet weak var numberOfPictureLabel: UILabel!
    
    let creatorImagePlaceholder = UIImage(named: "person")!
    let picturePlaceholder = UIImage(named: "picture-placeholder")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ref = Firebase(url: "\(Config.firebaseUrl)")
    }
    
    override func drawRect(rect: CGRect) {
        numberOfPictureView.layer.cornerRadius = numberOfPictureView.frame.size.width / 2
    }
    
    func configure(post: Post) {
        ref.childByAppendingPath("profiles").childByAppendingPath(post.creator).observeEventType(.Value, withBlock: { snapshot in
            if let profile = snapshot.value as? Dictionary<String, String> {
                self.creatorNameLabel.text = profile["displayName"]!
                
                if let imageUrl = profile["imageUrl"] {
                    let url = NSURL(string: imageUrl)!
                    self.creatorImageView.af_setImageWithURL(url, placeholderImage: self.creatorImagePlaceholder, imageTransition: .CrossDissolve(0.2))
                }
            }
        })

        let date = NSDate(timeIntervalSince1970: post.timestamp / 1000)
        timestampLabel.text = date.toString(dateStyle: .MediumStyle, timeStyle: .ShortStyle, doesRelativeDateFormatting: true)
        
        if let status = post.status where status != "" {
            statusLabel.text = status
            statusLabel.hidden = false
        } else {
            statusLabel.hidden = true
        }
        
        numberOfPictureView.hidden = true
        pictureContainerView.hidden = true
        if let pictures = post.pictures where pictures.count > 0 {
            pictureContainerView.hidden = false
            let url = NSURL(string: pictures[0])!
            pictureImageView.af_setImageWithURLRequest(NSURLRequest(URL: url), placeholderImage: self.picturePlaceholder, filter: nil, imageTransition: .CrossDissolve(0.2), completion: { response in
                if pictures.count > 1 {
                    self.numberOfPictureLabel.text = "\(pictures.count)"
                    self.numberOfPictureView.hidden = false
                }
            })
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        creatorImageView.af_cancelImageRequest()
        creatorImageView.layer.removeAllAnimations()
        creatorImageView.image = nil
        
        pictureImageView.af_cancelImageRequest()
        pictureImageView.layer.removeAllAnimations()
        pictureImageView.image = nil
    }
}
