//
//  ParseUtilities.swift
//  xDating
//
//  Created by Alpaslan Bak on 20.07.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import Foundation
import Parse
import UIKit
import ParseLiveQuery

var blockedUsers:[String] = []

var chatUserPhotoUrls = [String:String]()

var subscription: Subscription<PFObject>?
let liveQueryClient = ParseLiveQuery.Client()

func isUserLoggedIn() -> Bool {
    if PFUser.current()?.email == nil{
        return false
    }
    else{
        return true
    }
}

func currentUserEmail() -> String {
    return PFUser.current()?.email ?? "none"
}

func currentUserName() -> String {
    return PFUser.current()?["name"] as! String
}

func signUp(emailStr:String, passwordStr:String, nameStr:String, isFemale:Bool, age:Int, completion: @escaping(_ success: Bool, _ error:Error?) -> Void) {
    let user = PFUser()
    user.username = emailStr
    user.password = passwordStr
    user.email = emailStr
    user["name"] = nameStr
    user["isFemale"] = isFemale
    user["age"] = age
    
    user.signUpInBackground { (succeeded, error) in
        if let error = error {
            print("User SignUp Error: ", error.localizedDescription)
            completion(false, error)
        } else {
            signupChat(userEmail: emailStr, userPassword: QBDEFAULTPASSWORD)
            completion(true, nil)
        }
    }
}

func login(emailStr:String, passwordStr:String, completion: @escaping(_ success: Bool, _ error:Error?) -> Void){
    PFUser.logInWithUsername(inBackground: emailStr, password: passwordStr) { (user, error) in
        if let error = error {
            print("login-error: ", error.localizedDescription)
            completion(false, error)
        } else {
            checkQBAccountExists(userEmail: currentUserEmail())
            completion(true, nil)
        }
    }
}

func getLocation(str:String, completion: @escaping(_ success: Bool, _ objects: [PFObject]?) -> Void){
    
    let capStr = str.capitalized
    
    let query = PFQuery(className:"Continentscountriescities_City")
    //query.whereKey("name", contains: str)
    query.whereKey("name", hasPrefix: capStr)
    //query.whereKey("name", matchesText: str)
    query.includeKey("country")
    query.limit = 10
    query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
        if let error = error {
            print("getLocation-error: ", error.localizedDescription)
            completion(false, objects)
        } else if let objects = objects {
            completion(true, objects)
        }
    }
}

func uploadUserVideo(videoData:NSData){
    print("uploadUserVideo")
    if let imageFile = PFFileObject(name: "video.mp4", data: videoData as Data){
        let userPhoto = PFObject(className:"UserPhoto")
        userPhoto["imageFile"] = imageFile
        userPhoto["user"] = PFUser.current()
        userPhoto["isVideo"] = true
        userPhoto.saveInBackground { (success, error) in
            print("USER VIDEO SAVED! - error: ", (error?.localizedDescription ?? "") as String)
            addPhotoRelation(photoObject: userPhoto)
        }
        return
    }
}

func uploadUserImage(image:UIImage){
    guard let imageData = image.jpegData(compressionQuality: 0.6) else { return }
    if let imageFile = PFFileObject(name: "image.jpg", data: imageData){
        let userPhoto = PFObject(className:"UserPhoto")
        userPhoto["imageFile"] = imageFile
        userPhoto["user"] = PFUser.current()
        userPhoto["isVideo"] = false
        userPhoto.saveInBackground { (success, error) in
            print("USER PFOTO SAVED! - error: ", (error?.localizedDescription ?? "") as String)
            addPhotoRelation(photoObject: userPhoto)
            addPhotoToUserPhotosArray(photoObject: userPhoto)
        }
        return
    }
}

func addPhotoToUserPhotosArray(photoObject:PFObject){
    guard let user = PFUser.current() else { return }
    user.add(photoObject, forKey: "userPhotosArray")
    user.saveInBackground { (success, error) in
        print("userPhotosArray SAVED! - error: ", (error?.localizedDescription ?? "") as String)
        checkDefaultUserPhoto(photoObject: photoObject)
    }
}

func addPhotoRelation(photoObject:PFObject){
    guard let user = PFUser.current() else { return }
    let relation = user.relation(forKey: "userPhotos")
    relation.add(photoObject)
    user.saveInBackground { (sucess, error) in
        print("USER PFOTO RELATION SAVED! - error: ", (error?.localizedDescription ?? "") as String)
        checkDefaultUserPhoto(photoObject: photoObject)
        sendNewMediaNotification()
    }
}

func sendNewMediaNotification(){
    let nc = NotificationCenter.default
    nc.post(name: Notification.Name("NewMediaAdded"), object: nil)
}

func checkDefaultUserPhoto(photoObject:PFObject){
    guard let user = PFUser.current() else { return }
    guard let defaultUserPhoto = user["defaultUserPhoto"] else {
        print("NO DEFAULT USER PHOTO")
        saveDefaultUserPhoto(photoObject: photoObject)
        return
    }
    print("defaultUserPhoto: ", defaultUserPhoto)
}

func saveDefaultUserPhoto(photoObject:PFObject){
    guard let user = PFUser.current() else { return }
    user["defaultUserPhoto"] = photoObject
    user.saveInBackground { (success, error) in
        print("DEFAULT USER PFOTO SAVED! - error: ", (error?.localizedDescription ?? "") as String)
    }
}

func getFeedFromCloud(completion: @escaping(_ success: Bool, _ objects: Any?) -> Void){
    print("getFeedFromCloud")
    getBlockUsers { (success, results) in
        print("blockedUsers: ", blockedUsers)
        
        let uid:String = PFUser.current()?.objectId ?? "-1"
        let params: [AnyHashable: Any] = [
            "iid": "000",
            "userObjectId" : uid
        ]
        
        //print("sendFollowersToServer-params: ", params)
        
        PFCloud.callFunction(inBackground: "getFeedUsersAndPhotos", withParameters: params) { (result, error) in
            //        print("getFeedUsers ERROR: ", error)
            //        print("getFeedUsers RESULT: ", result)
            
            if error == nil{
                var tempArray:NSArray = []
                tempArray = result as! NSArray
                completion(true, cleanUpBlockedUsers(arrayToCheck: tempArray))
            }
            else{
                completion(false, nil)
            }
            
        }
    }
}


func cleanUpBlockedUsers(arrayToCheck:NSArray) -> [Any] {
    
    var feedArray:[Any] = []
    for x:Any in arrayToCheck {
        let dict:NSDictionary = x as! NSDictionary
        let tempUser:PFUser = dict["user"] as! PFUser
        
        if !blockedUsers.contains(tempUser.objectId!) {
            
            if tempUser.objectId != PFUser.current()?.objectId{
                feedArray.append(x)
            }
            
        }
    }
    return feedArray
}

func getBlockUsers(completion: @escaping(_ success: Bool, _ objects: [PFObject]?) -> Void){
    guard let user = PFUser.current() else {
        completion(false, nil)
        return
        
    }
    blockedUsers = []
    
    let q1 = PFQuery(className:"BlockUser")
    q1.whereKey("blocker", equalTo: user)
    
    let q2 = PFQuery(className:"BlockUser")
    q2.whereKey("blocked", equalTo: user)
    
    let query = PFQuery.orQuery(withSubqueries: [q1, q2])
    
    query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
        if let error = error {
            print("getBlockUsers-error: ", error.localizedDescription)
            completion(false, objects)
        } else if let objects = objects {
            //print("getBlockUsers: ", objects)
            
            for item:PFObject in objects {
                let user1:PFUser = item["blocked"] as! PFUser
                let user2:PFUser = item["blocker"] as! PFUser
                
                if user1.objectId != user.objectId {
                    blockedUsers.append(user1.objectId!)
                }
                
                if user2.objectId != user.objectId {
                    blockedUsers.append(user2.objectId!)
                }
                
            }
            completion(true, objects)
        }
    }
}



func getProfileViewers(completion: @escaping(_ success: Bool, _ objects: Any?) -> Void){
    let uid:String = PFUser.current()?.objectId ?? "-1"
    let params: [AnyHashable: Any] = [
        "userId" : uid
    ]
    
    print("getProfileViewers-params: ", params)
    
    PFCloud.callFunction(inBackground: "getProfileViewers", withParameters: params) { (result, error) in
        //        print("getProfileViewers ERROR: ", error)
        //        print("getProfileViewers RESULT: ", result)
        
        if error == nil{
            completion(true, result)
        }
        else{
            completion(false, nil)
        }
        
    }
}

func getSearchResuts(locationId:String, completion: @escaping(_ success: Bool, _ objects: Any?) -> Void){
    let uid:String = PFUser.current()?.objectId ?? "-1"
    let params: [AnyHashable: Any] = [
        "userId" : uid,
        "locationId" : locationId
    ]
    
    print("getSearchResuts-params: ", params)
    
    PFCloud.callFunction(inBackground: "searchUsers", withParameters: params) { (result, error) in
        //        print("getSearchResuts ERROR: ", error)
        //        print("getSearchResuts RESULT: ", result)
        
        if error == nil{
            completion(true, result)
        }
        else{
            completion(false, nil)
        }
        
    }
}

func setLastOnline(){
    guard let user = PFUser.current() else { return }
    user["lastOnline"] = Date()
    user.saveInBackground { (success, error) in
        //print("LAST ONLINE SAVED! - error: ", (error?.localizedDescription ?? "") as String)
    }
}

func sendProfileView(viewedUser:PFUser){
    if !isUserLoggedIn() {
        return
    }
    
    let uid:String = PFUser.current()?.objectId ?? "-1"
    
    if uid == viewedUser.objectId {
        return
    }
    
    let params: [AnyHashable: Any] = [
        "viewerId": uid,
        "viewedId" : (viewedUser.objectId ?? "") as String
    ]
    
    //print("sendProfileView-params: ", params)
    
    PFCloud.callFunction(inBackground: "sendProfileView", withParameters: params) { (result, error) in
        //print("sendProfileView ERROR: ", error)
        //print("PROFILE VIEW SAVED")
    }
}

func setProfileObjectSeen(profileObject:PFObject){
    profileObject["notSeen"] = false
    profileObject.saveInBackground { (success, error) in
        //print("PROFILE OBJECT SET AS SEEN: error: ", error)
    }
}


func deletePhotoObject(objectToDelete:PFObject, completion: @escaping(_ success: Bool) -> Void){
    objectToDelete.deleteInBackground { (success, error) in
        print("PHOTO DELETE-success: ", success)
        completion(success)
    }
}

func changeDefaultUserPhoto(newUserPhotoObject:PFObject, completion: @escaping(_ success: Bool) -> Void){
    guard let user = PFUser.current() else { return }
    
    user["defaultUserPhoto"] = newUserPhotoObject
    user.saveInBackground { (success, error) in
        print("DEFAULT PHOTO CHANGED")
        completion(success)
    }
}

func reportUser(userToReport:PFUser, reason:String, completion: @escaping(_ success: Bool) -> Void){
    guard let user = PFUser.current() else { return }
    
    let report = PFObject(className:"ProfileReport")
    report["reporter"] = user
    report["reported"] = userToReport
    report["notSeen"] = true
    report["reason"] = reason
    report.incrementKey("reports")
    report.saveInBackground { (success, error) in
        completion(success)
    }
}

func blockUser(userToBlock:PFUser, completion: @escaping(_ success: Bool) -> Void){
    guard let user = PFUser.current() else { return }
    
    let block = PFObject(className:"BlockUser")
    block["blocker"] = user
    block["blocked"] = userToBlock
    block["notSeen"] = true
    block.saveInBackground { (success, error) in
        completion(success)
        blockedUsers.append(userToBlock.objectId!)
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("UserBlockedNotification"), object: nil)
    }
}

func saveQBUserId(qbUserId:Int){
    guard let user = PFUser.current() else { return }
    user["qbUserId"] = qbUserId
    user.saveInBackground { (success, error) in
        print("USER QB ID SAVED")
    }
}

func getProfileViewsCount(completion: @escaping(_ profileViewCount: Int) -> Void){
    guard let user = PFUser.current() else { return }
    
    var profileQuery: PFQuery<ProfileView> {
    return (ProfileView.query()!
        .whereKey("viewed", equalTo: user)
        .whereKeyExists("viewer")
        .whereKey("notSeen", equalTo: true)
        .order(byAscending: "createdAt")) as! PFQuery<ProfileView>
    }
    
    profileQuery.countObjectsInBackground { (count, error) in
        if error == nil{
            completion(Int(count))
        }
        else{
            completion(0)
        }
    }
        
}
