//
//  StatusTableViewCell.swift
//  monochrome-social
//
//  Created by Siew Mai Chan on 18/12/2015.
//  Copyright © 2015 Siew Mai Chan. All rights reserved.
//

import UIKit

protocol StatusTableViewCellDelegate: class {
    func heightDidChange(newHeight: CGFloat)
    func statusDidEndEditing(newStatus: String)
    func statusDidBeginEditing()
    func insertTagDidBegin()
}

class StatusTableViewCell: UITableViewCell, UITextViewDelegate{
    
    weak var delegate : StatusTableViewCellDelegate?
    @IBOutlet weak var textView: UITextView!
    var placeholderLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
        
        placeholderLabel = UILabel()
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPointMake(5, textView.font!.pointSize / 2)
        placeholderLabel.textColor = UIColor.lightGrayColor()
        placeholderLabel.text = "What's happening"
        placeholderLabel.font = textView.font
        placeholderLabel.sizeToFit()
    }
    
    func configure(status: String) {
        textView.text = status
    }
    
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = !textView.text.isEmpty
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width,
            height: CGFloat.max))
        
        // Resize the cell only when cell's size is changed
        if size.height != newSize.height {
            self.delegate?.heightDidChange(newSize.height)
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        self.delegate?.statusDidEndEditing(textView.text)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.delegate?.statusDidBeginEditing()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "#" {
            self.delegate?.insertTagDidBegin()
        }
        return true
    }
}