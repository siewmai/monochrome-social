//
//  TestViewController.swift
//  monochrome-social
//
//  Created by Siew Mai Chan on 19/12/2015.
//  Copyright © 2015 Siew Mai Chan. All rights reserved.
//

import UIKit
import ImageSlideshow

class TestViewController: UIViewController {
    
    @IBOutlet weak var imageSlideShow: ImageSlideshow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageSlideShow.backgroundColor = UIColor.blackColor()
        imageSlideShow.pageControlPosition = PageControlPosition.Hidden
        
        imageSlideShow.setImageInputs([ImageSlideShowSource(urlString: "https://s3.amazonaws.com/monochrome/facebook:1505469549781506/-K63uuS8M3H2payu2mDB")!, ImageSlideShowSource(urlString: "https://s3.amazonaws.com/monochrome/facebook:1505469549781506/-K63uuTiA4CVCXdp6gy-")!, ImageSlideShowSource(urlString: "https://s3.amazonaws.com/monochrome/facebook:1505469549781506/-K63uuUJeRwog7I7WACi")!, ImageSlideShowSource(urlString: "https://s3.amazonaws.com/monochrome/facebook:1505469549781506/-K63uuWco77JPJbjklxr")!])

    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
