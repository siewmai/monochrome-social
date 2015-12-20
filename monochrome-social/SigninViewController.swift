//
//  SigninViewController.swift
//  monochrome-social
//
//  Created by Siew Mai Chan on 18/12/2015.
//  Copyright © 2015 Siew Mai Chan. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class SigninViewController: UIViewController {
    var ref: Firebase!
    @IBOutlet weak var signinView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Firebase(url: "\(Config.firebaseUrl)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if NSUserDefaults.standardUserDefaults().valueForKey(Constant.keyUID) != nil {
            signinView.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if NSUserDefaults.standardUserDefaults().valueForKey(Constant.keyUID) != nil {
            self.performSegueWithIdentifier(Constant.segueMainController, sender: nil)
        }
    }

    @IBAction func signinWithFacebook(sender: AnyObject) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email", "public_profile", "user_friends"], fromViewController: self) { facebookResult, facebookError in
            if facebookError != nil {
                MessageService.instance.show(nil, message: "Error while connecting to Facebook", action: "Close", controller: self)
            } else if facebookResult.isCancelled {
                print("cancel")
            } else {
                ActivityIndicatorService.instance.show(self.view, ignoreInteraction: true)
                let fbtoken = FBSDKAccessToken.currentAccessToken().tokenString
                self.ref.authWithOAuthProvider("facebook", token: fbtoken, withCompletionBlock: { error, authData in
                    if error != nil {
                        ActivityIndicatorService.instance.hide()
                        MessageService.instance.show(nil, message: "Error while connecting to Monochrome", action: "Close", controller: self)
                    } else {
                        self.processLogin(fbtoken, authData: authData)
                    }
                })

            }
        }
    }
    
    func processLogin(fbtoken: String, authData: FAuthData) {
        ref.childByAppendingPath("profiles").childByAppendingPath(authData.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.value is NSNull {
                self.createProfile(fbtoken, authData: authData)
            } else {
                NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: Constant.keyUID)
                self.performSegueWithIdentifier(Constant.segueMainController, sender: nil)
                ActivityIndicatorService.instance.hide()
            }
        })
    }

    func createProfile(fbtoken: String, authData: FAuthData) {
        let uid = authData.uid
        let displayName = authData.providerData["displayName"] as! String
        let email = authData.providerData["email"] as! String
        let bio = ""
        let city = ""
        var imageUrl = ""
        if let url = authData.providerData["profileImageURL"] as? String {
            imageUrl = url // 100x100 by default
        }
        let request = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["fields": "url", "redirect": false, "type": "large"], tokenString: fbtoken, version: nil, HTTPMethod: "GET")
        request.startWithCompletionHandler { connection, result, error in
            if error == nil {
                if let data = result["data"] as? Dictionary<String, AnyObject> {
                    if let url = data["url"] as? String {
                        // Use 200x200 if succeed
                        imageUrl = url
                    }
                }
            }
            let data: Dictionary<String, AnyObject> = [
                "provider": "facebook",
                "displayName":displayName,
                "email":email,
                "city": city,
                "bio": bio,
                "imageUrl": imageUrl
            ]
            self.ref.childByAppendingPath("profiles").childByAppendingPath(uid).setValue(data)
            NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: Constant.keyUID)
            self.performSegueWithIdentifier(Constant.segueMainController, sender: nil)
            ActivityIndicatorService.instance.hide()
        }
    }
}
