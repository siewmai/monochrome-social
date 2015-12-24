//
//  Post.swift
//  monochrome-social
//
//  Created by Siew Mai Chan on 18/12/2015.
//  Copyright © 2015 Siew Mai Chan. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    private var _key: String
    private var _creator: String
    private var _status: String?
    private var _pictures: [String]?
    private var _location: String?
    private var _timestamp: NSTimeInterval
    
    var key: String {
        return _key
    }
    
    var creator: String {
        return _creator
    }
    
    var status: String? {
        return _status
    }
    
    var pictures: [String]? {
        return _pictures
    }
    
    var location: String? {
        return _location
    }
    
    var timestamp: NSTimeInterval {
        return _timestamp
    }
    
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        self._key = key
        
        self._creator = dictionary["creator"] as! String
        self._status = dictionary["status"] as? String
        if let pictures = dictionary["pictures"] as? Dictionary<String, String> {
            self._pictures = pictures.sort({ $0.0 < $1.0}).map({ return $0.1 })
        }
        if let location = dictionary["location"] as? Dictionary<String, String> {
            self._location = location["name"]
        }
        self._timestamp = dictionary["timestamp"] as! NSTimeInterval
    }
}
