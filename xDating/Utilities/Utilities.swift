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

func displayAlert(alertTitle:String, alertMessage:String, parent:UIViewController){
    
//    let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
//    let action1 = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action:UIAlertAction) in
//
//    }
//
//    alertController.addAction(action1)
//    parent.present(alertController, animated: true, completion: nil)
    
    
    let alert = NewYorkAlertController(title: alertTitle,
                                       message: alertMessage,
                                       style: .alert)

    let ok = NewYorkButton(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
        
    }
    
    alert.addButton(ok)
    parent.present(alert, animated: true)
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

func showPhotoVideoPicker(parent:UIViewController) {
    
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
        handleSelectedMedia(selectedItems: selectedItems)
        picker.dismiss(animated: true, completion: nil)

    }
    
    parent.present(picker, animated: true, completion: nil)
}

func handleSelectedMedia(selectedItems:[YPMediaItem]){
    for item in selectedItems {
        switch item {
        case .photo(let photo):
            uploadUserImage(image: photo.image)
            print(photo)
        case .video(let video):
            do {
                let videoData = try NSData(contentsOf: video.url, options: .mappedIfSafe)
                uploadUserVideo(videoData: videoData)
            }
            catch{
                print(error)
            }

            print(video)
        }
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

func getUserNameAndAge(user:PFUser) -> String {
    let name:String = user["name"] as? String ?? ""
    let age:Int = user["age"] as? Int ?? 18
    return "\(name), \(age)"
}

func getUserLocation(user:PFUser, completion: @escaping(_ str: String?) -> Void){
    guard let locationObject:PFObject = user["location"] as? PFObject else{ return }
    locationObject.fetchIfNeededInBackground { (object, error) in
        let countryObject:PFObject = locationObject["country"] as! PFObject
        countryObject.fetchIfNeededInBackground { (cObject, error) in
            let location:String = locationObject["name"] as? String ?? ""
            let country:String = cObject?["name"] as? String ?? ""
            let locationString:String = "\(location), \(country)"
            completion(locationString)
        }
    }
}


