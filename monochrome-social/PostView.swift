//
//  PostView.swift
//  monochrome-social
//
//  Created by Siew Mai Chan on 18/12/2015.
//  Copyright © 2015 Siew Mai Chan. All rights reserved.
//

import UIKit

class PostView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let width = CGFloat(0.5)
        layer.borderColor = Constant.colorShadow.CGColor
        layer.frame = CGRect(x: 0, y: frame.size.height - width, width:  frame.size.width, height: frame.size.height)
        layer.borderWidth = width
    }
}
