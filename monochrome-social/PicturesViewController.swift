//
//  PicturesViewController.swift
//  monochrome-social
//
//  Created by Siew Mai Chan on 21/12/2015.
//  Copyright © 2015 Siew Mai Chan. All rights reserved.
//

import UIKit
import ImageSlideshow

public class PicturesViewController: UIViewController {
    
    public var slideshow: ImageSlideshow!
    public var initialPage: Int = 0
    public var inputs: [InputSource]?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        slideshow = ImageSlideshow(frame: self.view.frame);
        slideshow.backgroundColor = UIColor.blackColor()
        slideshow.zoomEnabled = true
        slideshow.contentScaleMode = UIViewContentMode.ScaleAspectFit
        slideshow.pageControlPosition = PageControlPosition.Hidden
        slideshow.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        if let inputs = inputs {
            print(inputs)
            slideshow.setImageInputs(inputs)
        }
        slideshow.frame = self.view.frame
        slideshow.slideshowInterval = 0
        self.view.addSubview(slideshow);
        
        let closeButton = UIButton(frame: CGRectMake(CGRectGetWidth(self.view.frame) - 32, 15, 24, 24))
        closeButton.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
        closeButton.setImage(UIImage(named: "close"), forState: UIControlState.Normal)
        closeButton.addTarget(self, action: "close", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(closeButton)
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        slideshow.setCurrentPage(initialPage, animated: false)
    }
    
    func close() {
        self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
}
