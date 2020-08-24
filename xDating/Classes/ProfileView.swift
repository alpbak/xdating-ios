//
//  ProfileView.swift
//  xDating
//
//  Created by Alpaslan Bak on 23.08.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import Foundation

import Parse

class ProfileView: PFObject, PFSubclassing {
    @NSManaged var viewed: PFObject?
    @NSManaged var viewer: PFObject?
    @NSManaged var agent: NSNumber?
    @NSManaged var viewes: NSNumber?
    @NSManaged var notSeen: NSNumber?

    class func parseClassName() -> String {
        return "ProfileView"
    }
}
