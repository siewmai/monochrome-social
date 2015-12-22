//
//  ImageSlideShowSource.swift
//  monochrome-social
//
//  Created by Siew Mai Chan on 21/12/2015.
//  Copyright © 2015 Siew Mai Chan. All rights reserved.
//

import Foundation
import AlamofireImage
import ImageSlideshow

public class ImageSlideShowSource: NSObject, InputSource {
    let url: NSURL!
    let picturePlaceholder = UIImage(named: "picture-placeholder")!
    
    public init(url: NSURL) {
        self.url = url
    }
    
    public init?(urlString: String) {
        if let validUrl = NSURL(string: urlString) {
            self.url = validUrl
            super.init()
        } else {
            // working around Swift 1.2 failure initializer bug
            self.url = NSURL(string: "")!
            super.init()
            return nil
        }
    }
    
    @objc public func setToImageView(imageView: UIImageView) {
        imageView.af_setImageWithURL(url, placeholderImage: picturePlaceholder)
    }
}