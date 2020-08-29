//
//  ImageCellNode.swift
//  Texture
//
//  Copyright (c) Facebook, Inc. and its affiliates.  All rights reserved.
//  Changes after 4/13/2017 are: Copyright (c) Pinterest, Inc.  All rights reserved.
//  Licensed under Apache 2.0: http://www.apache.org/licenses/LICENSE-2.0
//

import UIKit
import AsyncDisplayKit
import Parse

class ImageCellNode: ASCellNode, ASVideoNodeDelegate {
    
    let imageNode = ASNetworkImageNode()
    let videoNode = ASVideoNode()
    var mCellUser:PFUser? = nil
    var mUserPhotoObject:UserPhotoObject?
    var isForVideo = false
    var cellIndex:Int = 0
    
    required init(userPhotoObject:UserPhotoObject, cellUser:PFUser, index:Int) {
        super.init()
        
        cellIndex = index
        mCellUser = cellUser
        mUserPhotoObject = userPhotoObject
        
        guard let photoUrl:String = userPhotoObject.imageFile.url else {
            return
        }

        if userPhotoObject.isVideo {
            let screenSize = UIScreen.main.bounds
            isForVideo = true
            
            videoNode.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.width)
            let mUrl:URL = URL.init(string: photoUrl)!
            let mAsset:AVAsset = AVAsset.init(url:mUrl)
            
            DispatchQueue.main.async {
                self.videoNode.asset = mAsset
            }
            
            videoNode.delegate = self
            videoNode.shouldAutoplay = true
            videoNode.shouldAutorepeat = true
            videoNode.muted = true
            
            self.addSubnode(self.videoNode)
        }
        else{
            isForVideo = false
            imageNode.contentMode = .scaleAspectFill
            imageNode.url = URL(string: photoUrl)
            self.addSubnode(self.imageNode)
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return  ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: photoVideoStack())
    }

    func photoVideoStack() -> ASStackLayoutSpec {
        let imageRatio: CGFloat = 1.0
        var imagePlace:ASRatioLayoutSpec
        if isForVideo {
            imagePlace = ASRatioLayoutSpec(ratio: imageRatio, child: videoNode)
        }
        else{
            imagePlace = ASRatioLayoutSpec(ratio: imageRatio, child: imageNode)
        }
        
        let stackLayout = ASStackLayoutSpec.horizontal()
        stackLayout.justifyContent = .start
        stackLayout.alignItems = .start
        stackLayout.children = [imagePlace]
        
        return stackLayout
    }
    
    func didTap(_ videoNode: ASVideoNode) {
        print("TAP: ")
        videoNode.muted = !(videoNode.muted )
    }
}
