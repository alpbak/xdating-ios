//
//  ProfileViewListener.swift
//  xDating
//
//  Created by Alpaslan Bak on 24.08.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import Foundation
import Parse
import ParseLiveQuery

class ProfileViewListener {
    var objects: [PFObject] = []
    var subscription: Subscription<PFObject>?
    var subscriber: ParseLiveQuery.Client!
    let query = PFQuery(className: "ProfileView")

    func startListener() {
        guard let user = PFUser.current() else { return }
        
        print("startListener()")
        // initialize the client
        subscriber = ParseLiveQuery.Client()
//        subscriber = ParseLiveQuery.Client(server: "ws://xdating.b4a.app",
//                                           applicationId: "Er4D5b5gWUWuwSkKp3BL3olrJaIlE4kNxNqzoIU8",
//                                           clientKey: "0Sh5MFlkJlCP0bafUnuoYqlfdchDHPZSLJnYe7Vp")
        
//        subscriber = ParseLiveQuery.Client(server: "ws://xdating.b4a.app")

        // initialize subscriber and start subscription
        let query: PFQuery<PFObject> = PFQuery(className: "ProfileView")
            .whereKey("viewed", equalTo: user)
            .whereKeyExists("viewer")
            .whereKey("notSeen", equalTo: true)
        
        subscription = subscriber.subscribe(query)

        // handle the event listenrs.
        _ = subscription?.handleEvent({ (_, event) in
            print("EVENT: ", event)
            switch event {
            case .created(let object):
                self.objects.append(object)
                print("ProfileViewListener - 01: ", self.objects)

            default:
                print("ProfileViewListener - 02")
                break // do other stuff or do nothing
            }
        })
    }
}
