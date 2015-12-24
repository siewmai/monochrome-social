//
//  HomeViewController.swift
//  monochrome-social
//
//  Created by Siew Mai Chan on 18/12/2015.
//  Copyright © 2015 Siew Mai Chan. All rights reserved.
//

import UIKit
import Firebase
import ICSPullToRefresh
import ImageSlideshow

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newFeedsButton: UIButton!
    
    let pagesize:UInt = 20
    var ref: Firebase!
    var handle: UInt!
    
    var uid: String!
    var posts = [Post]()
    var loadedPosts = [Post]()
    
    var initialAdd = true
    var transitionDelegate: ZoomAnimatedTransitioningDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = UIImageView(image: UIImage(named: "home-title"))
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        uid = NSUserDefaults.standardUserDefaults().valueForKey(Constant.keyUID) as! String
        ref = Firebase(url: "\(Config.firebaseUrl)")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        newFeedsButton.hidden = true
        newFeedsButton.layer.cornerRadius = 12.0
        newFeedsButton.layer.shadowColor = Constant.colorShadow.CGColor
        newFeedsButton.layer.shadowOpacity = 0.2
        newFeedsButton.layer.shadowRadius = 1.0
        newFeedsButton.layer.shadowOffset = CGSizeMake(0.0, 0.5)
        
        tableView.separatorStyle = .None
        ActivityIndicatorService.instance.show(view, ignoreInteraction: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        handle = ref.childByAppendingPath("feeds").childByAppendingPath(uid).queryLimitedToLast(pagesize).observeEventType(.ChildAdded, withBlock: { snapshot in
            if let dictionary = snapshot.value as? Dictionary<String, AnyObject> {
                let key = snapshot.key
                if !self.loadedPosts.contains({ $0.key == key }){
                    let post = Post(key: key, dictionary: dictionary)
                    self.loadedPosts.append(post)
                    if !self.initialAdd {
                        self.newFeedsButton.hidden = false
                    }
                }
            }
        })
        if initialAdd {
            ref.childByAppendingPath("feeds").childByAppendingPath(uid).queryLimitedToLast(pagesize).observeSingleEventOfType(.Value, withBlock: { snapshot in
                if snapshot.children.allObjects.count > 0 {
                    self.posts = self.loadedPosts.reverse()
                    self.tableView.separatorStyle = .SingleLine
                    self.tableView.reloadData()
                }
                self.initialAdd = false
                ActivityIndicatorService.instance.hide()
            })
        }
        
        tableView.addInfiniteScrollingWithHandler { () -> () in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                self.loadMore()
                sleep(1)
                dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                    self.tableView.reloadData()
                    self.tableView.infiniteScrollingView?.stopAnimating()
                })
            })
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        ref.removeObserverWithHandle(handle)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        if let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? FeedTableViewCell {
            cell.configure(post)
            cell.selectionStyle = .None
            return cell
        } else {
            let cell = FeedTableViewCell()
            cell.configure(post)
            return cell
        }
    }
    
    func loadMore() {
        if posts.count > 0 {
            let lastKey = posts.last?.key
            var morePosts = [Post]()
            ref.childByAppendingPath("feeds").childByAppendingPath(uid).queryOrderedByKey().queryEndingAtValue(lastKey).queryLimitedToLast(pagesize + 1).observeSingleEventOfType(.Value, withBlock: { snapshot in
                if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                    for snap in snapshots {
                        if let dictionary = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            if key != lastKey {
                                let post = Post(key: key, dictionary: dictionary)
                                morePosts.append(post)
                            }
                        }
                    }
                    self.loadedPosts.insertContentsOf(morePosts, at: 0)
                    self.posts.insertContentsOf(morePosts.reverse(), at: self.posts.count)
                }
            })
        }
    }
    
    @IBAction func loadNewFeeds(sender: AnyObject) {
        posts = loadedPosts.reverse()
        tableView.separatorStyle = .SingleLine
        tableView.reloadData()
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        newFeedsButton.hidden = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constant.segueShowPost {
            if let controller = segue.destinationViewController.contentViewController as? ShowPostViewController {
                if let cell = sender as? UITableViewCell {
                    let indexPath = tableView.indexPathForCell(cell)
                    if let index = indexPath?.row {
                        controller.post = posts[index]
                    }
                }
            }
        }
    }
}
