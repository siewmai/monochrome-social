//
//  PictureTableViewCell.swift
//  monochrome-social
//
//  Created by Siew Mai Chan on 18/12/2015.
//  Copyright © 2015 Siew Mai Chan. All rights reserved.
//

import UIKit

protocol PictureTableViewCellDelegate: class {
    func pictureDidRemove(index:Int)
}

class PictureTableViewCell: UITableViewCell {
    
    weak var delegate : PictureTableViewCellDelegate?
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var removeView: UIView!
    
    var index: Int!
    
    internal var aspectConstraint : NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                pictureImageView.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                pictureImageView.addConstraint(aspectConstraint!)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        removeView.layer.cornerRadius = removeView.frame.width / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //aspectConstraint = nil
    }
    
    func configure(index:Int, image : UIImage) {
        self.index = index
        let aspect = image.size.height / image.size.width
       // imageView?.frame.height = image.size.width * aspect
        aspectConstraint = NSLayoutConstraint(item: pictureImageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: pictureImageView, attribute: NSLayoutAttribute.Width, multiplier: aspect, constant: 0.0)
        
        pictureImageView.image = image
    }
    
    @IBAction func remove(sender: AnyObject) {
        self.delegate?.pictureDidRemove(index)
    }
}
