//
//  Utilities.swift
//  xDating
//
//  Created by Alpaslan Bak on 21.07.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import Foundation
import UIKit
import YPImagePicker
import AVFoundation
import AVKit
import Photos
import Parse
import NewYorkAlert

enum SettingsChoices: Int {
    case newprofile
    case newmessage
    case setting1
    case setting2
    case setting3
}

struct LoginConstant {
    static let notSatisfyingDeviceToken = "Invalid parameter not satisfying: deviceToken != nil"
    static let enterToChat = NSLocalizedString("Enter to chat", comment: "")
    static let fullNameDidChange = NSLocalizedString("Full Name Did Change", comment: "")
    static let login = NSLocalizedString("Login", comment: "")
    static let checkInternet = NSLocalizedString("No Internet Connection", comment: "")
    static let checkInternetMessage = NSLocalizedString("Make sure your device is connected to the internet", comment: "")
    static let enterUsername = NSLocalizedString("Please enter your login and username", comment: "")
    static let loginHint = NSLocalizedString("Use your email or alphanumeric characters in a range from 3 to 50. First character must be a letter.", comment: "")
    static let usernameHint = NSLocalizedString("Use alphanumeric characters and spaces in a range from 3 to 20. Cannot contain more than one space in a row.", comment: "")
    static let defaultPassword = "quickblox"
    static let infoSegue = "ShowInfoScreen"
    static let showDialogs = "ShowDialogsViewController"
}


public enum ReportReason {
    static let inappropriatePhoto: String = NSLocalizedString("INAPPROPRIATE PHOTO/VIDEO", comment: "")
    static let inappropriateContent: String = NSLocalizedString("INAPPROPRIATE CONTENT", comment: "")
    static let spammer: String = NSLocalizedString("SPAMMER", comment: "")
    static let harrasment: String = NSLocalizedString("HARRASMENT", comment: "")
}

func displayAlert(alertTitle:String, alertMessage:String, parent:UIViewController?){
    let alert = NewYorkAlertController(title: alertTitle,
                                       message: alertMessage,
                                       style: .alert)
    
    let ok = NewYorkButton(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
        
    }
    
    alert.addButton(ok)
    if parent == nil {
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        let rootVC = appDelegate?.getRootVC()
        rootVC?.present(alert, animated: true)
    }
    else{
        parent?.present(alert, animated: true)
    }
}

func displayAlertWithCompletion(alertTitle:String, alertMessage:String, parent:UIViewController?, completion: @escaping(_ success: Bool) -> Void){
    let alert = NewYorkAlertController(title: alertTitle,
                                       message: alertMessage,
                                       style: .alert)
    
    let ok = NewYorkButton(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
        completion(true)
    }
    
    alert.addButton(ok)
    if parent == nil {
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        let rootVC = appDelegate?.getRootVC()
        rootVC?.present(alert, animated: true)
    }
    else{
        parent?.present(alert, animated: true)
    }
}

func displayWaitIndicator(message:String?){
    if (message != nil) {
        SKActivityIndicator.show(message ?? "", userInteractionStatus: false)
    }
    else{
        SKActivityIndicator.show()
    }
}

func hideWaitIndicator(){
    SKActivityIndicator.dismiss()
}

func showPhotoVideoPicker(parent:UIViewController, completion: @escaping(_ success: UIImage?) -> Void) {
    
    var selectedItems = [YPMediaItem]()
    
    var config = YPImagePickerConfiguration()
    config.library.mediaType = .photoAndVideo
    config.usesFrontCamera = true
    config.shouldSaveNewPicturesToAlbum = false
    config.video.compression = AVAssetExportPresetMediumQuality
    config.startOnScreen = .library
    config.screens = [.library, .photo, .video]
    config.video.recordingTimeLimit = 15.0
    //config.video.libraryTimeLimit = 500.0
    config.video.libraryTimeLimit = 30
    config.showsCrop = .rectangle(ratio: (1/1))
    config.wordings.libraryTitle = "Gallery"
    config.hidesStatusBar = false
    config.hidesBottomBar = false
    config.maxCameraZoomFactor = 2.0
    config.library.maxNumberOfItems = 5
    config.gallery.hidesRemoveButton = false
    config.library.preselectedItems = selectedItems
    
    let picker = YPImagePicker(configuration: config)
    
    /* Multiple media implementation */
    picker.didFinishPicking { [unowned picker] items, cancelled in
        
        if cancelled {
            print("Picker was canceled")
            sendNewMediaNotification()
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        selectedItems = items
        //handleSelectedMedia(selectedItems: selectedItems, completion: )
        handleSelectedMedia(selectedItems: selectedItems) { (image) in
            completion(image)
        }
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    parent.present(picker, animated: true, completion: nil)
}

func handleSelectedMedia(selectedItems:[YPMediaItem], completion: @escaping(_ success: UIImage?) -> Void){
//    for item in selectedItems {
//        switch item {
//        case .photo(let photo):
//            uploadUserImage(image: photo.image)
//            completion(photo.image)
//            print(photo)
//        case .video(let video):
//            do {
//                let videoData = try NSData(contentsOf: video.url, options: .mappedIfSafe)
//                uploadUserVideo(videoData: videoData)
//            }
//            catch{
//                print(error)
//            }
//
//            print(video)
//            completion(nil)
//        }
//    }
    
    let totalPhotoCount:Int = selectedItems.count
    var pIndex = 0
    
    displayWaitIndicator(message: NSLocalizedString("Media Uploading", comment: ""))
    let dispatchGroup = DispatchGroup()
    
    for item in selectedItems {
        dispatchGroup.enter()
        
        switch item {
        case .photo(let photo):
            uploadUserImage(image: photo.image)
            uploadUserImageWithCompletion(image: photo.image) { (success) in
                print("IMAGE UPLOADED")
                pIndex = pIndex + 1
                
                if pIndex == totalPhotoCount{
                    print("ALL IMAGES UPLOADED")
                    hideWaitIndicator()
                }
            }
            completion(photo.image)
            
        case .video(let video):
            do {
                let videoData = try NSData(contentsOf: video.url, options: .mappedIfSafe)
                //uploadUserVideo(videoData: videoData)
                
                uploadUserVideoWithCompletion(videoData: videoData) { (success) in
                    print("VIDEO UPLOADED")
                    pIndex = pIndex + 1
                    
                    if pIndex == totalPhotoCount{
                        print("ALL VIDEOS UPLOADED")
                        hideWaitIndicator()
                    }
                }
            }
            catch{
                print(error)
            }
            
            print(video)
            completion(nil)
        }

//        performGeoCoding { address in
//            dispatchGroup.leave()
//        }
    }

    dispatchGroup.notify(queue: .main) {
        //completionHandler()
        print("UPLOADS DONE")
    }
    
    
    print("ITEMS ARE UPLOADING")
}

func openUserProfile(cellDict:NSDictionary){
    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    let vc = UserProfileViewController()
    vc.cellDict = cellDict
    let rootVC = appDelegate?.getRootVC()
    rootVC?.present(vc, animated: true, completion: nil)
}

func openUserProfileForUser(user:PFUser){
    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    let vc = UserProfileViewController()
    vc.cellUser = user
    let rootVC = appDelegate?.getRootVC()
    rootVC?.present(vc, animated: true, completion: nil)
}

func getUserNameAndAge(user:PFUser) -> String {
    let name:String = user["name"] as? String ?? ""
    let age:Int = user["age"] as? Int ?? 18
    return "\(name), \(age)"
}

func getUserName(user:PFUser) -> String {
    let name:String = user["name"] as? String ?? ""
    return "\(name)"
}

func getUserAge(user:PFUser) -> String {
    let age:Int = user["age"] as? Int ?? 18
    return "\(age)"
}

func getUserLocation(user:PFUser, completion: @escaping(_ str: String?) -> Void){
    guard let locationObject:PFObject = user["location"] as? PFObject else{ return }
    let location:String = locationObject["name"] as? String ?? ""
    
    let countryObject:PFObject = locationObject["country"] as! PFObject
    let country:String = getCountryName(objId: countryObject.objectId ?? "")
    let locationString:String = "\(location), \(country)"
    completion(locationString)
    /*
     locationObject.fetchIfNeededInBackground { (object, error) in
     let countryObject:PFObject = locationObject["country"] as! PFObject
     countryObject.fetchIfNeededInBackground { (cObject, error) in
     let location:String = locationObject["name"] as? String ?? ""
     let country:String = cObject?["name"] as? String ?? ""
     let locationString:String = "\(location), \(country)"
     completion(locationString)
     }
     }
     */
}

func getCountryName(objId:String) -> String {
    var countryName:String = ""
    let countriesArray:NSArray = readjson()["results"] as! NSArray
    if let swiftArray = countriesArray.mutableCopy() as? Array<Dictionary<String, AnyObject>> {
        //print("swiftArray: ", swiftArray)
        
        for w:Dictionary<String, AnyObject> in swiftArray {
            let tempObjId:String = w["objectId"] as! String
            if tempObjId == objId {
                countryName = w["name"] as! String
            }
        }
    }
    return countryName
}

func readjson() -> NSDictionary{
    if let filePath = Bundle.main.path(forResource: "countries", ofType: "json"), let data = NSData(contentsOfFile: filePath) {
        
        do {
            let json = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments)
            return json as! NSDictionary
        }
        catch {
            return NSDictionary()
        }
    }
    return NSDictionary()
    
}

func reportUser(user:PFUser, parent:UIViewController?){
    
    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    let rootParent = appDelegate?.getRootVC()
    
    
    let mParent:UIViewController
    mParent = parent ?? rootParent!
    
    //    if parent == nil {
    //        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    //        let rootParent = appDelegate?.getRootVC()
    //    }
    
    let actionSheet = NewYorkAlertController(title: NSLocalizedString("REPORT USER", comment: ""),
                                             message: NSLocalizedString("Please select the subject for your report.", comment: ""),
                                             style: .actionSheet)
    
    
    let buttons = [
        NewYorkButton(title: ReportReason.inappropriateContent, style: .default, handler: { (button) in
            reportUser(userToReport: user, reason: ReportReason.inappropriateContent) { (success) in
                displayReportAlert(parent: parent)
            }
        }),
        NewYorkButton(title: ReportReason.inappropriatePhoto, style: .default, handler: { (button) in
            reportUser(userToReport: user, reason: ReportReason.inappropriatePhoto) { (success) in
                displayReportAlert(parent: parent)
            }
        }),
        NewYorkButton(title: ReportReason.spammer, style: .default, handler: { (button) in
            reportUser(userToReport: user, reason: ReportReason.spammer) { (success) in
                displayReportAlert(parent: parent)
            }
        }),
        NewYorkButton(title: ReportReason.harrasment, style: .default, handler: { (button) in
            reportUser(userToReport: user, reason: ReportReason.harrasment) { (success) in
                displayReportAlert(parent: parent)
            }
        }),
        NewYorkButton(title: NSLocalizedString("BLOCK USER", comment: ""), style: .destructive, handler: { (button) in
            reportUser(userToReport: user, reason: ReportReason.harrasment) { (success) in
                displayBlockAlert(parent: mParent) { (success) in
                    
                    blockUser(userToBlock: user) { (success) in
                        print("USER BLOCKED FROM MAIN FEED")
                    }
                }
            }
        })
    ]
    actionSheet.addButtons(buttons)
    mParent.present(actionSheet, animated: true)
}

func displayReportAlert(parent:UIViewController?){
    displayAlert(alertTitle: NSLocalizedString("Thank You", comment: ""),
                 alertMessage: NSLocalizedString("We have received your report.", comment: ""),
                 parent: parent)
}

func displayBlockAlert(parent:UIViewController, completion: @escaping(_ success: Bool) -> Void){
    let alert = NewYorkAlertController(title: NSLocalizedString("Block", comment: ""),
                                       message: NSLocalizedString("Are you sure you want to block this user", comment: ""),
                                       style: .alert)
    
    let ok = NewYorkButton(title: NSLocalizedString("YES", comment: ""), style: .default) { _ in
        completion(true)
    }
    
    let no = NewYorkButton(title: NSLocalizedString("NO", comment: ""), style: .cancel) { _ in
        completion(false)
    }
    
    alert.addButton(ok)
    alert.addButton(no)
    
    parent.present(alert, animated: true)
}

func setupDate(_ dateSent: Date) -> String {
    let formatter = DateFormatter()
    var dateString = ""
    
    if Calendar.current.isDateInToday(dateSent) == true {
        dateString = messageTimeDateFormatter.string(from: dateSent)
    } else if Calendar.current.isDateInYesterday(dateSent) == true {
        dateString = "Yesterday"
    } else if dateSent.hasSame([.year], as: Date()) == true {
        formatter.dateFormat = "d MMM"
        dateString = formatter.string(from: dateSent)
    } else {
        formatter.dateFormat = "d.MM.yy"
        var anotherYearDate = formatter.string(from: dateSent)
        if (anotherYearDate.hasPrefix("0")) {
            anotherYearDate.remove(at: anotherYearDate.startIndex)
        }
        dateString = anotherYearDate
    }
    
    return dateString
}

func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}
