//
//  CreatePostTableViewController.swift
//  monochrome-social
//
//  Created by Siew Mai Chan on 18/12/2015.
//  Copyright © 2015 Siew Mai Chan. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps

class CreatePostTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, StatusTableViewCellDelegate, LocationTableViewCellDelegate, PictureTableViewCellDelegate {
    
    @IBOutlet weak var publishButton: UIBarButtonItem!
    @IBOutlet weak var addPictureButton: UIBarButtonItem!
    
    var uid: String!
    var ref: Firebase!
    var followerSnapshot: FDataSnapshot!
    var followerHandle: UInt!
    
    var status = ""
    var location: Place?
    var pictures = [UIImage]()
    var imagePicker: UIImagePickerController!
    
    var isInsertTag = false
    
    var placePicker: GMSPlacePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = NSUserDefaults.standardUserDefaults().valueForKey(Constant.keyUID) as! String
        ref = Firebase(url: "\(Config.firebaseUrl)")

        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        updatePublishButtonState()
        
        let center = CLLocationCoordinate2DMake(37.788204, -122.411937)
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        placePicker = GMSPlacePicker(config: config)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if let nav = self.navigationController {
                nav.view.frame.size.height -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if let nav = self.navigationController {
                nav.view.frame.size.height += keyboardSize.height
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        followerHandle = ref.childByAppendingPath("followers").childByAppendingPath(uid).observeEventType(.Value, withBlock: { snapshot in
            self.followerSnapshot = snapshot
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        ref.removeObserverWithHandle(followerHandle)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if location != nil {
                return 1
            } else {
                return 0
            }
        case 2:
            return pictures.count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("StatusTableViewCell", forIndexPath: indexPath) as! StatusTableViewCell
            cell.delegate = self
            cell.configure(status)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("LocationTableViewCell", forIndexPath: indexPath) as! LocationTableViewCell
            cell.delegate = self
            cell.configure(location)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("PictureTableViewCell", forIndexPath: indexPath) as! PictureTableViewCell
            let index = indexPath.row
            let picture = pictures[index]
            cell.delegate = self
            cell.configure(index, image: picture)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    @IBAction func addPicture(sender: UIBarButtonItem) {
        let options = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let library = UIAlertAction(title: "Choose from library", style: UIAlertActionStyle.Default) { action in
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        
        let takePhoto = UIAlertAction(title: "Take photo", style: UIAlertActionStyle.Default) { action in
            self.imagePicker.sourceType = .Camera
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        options.addAction(library)
        options.addAction(takePhoto)
        options.addAction(cancel)
        
        options.modalPresentationStyle = .Popover
        
        let presentationController = options.popoverPresentationController
        presentationController?.barButtonItem = sender
        
        presentViewController(options, animated: true, completion: nil)
    }
    
    @IBAction func getLocation(sender: UIBarButtonItem) {
        
        placePicker?.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            if let place = place {
                self.location = Place(id: place.placeID, name: (place.name != nil) ? place.name : "", address: (place.formattedAddress != nil) ? place.formattedAddress : "")
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func cancel(sender: AnyObject) {
        presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func publish(sender: AnyObject) {
        ActivityIndicatorService.instance.show(view, ignoreInteraction: true)
        uploadPictures { firebasePictures in
            var post: Dictionary<String, AnyObject> = [
                "creator": self.uid,
                "status": self.status,
                "pictures": firebasePictures,
                "timestamp": FirebaseServerValue.timestamp()
            ]
            if self.location != nil {
                let location: Dictionary<String, String> = [
                    "id": self.location!.id,
                    "name": self.location!.name,
                    "address": self.location!.address
                ]
                
                post["location"] = location
            }
            
            let postRef = self.ref.childByAppendingPath("posts").childByAppendingPath(self.uid).childByAutoId()
            let fanoutObject = self.getFanoutObject(self.uid, key: postRef.key, post: post)
            
            postRef.setValue(post)
            self.ref.updateChildValues(fanoutObject)
            
            ActivityIndicatorService.instance.hide()
            self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func getFanoutObject(uid: String, key: String, post: Dictionary<String, AnyObject>) -> Dictionary<String, AnyObject> {
        var fanoutObject = Dictionary<String, AnyObject>()
        fanoutObject["/feeds/\(uid)/\(key)"] = post
        
        if let snapshots = followerSnapshot.children.allObjects as? [FDataSnapshot] {
            for snap in snapshots {
                fanoutObject["/feeds/\(snap.key)/\(key)"] = post
            }
        }
        return fanoutObject
    }
    
    func uploadPictures(completion: (firebasePictures: Dictionary<String, String>) -> Void) {
        var firebasePictures = Dictionary<String, String>()
        if self.pictures.count > 0 {
            
            for picture in self.pictures {
                let imageData = UIImageJPEGRepresentation(picture, 0.2)
                let pictureRef = ref.childByAppendingPath("pictures").childByAppendingPath(uid).childByAutoId()
                
                AmazonS3Service.instance.uploadProfileImage(imageData!, folderName: uid, fileName: pictureRef.key, completion: { nsurl in
                    pictureRef.setValue(nsurl.URLString)
                    firebasePictures[pictureRef.key] = nsurl.URLString
                    if firebasePictures.count == self.pictures.count {
                        completion(firebasePictures: firebasePictures)
                    }
                })
            }
        } else {
            completion(firebasePictures: firebasePictures)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.pictures.append(image)
            tableView.reloadData()
            
            let indexPath = NSIndexPath(forRow: self.pictures.count - 1, inSection: 2)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            
            updateAddPictureButtonState()
            updatePublishButtonState()
        }
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func heightDidChange(newHeight: CGFloat) {
        UIView.setAnimationsEnabled(false)
        tableView?.beginUpdates()
        tableView?.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    func statusDidEndEditing(newStatus: String) {
        status = newStatus
        tableView.reloadData()
        
        updatePublishButtonState()
    }
    
    func statusDidBeginEditing() {
        publishButton.enabled = false
    }
    
    func insertTagDidBegin() {
        isInsertTag = true
        tableView.reloadData()
    }
    
    func pictureDidRemove(index: Int) {
        pictures.removeAtIndex(index)
        tableView.reloadData()
        
        updateAddPictureButtonState()
        updatePublishButtonState()
    }
    
    func locationDidSelect(place: Place) {
        location = place
        tableView.reloadData()
    }
    
    func locationDidRemove() {
        location = nil
        tableView.reloadData()
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    func updatePublishButtonState() {
        publishButton.enabled = !(status.isEmpty && pictures.count == 0)
    }
    
    func updateAddPictureButtonState() {
        addPictureButton.enabled = pictures.count < 4
    }
}