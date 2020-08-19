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

func isUserLoggedIn() -> Bool {
    if PFUser.current()?.email == nil{
        return false
    }
    else{
        return true
    }
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
    }
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
            completion(true, result)
        }
        else{
            completion(false, nil)
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
        print("getSearchResuts ERROR: ", error)
        print("getSearchResuts RESULT: ", result)
        
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
    let uid:String = PFUser.current()?.objectId ?? "-1"
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
