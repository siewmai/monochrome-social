//
//  ShowPostViewController.swift
//  monochrome-social
//
//  Created by Siew Mai Chan on 22/12/2015.
//  Copyright © 2015 Siew Mai Chan. All rights reserved.
//

import UIKit
import ImageSlideshow

class ShowPostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PostStatusTableViewCellDelegate, PostPicturesTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    var likeBarButton: UIBarButtonItem!
    var commentBarButton: UIBarButtonItem!
    var shareBarButton: UIBarButtonItem!
    
    var post: Post!
    var comments = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44

        comments = ["Looks good", "Hello World"]
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override var inputAccessoryView: UIView {
        let toolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, view.frame.size.width, 50))
        toolbar.barStyle = UIBarStyle.Default
        toolbar.barTintColor = UIColor.whiteColor()
        
        likeBarButton = UIBarButtonItem(image: UIImage(named: "like-outline"), style: .Plain, target: self, action: Selector("like:"))
        likeBarButton.tintColor = UIColor.darkGrayColor()
        
        commentBarButton = UIBarButtonItem(image: UIImage(named: "comments"), style: .Plain, target: self, action: Selector("comment:"))
        commentBarButton.tintColor = UIColor.darkGrayColor()
        
        shareBarButton = UIBarButtonItem(image: UIImage(named: "share"), style: .Plain, target: self, action: Selector("share:"))
        shareBarButton.tintColor = UIColor.darkGrayColor()
        
        toolbar.items = [likeBarButton, commentBarButton, shareBarButton]
        return toolbar
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if let status = post.status where status != "" {
                return 1
            } else {
                return 0
            }
        case 2:
            if let location = post.location where location != "" {
                return 1
            } else {
                return 0
            }
        case 3:
            if post.pictures != nil {
                return 1
            } else {
                return 0
            }
        case 4:
            return 1
        case 5:
            return comments.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("PostCreatorTableViewCell") as! PostCreatorTableViewCell
            cell.configure(post)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("PostStatusTableViewCell") as! PostStatusTableViewCell
            cell.delegate = self
            cell.configure(post)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("PostLocationTableViewCell") as! PostLocationTableViewCell
            cell.configure(post)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("PostPicturesTableViewCell") as! PostPicturesTableViewCell
            cell.delegate = self
            cell.configure(indexPath.row, pictures: post.pictures)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier("PostResponseTableViewCell")
            return cell!
        case 5:
            let cell = tableView.dequeueReusableCellWithIdentifier("PostCommentTableViewCell") as! PostCommentTableViewCell
            cell.commentLabel.text = comments[indexPath.row]
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func handleHashtagTap(hashtag: String) {
        print("Controller handle \(hashtag)")
    }
    
    func presentPicturesSlideShow(selectedIndex: Int) {
        let picturesViewController = PicturesViewController()
        if let urls = post.pictures {
            var inputs = [ImageSlideShowSource]()
            for url in urls {
                inputs.append(ImageSlideShowSource(urlString: url)!)
            }
            picturesViewController.inputs = inputs
            picturesViewController.initialPage = selectedIndex
            self.presentViewController(picturesViewController, animated: true, completion: nil)
        }
    }
}
