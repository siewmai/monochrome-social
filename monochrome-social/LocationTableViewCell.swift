//
//  LocationTableViewCell.swift
//  monochrome-social
//
//  Created by Siew Mai Chan on 18/12/2015.
//  Copyright © 2015 Siew Mai Chan. All rights reserved.
//

import UIKit

protocol LocationTableViewCellDelegate: class {
    func locationDidRemove()
}

class LocationTableViewCell: UITableViewCell {
    
    var delegate: LocationTableViewCellDelegate?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    
    func configure(location:Place?) {
        if location != nil {
            nameLabel.text = location!.name
            addressLabel.text = location!.address
        }
    }
    
    @IBAction func remove(sender: AnyObject) {
        self.delegate?.locationDidRemove()
    }
}

