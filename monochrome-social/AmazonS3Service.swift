//
//  AmazonS3Service.swift
//  monochrome-social
//
//  Created by Siew Mai Chan on 19/12/2015.
//  Copyright © 2015 Siew Mai Chan. All rights reserved.
//

import Foundation
import AmazonS3RequestManager

class AmazonS3Service {
    static let instance = AmazonS3Service()
    
    private let amazonS3Manager: AmazonS3RequestManager!
    
    init() {
        amazonS3Manager = AmazonS3RequestManager(bucket: Config.amazonBucket,
            region: Config.amazonRegion,
            accessKey: Config.amazonAccessKey,
            secret: Config.amazonSecretKey)
    }
    
    func uploadProfileImage(imageData: NSData, folderName: String, fileName: String, completion: (nsurl: NSURL) -> Void){
        amazonS3Manager.putObject(imageData, destinationPath: "\(folderName)/\(fileName)").responseS3Data { response in
            completion(nsurl: (response.response?.URL)!)
        }
    }
}
