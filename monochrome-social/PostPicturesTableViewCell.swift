//
//  PostPicturesTableViewCell.swift
//  monochrome-social
//
//  Created by Siew Mai Chan on 22/12/2015.
//  Copyright © 2015 Siew Mai Chan. All rights reserved.
//

import UIKit

protocol PostPicturesTableViewCellDelegate: class {
    func presentPicturesSlideShow(selectedIndex: Int)
}

class PostPicturesTableViewCell: UITableViewCell {
    
    weak var delegate : PostPicturesTableViewCellDelegate?
    
    @IBOutlet weak var forthImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var leftStackView: UIStackView!
    @IBOutlet weak var rightStackView: UIStackView!
    
    var container = [UIImageView]()
    
    let picturePlaceholder = UIImage(named: "picture-placeholder")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let firstImageViewTapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "firstImageViewTapped:")
        firstImageView.addGestureRecognizer(firstImageViewTapped)
        
        let secondImageViewTapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "secondImageViewTapped:")
        secondImageView.addGestureRecognizer(secondImageViewTapped)
        
        let thirdImageViewTapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "thirdImageViewTapped:")
        thirdImageView.addGestureRecognizer(thirdImageViewTapped)
        
        let forthImageViewTapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "forthImageViewTapped:")
        forthImageView.addGestureRecognizer(forthImageViewTapped)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        firstImageView.af_cancelImageRequest()
        firstImageView.layer.removeAllAnimations()
        firstImageView.image = nil
        
        secondImageView.af_cancelImageRequest()
        secondImageView.layer.removeAllAnimations()
        secondImageView.image = nil
        
        thirdImageView.af_cancelImageRequest()
        thirdImageView.layer.removeAllAnimations()
        thirdImageView.image = nil
        
        forthImageView.af_cancelImageRequest()
        forthImageView.layer.removeAllAnimations()
        forthImageView.image = nil
        
        container.removeAll()
    }

    func configure(index:Int, var pictures: [String]?) {
        firstImageView.hidden = true
        secondImageView.hidden = true
        thirdImageView.hidden = true
        forthImageView.hidden = true
        leftStackView.hidden = true
        rightStackView.hidden = true
       
        if pictures != nil {
            rightStackView.hidden = false
            
            if pictures!.count == 1 {
                container = [forthImageView]
            } else if pictures!.count == 2 {
                container = [forthImageView, secondImageView]
            } else if pictures!.count == 3 {
                leftStackView.hidden = false
                container = [forthImageView, secondImageView, thirdImageView]
            } else if pictures!.count == 4 {
                leftStackView.hidden = false
                container = [forthImageView, thirdImageView, secondImageView, firstImageView]
            }
            
            for imageView in container {
                if let picture = pictures?.popLast() {
                    let url = NSURL(string: picture)!
                    imageView.af_setImageWithURLRequest(NSURLRequest(URL: url), placeholderImage: self.picturePlaceholder, filter: nil, imageTransition: .CrossDissolve(0.5), completion: { response in
                        imageView.hidden = false
                    })
                }
            }
        }
    }
    
    func firstImageViewTapped(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            let index = container.count - container.indexOf(firstImageView)! - 1
            self.delegate?.presentPicturesSlideShow(index)
        }
    }
    
    func secondImageViewTapped(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            let index = container.count - container.indexOf(secondImageView)! - 1
            self.delegate?.presentPicturesSlideShow(index)
        }
    }
    
    func thirdImageViewTapped(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            let index = container.count - container.indexOf(thirdImageView)! - 1
            self.delegate?.presentPicturesSlideShow(index)
        }
    }
    
    func forthImageViewTapped(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            let index = container.count - container.indexOf(forthImageView)! - 1
            self.delegate?.presentPicturesSlideShow(index)
        }
    }

}
