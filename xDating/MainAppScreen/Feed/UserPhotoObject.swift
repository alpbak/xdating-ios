//
//  UserPhotoObject.swift
//  xDating
//
//  Created by Alpaslan Bak on 22.07.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit
import Parse
class UserPhotoObject: PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        "UserPhoto"
    }
    
    
    @NSManaged var imageFile: PFFileObject
    @NSManaged var user: PFUser
    @NSManaged var isVideo: Bool
    
    
    init(pfObject: PFObject) {
        super.init()
        self.imageFile = pfObject.object(forKey: "imageFile") as! PFFileObject
        self.user = pfObject.object(forKey: "user") as! PFUser
        self.isVideo = pfObject.object(forKey: "isVideo") as! Bool
        
//        pfObject.fetchInBackground { (obj, error) in
//            print("UserPhotoObject")
//        }
    }

    override init() {
        super.init()
    }
    
}
