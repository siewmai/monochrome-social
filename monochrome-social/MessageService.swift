//
//  Message.swift
//  monochrome-social
//
//  Created by Siew Mai Chan on 18/12/2015.
//  Copyright © 2015 Siew Mai Chan. All rights reserved.
//

import Foundation
import UIKit

class MessageService {
    static let instance = MessageService()
    
    func show(title: String?, message: String?, action: String?, controller: UIViewController) {
        let alert = UIAlertController(title: title, message: message
            , preferredStyle: .Alert)
        let action = UIAlertAction(title: action ?? "Close", style: .Default, handler: nil)
        alert.addAction(action)
        
        controller.presentViewController(alert, animated: true, completion: nil)
    }
}
