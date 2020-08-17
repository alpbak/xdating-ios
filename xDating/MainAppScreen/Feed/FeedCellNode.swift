//
//  FeedCellNode.swift
//  xDating
//
//  Created by Alpaslan Bak on 16.08.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Parse

class FeedCellNode: ASCellNode, ASCollectionDelegate, ASCollectionDataSource {
    var cellPhotos:NSArray = []
    var cellUser:PFUser?
    var userPhotosArray:[UserPhotoObject] = []
    
    let userNameNode = ASTextNode()
    let postLocationNode = ASTextNode()
    let lastOnlineNode = ASTextNode()
    var _collectionNode:ASCollectionNode?
    
    required init(with cellDict:NSDictionary) {
        super.init()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        _collectionNode = ASCollectionNode(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width), collectionViewLayout: flowLayout)
        _collectionNode?.delegate = self
        _collectionNode?.dataSource = self
        _collectionNode?.backgroundColor = .lightGray
        //_collectionNode?.view.isPagingEnabled = true
        
        
        
        automaticallyManagesSubnodes = true
        cellUser = nil
        cellPhotos = []
        userPhotosArray = []
        
        cellUser = cellDict["user"] as? PFUser
        cellPhotos = cellDict["photos"] as! NSArray
        
        cellPhotos.forEach({ (object) in
            let temp:UserPhotoObject = UserPhotoObject.init(pfObject: object as! PFObject)
            if temp.isVideo{
                self.userPhotosArray.insert(temp, at: 0)
            }
            else{
                self.userPhotosArray.append(temp)
            }
        })
        
        setupTextNodes()
        
        DispatchQueue.main.async {
            self._collectionNode?.reloadData()
            self._collectionNode?.view.isPagingEnabled = true
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//            self._collectionNode?.view.isPagingEnabled = true
//        }
    }
    
    func setupTextNodes(){
        let lastOnline:Date = (cellUser?["lastOnline"] as? Date)!
        let los:String = timeAgoSince(lastOnline) as String
        
        
        let nameStringAttribute = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 16.0),
                                   NSAttributedString.Key.foregroundColor: UIColor.label]
        let locationStringAttribute = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 12.0),
                                       NSAttributedString.Key.foregroundColor: UIColor.label]
        let lastOnlineStringAttribute = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 12.0),
                                         NSAttributedString.Key.foregroundColor: UIColor.gray]
        
        let nameString = NSAttributedString(string: getUserNameAndAge(user: cellUser!), attributes: nameStringAttribute as [NSAttributedString.Key : Any])
        let lastOnlineString = NSAttributedString(string: los, attributes: lastOnlineStringAttribute as [NSAttributedString.Key : Any])
        userNameNode.attributedText = nameString
        
        getUserLocation(user: cellUser!) { (locationString) in
            let str = NSAttributedString(string: locationString!, attributes: locationStringAttribute as [NSAttributedString.Key : Any])
            self.postLocationNode.attributedText = str
        }
        
        lastOnlineNode.attributedText = lastOnlineString
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let imageRatio: CGFloat = 1.0
        let imagePlace = ASRatioLayoutSpec(ratio: imageRatio, child: _collectionNode!)
        
        let relativeSpec = ASRelativeLayoutSpec(horizontalPosition: .end,
                                                verticalPosition: .start,
                                                sizingOption: [],
                                                child: getButtonsStack())
        relativeSpec.style.maxWidth = ASDimensionMakeWithPoints(UIScreen.main.bounds.width)
        relativeSpec.style.minHeight = ASDimensionMakeWithPoints(60.0)
        
        let headerLayoutSpec = ASBackgroundLayoutSpec(child: relativeSpec, background: getNameLocationStack())
        
        let insets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 5.0)
        let headerWithInset = ASInsetLayoutSpec(insets: insets, child: headerLayoutSpec)

        let stackLayout = ASStackLayoutSpec.vertical()
        stackLayout.justifyContent = .start
        stackLayout.alignItems = .start
        stackLayout.style.flexShrink = 1.0
        stackLayout.lineSpacing = 0
        stackLayout.children = [headerWithInset, imagePlace]
        
        return  ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: stackLayout)
    }
    
    func getNameLocationStack() -> ASStackLayoutSpec {
        let nameLocationStack = ASStackLayoutSpec.vertical()
        nameLocationStack.spacing = 5
        nameLocationStack.children = [userNameNode, postLocationNode, lastOnlineNode]
        //nameLocationStack.style.minWidth = ASDimensionMakeWithPoints(160.0)
        return nameLocationStack
    }
    
    func getButtonsStack() -> ASStackLayoutSpec {
        let sendMessageTextNode = ASTextNode()
        let videoTextNode = ASTextNode()
        let buttonStringsAttr = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 12.0), NSAttributedString.Key.foregroundColor: UIColor.label]
        
        let messageString = NSAttributedString(string: "Message", attributes: buttonStringsAttr as [NSAttributedString.Key : Any])
        let videoString = NSAttributedString(string: "Approved", attributes: buttonStringsAttr as [NSAttributedString.Key : Any])
        
        sendMessageTextNode.maximumNumberOfLines = 2
        videoTextNode.maximumNumberOfLines = 2
        sendMessageTextNode.attributedText = messageString
        videoTextNode.attributedText = videoString
        
        let messageButtonNode = ASButtonNode()
        messageButtonNode.setImage(UIImage.init(named: "messageicon"), for: .normal)
        
        let videoButtonNode = ASButtonNode()
        videoButtonNode.setImage(UIImage.init(named: "videoicon"), for: .normal)
        
        let messageStack = ASStackLayoutSpec.vertical()
        messageStack.spacing = 5
        messageStack.children = [messageButtonNode, sendMessageTextNode]
        messageStack.alignItems = .center
        
        let videoStack = ASStackLayoutSpec.vertical()
        videoStack.spacing = 5
        videoStack.children = [videoButtonNode, videoTextNode]
        videoStack.alignItems = .center
        
        let buttonStack = ASStackLayoutSpec.horizontal()
        buttonStack.spacing = 10
        buttonStack.alignContent = .center
        buttonStack.children = [messageStack, videoStack]
        buttonStack.alignItems = .center
        
        messageButtonNode.addTarget(self, action: #selector(handleMessageClick), forControlEvents: .touchUpInside)
        videoButtonNode.addTarget(self, action: #selector(handleVideoClick), forControlEvents: .touchUpInside)
        
        return buttonStack
    }
    
    @objc func handleMessageClick(sender: UIButton){
        print("CHAT: ", cellUser?["name"] ?? "")
    }
    
    @objc func handleVideoClick(sender: UIButton){
        print("VIDEO", cellUser?["name"] ?? "")
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return cellPhotos.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            return ImageCellNode(userPhotoObject: self.userPhotosArray[indexPath.row], cellUser: self.cellUser!)
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let width = UIScreen.main.bounds.width
        return ASSizeRange(min: CGSize(width: width, height: width), max: CGSize(width: width, height: width))
    }
}
