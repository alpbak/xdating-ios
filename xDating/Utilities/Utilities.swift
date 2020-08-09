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

func displayAlert(alertTitle:String, alertMessage:String, parent:UIViewController){
    
    let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
    let action1 = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action:UIAlertAction) in
        
    }
    
    alertController.addAction(action1)
    parent.present(alertController, animated: true, completion: nil)
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
    
    /* Uncomment and play around with the configuration 👨‍🔬 🚀 */
    
    /* Set this to true if you want to force the  library output to be a squared image. Defaults to false */
    //         config.library.onlySquare = true
    
    /* Set this to true if you want to force the camera output to be a squared image. Defaults to true */
    // config.onlySquareImagesFromCamera = false
    
    /* Ex: cappedTo:1024 will make sure images from the library or the camera will be
     resized to fit in a 1024x1024 box. Defaults to original image size. */
    // config.targetImageSize = .cappedTo(size: 1024)
    
    /* Choose what media types are available in the library. Defaults to `.photo` */
    config.library.mediaType = .photoAndVideo
    
    /* Enables selecting the front camera by default, useful for avatars. Defaults to false */
    config.usesFrontCamera = true
    
    /* Adds a Filter step in the photo taking process. Defaults to true */
    // config.showsFilters = false
    
    /* Manage filters by yourself */
    //        config.filters = [YPFilter(name: "Mono", coreImageFilterName: "CIPhotoEffectMono"),
    //                          YPFilter(name: "Normal", coreImageFilterName: "")]
    //        config.filters.remove(at: 1)
    //        config.filters.insert(YPFilter(name: "Blur", coreImageFilterName: "CIBoxBlur"), at: 1)
    
    /* Enables you to opt out from saving new (or old but filtered) images to the
     user's photo library. Defaults to true. */
    config.shouldSaveNewPicturesToAlbum = false
    
    /* Choose the videoCompression. Defaults to AVAssetExportPresetHighestQuality */
    config.video.compression = AVAssetExportPresetMediumQuality
    
    /* Defines the name of the album when saving pictures in the user's photo library.
     In general that would be your App name. Defaults to "DefaultYPImagePickerAlbumName" */
    // config.albumName = "ThisIsMyAlbum"
    
    /* Defines which screen is shown at launch. Video mode will only work if `showsVideo = true`.
     Default value is `.photo` */
    config.startOnScreen = .library
    
    /* Defines which screens are shown at launch, and their order.
     Default value is `[.library, .photo]` */
    config.screens = [.library, .photo, .video]
    
    /* Can forbid the items with very big height with this property */
    //        config.library.minWidthForItem = UIScreen.main.bounds.width * 0.8
    
    /* Defines the time limit for recording videos.
     Default is 30 seconds. */
    config.video.recordingTimeLimit = 15.0
    
    /* Defines the time limit for videos from the library.
     Defaults to 60 seconds. */
    //config.video.libraryTimeLimit = 500.0
    config.video.libraryTimeLimit = 30
    
    /* Adds a Crop step in the photo taking process, after filters. Defaults to .none */
    config.showsCrop = .rectangle(ratio: (1/1))
    
    /* Defines the overlay view for the camera. Defaults to UIView(). */
    // let overlayView = UIView()
    // overlayView.backgroundColor = .red
    // overlayView.alpha = 0.3
    // config.overlayView = overlayView
    
    /* Customize wordings */
    config.wordings.libraryTitle = "Gallery"
    
    /* Defines if the status bar should be hidden when showing the picker. Default is true */
    config.hidesStatusBar = false
    
    /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
    config.hidesBottomBar = false
    
    config.maxCameraZoomFactor = 2.0
    
    config.library.maxNumberOfItems = 5
    config.gallery.hidesRemoveButton = false
    
    /* Disable scroll to change between mode */
    // config.isScrollToChangeModesEnabled = false
    //        config.library.minNumberOfItems = 2
    
    /* Skip selection gallery after multiple selections */
    // config.library.skipSelectionsGallery = true
    
    /* Here we use a per picker configuration. Configuration is always shared.
     That means than when you create one picker with configuration, than you can create other picker with just
     let picker = YPImagePicker() and the configuration will be the same as the first picker. */
    
    
    /* Only show library pictures from the last 3 days */
    //let threDaysTimeInterval: TimeInterval = 3 * 60 * 60 * 24
    //let fromDate = Date().addingTimeInterval(-threDaysTimeInterval)
    //let toDate = Date()
    //let options = PHFetchOptions()
    //options.predicate = NSPredicate(format: "creationDate > %@ && creationDate < %@", fromDate as CVarArg, toDate as CVarArg)
    //
    ////Just a way to set order
    //let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
    //options.sortDescriptors = [sortDescriptor]
    //
    //config.library.options = options
    
    config.library.preselectedItems = selectedItems
    
    let picker = YPImagePicker(configuration: config)
    
    /* Change configuration directly */
    // YPImagePickerConfiguration.shared.wordings.libraryTitle = "Gallery2"
    
    
    /* Multiple media implementation */
    picker.didFinishPicking { [unowned picker] items, cancelled in
        
        if cancelled {
            print("Picker was canceled")
            picker.dismiss(animated: true, completion: nil)
            return
        }
        //_ = items.map { print("🧀 \($0)") }
        
        selectedItems = items
        handleSelectedMedia(selectedItems: selectedItems)
        picker.dismiss(animated: true, completion: nil)
//        if let firstItem = items.first {
//            switch firstItem {
//            case .photo(let photo):
//                self.selectedImageView.image = photo.image
//                picker.dismiss(animated: true, completion: nil)
//            case .video(let video):
//                self.selectedImageView.image = video.thumbnail
//
//                let assetURL = video.url
//                let playerVC = AVPlayerViewController()
//                let player = AVPlayer(playerItem: AVPlayerItem(url:assetURL))
//                playerVC.player = player
//
//                picker.dismiss(animated: true, completion: { [weak self] in
//                    parent.present(playerVC, animated: true, completion: nil)
//                    print("😀 \(String(describing: self?.resolutionForLocalVideo(url: assetURL)!))")
//                })
//            }
//        }
    }
    
    /* Single Photo implementation. */
    // picker.didFinishPicking { [unowned picker] items, _ in
    //     self.selectedItems = items
    //     self.selectedImageV.image = items.singlePhoto?.image
    //     picker.dismiss(animated: true, completion: nil)
    // }
    
    /* Single Video implementation. */
    //picker.didFinishPicking { [unowned picker] items, cancelled in
    //    if cancelled { picker.dismiss(animated: true, completion: nil); return }
    //
    //    self.selectedItems = items
    //    self.selectedImageV.image = items.singleVideo?.thumbnail
    //
    //    let assetURL = items.singleVideo!.url
    //    let playerVC = AVPlayerViewController()
    //    let player = AVPlayer(playerItem: AVPlayerItem(url:assetURL))
    //    playerVC.player = player
    //
    //    picker.dismiss(animated: true, completion: { [weak self] in
    //        self?.present(playerVC, animated: true, completion: nil)
    //        print("😀 \(String(describing: self?.resolutionForLocalVideo(url: assetURL)!))")
    //    })
    //}
    
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
