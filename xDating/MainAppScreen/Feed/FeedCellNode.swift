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
    var profileViewObject:PFObject?
    
    let userNameNode = ASTextNode()
    let postLocationNode = ASTextNode()
    let lastOnlineNode = ASTextNode()
    var _collectionNode:ASCollectionNode?
    var shouldHideMorePhotoNode:Bool = false
    var isForProfileView:Bool = false
    
    let morePhotosTextNode = ASTextNode()
    
    required init(with cellDict:NSDictionary) {
        super.init()
        
        shouldHideMorePhotoNode = false
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        _collectionNode = ASCollectionNode(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width), collectionViewLayout: flowLayout)
        _collectionNode?.delegate = self
        _collectionNode?.dataSource = self
        _collectionNode?.backgroundColor = .lightGray
        
        automaticallyManagesSubnodes = true
        cellUser = nil
        cellPhotos = []
        userPhotosArray = []
        
        cellUser = cellDict["user"] as? PFUser
        cellPhotos = cellDict["photos"] as! NSArray
        profileViewObject = cellDict["profile"] as? PFObject
        
        if profileViewObject != nil {
            isForProfileView = true
        }
        else{
            isForProfileView = false
        }
        
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
        
        //        let lcat:PFObject = cellUser!["location"] as! PFObject
        //        let str = NSAttributedString(string: lcat["name"] as! String, attributes: locationStringAttribute as [NSAttributedString.Key : Any])
        //        self.postLocationNode.attributedText = str
        
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
        
        var stackToReturn:ASLayoutSpec
        if cellPhotos.count > 1 {
            if shouldHideMorePhotoNode {
                stackToReturn =  ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: stackLayout)
            }
            else{
                stackToReturn = ASBackgroundLayoutSpec(child: getMorePhotosStack(), background: stackLayout)
            }
        }
        else{
            stackToReturn =  ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: stackLayout)
        }
        
        if isForProfileView {
            return ASBackgroundLayoutSpec(child: getProfileViewStack(), background: stackToReturn)
        }
        else{
            return stackToReturn
        }
    }
    
    func handleMorePhotoView(isFirstCell:Bool, stringToDisplay:String){
        print("handleMorePhotoView: ", stringToDisplay)
        let nameStringAttribute = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 10.0),
        NSAttributedString.Key.foregroundColor: UIColor.white]
        
        var tailStr:String = "   "
        if isFirstCell {
            tailStr = " ➤  "
        }
        
        let str:String = "   " + stringToDisplay + tailStr
        
        let nameString = NSAttributedString(string: str, attributes: nameStringAttribute as [NSAttributedString.Key : Any])
        
        morePhotosTextNode.attributedText = nameString
        
    }
    
    func getMorePhotosStack() -> ASInsetLayoutSpec {
        let bColor:UIColor = UIColor.black.withAlphaComponent(0.2)
        morePhotosTextNode.style.alignSelf = .center
        morePhotosTextNode.backgroundColor = bColor
        
        let str:String = "   " + NSLocalizedString("Swipe For More", comment: "") + " ➤  "
        //handleMorePhotoView(isFirstCell: true, stringToDisplay: str)
        
        
        
        let topSeparator = ASImageNode()
        let bottomSeparator = ASImageNode()
        topSeparator.image = UIImage.as_resizableRoundedImage(withCornerRadius: 0, cornerColor: .black, fill: bColor)
        bottomSeparator.image = UIImage.as_resizableRoundedImage(withCornerRadius: 0, cornerColor: .black, fill: bColor)
        
        let verticalStackSpec = ASStackLayoutSpec.vertical()
        verticalStackSpec.spacing = 0
        verticalStackSpec.justifyContent = .center
        verticalStackSpec.children = [topSeparator, morePhotosTextNode, bottomSeparator]
        
        return ASInsetLayoutSpec(insets:UIEdgeInsets(top: CGFloat.infinity, left: CGFloat.infinity, bottom: 40, right: 10), child: verticalStackSpec)
    }
    
    func getProfileViewStack() -> ASInsetLayoutSpec {
        let bColor:UIColor = UIColor.black.withAlphaComponent(0.7)
        let strAttribute = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 10.0),
                            NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let newStrAttribute = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 12.0),
                               NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let newString = NSAttributedString(string: NSLocalizedString("NEW", comment: ""), attributes: newStrAttribute as [NSAttributedString.Key : Any])
        
        let profileViewCountInt:Int = profileViewObject?["views"] as! Int
        let profileViewCountStr:String = "\(profileViewCountInt)"
        
        var xStr:String = ""
        if profileViewCountInt == 1 {
            xStr = NSLocalizedString("view", comment: "")
        }
        else{
            xStr = NSLocalizedString("views", comment: "")
        }
        
        let str:String = "   " + profileViewCountStr + " " + xStr + " 👁  "
        let nameString = NSAttributedString(string: str, attributes: strAttribute as [NSAttributedString.Key : Any])
        let stringToDisplay:NSMutableAttributedString
        
        let notSeen:Bool = profileViewObject?["notSeen"] as! Bool
        if notSeen {
            stringToDisplay = NSMutableAttributedString.init(attributedString: nameString)
            stringToDisplay.append(newString)
        }
        else{
            stringToDisplay = NSMutableAttributedString.init(attributedString: nameString)
        }
        
        
        let profileTextNode = ASTextNode()
        profileTextNode.attributedText = stringToDisplay
        profileTextNode.style.alignSelf = .center
        profileTextNode.backgroundColor = bColor
        
        let topSeparator2 = ASImageNode()
        let bottomSeparator2 = ASImageNode()
        topSeparator2.image = UIImage.as_resizableRoundedImage(withCornerRadius: 0, cornerColor: .black, fill: bColor)
        bottomSeparator2.image = UIImage.as_resizableRoundedImage(withCornerRadius: 0, cornerColor: .black, fill: bColor)
        
        let verticalStackSpec = ASStackLayoutSpec.vertical()
        verticalStackSpec.spacing = 0
        verticalStackSpec.justifyContent = .center
        verticalStackSpec.children = [topSeparator2, profileTextNode, bottomSeparator2]
        
        return ASInsetLayoutSpec(insets:UIEdgeInsets(top: 60, left: CGFloat.infinity, bottom: CGFloat.infinity, right: 0), child: verticalStackSpec)
    }
    
    func getNameLocationStack() -> ASStackLayoutSpec {
        let nameLocationStack = ASStackLayoutSpec.vertical()
        nameLocationStack.spacing = 5
        nameLocationStack.children = [userNameNode, postLocationNode, lastOnlineNode]
        return nameLocationStack
    }
    
    func getButtonsStack() -> ASStackLayoutSpec {
        let sendMessageTextNode = ASTextNode()
        let videoTextNode = ASTextNode()
        let optionTextNode = ASTextNode()
        let buttonStringsAttr = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 12.0), NSAttributedString.Key.foregroundColor: UIColor.label]
        
        let messageString = NSAttributedString(string: "Message", attributes: buttonStringsAttr as [NSAttributedString.Key : Any])
        let videoString = NSAttributedString(string: "Approved", attributes: buttonStringsAttr as [NSAttributedString.Key : Any])
        let optionString = NSAttributedString(string: "", attributes: buttonStringsAttr as [NSAttributedString.Key : Any])
        
        sendMessageTextNode.maximumNumberOfLines = 2
        videoTextNode.maximumNumberOfLines = 2
        sendMessageTextNode.attributedText = messageString
        videoTextNode.attributedText = videoString
        optionTextNode.attributedText = optionString
        
        let messageButtonNode = ASButtonNode()
        messageButtonNode.setImage(UIImage.init(named: "messageicon"), for: .normal)
        
        let videoButtonNode = ASButtonNode()
        videoButtonNode.setImage(UIImage.init(named: "videoicon"), for: .normal)
        
        let optionsButtonNode = ASButtonNode()
        optionsButtonNode.setImage(UIImage.init(named: "options"), for: .normal)
        
        let messageStack = ASStackLayoutSpec.vertical()
        messageStack.spacing = 5
        messageStack.children = [messageButtonNode, sendMessageTextNode]
        messageStack.alignItems = .center
        
        let videoStack = ASStackLayoutSpec.vertical()
        videoStack.spacing = 5
        videoStack.children = [videoButtonNode, videoTextNode]
        videoStack.alignItems = .center
        
        let optionsStack = ASStackLayoutSpec.vertical()
        optionsStack.spacing = 5
        optionsStack.children = [optionsButtonNode, optionTextNode]
        optionsStack.alignItems = .center
        
        let buttonStack = ASStackLayoutSpec.horizontal()
        buttonStack.spacing = 10
        buttonStack.alignContent = .center
        buttonStack.children = [messageStack, videoStack, optionsStack]
        buttonStack.alignItems = .center
        
        messageButtonNode.addTarget(self, action: #selector(handleMessageClick), forControlEvents: .touchUpInside)
        videoButtonNode.addTarget(self, action: #selector(handleVideoClick), forControlEvents: .touchUpInside)
        optionsButtonNode.addTarget(self, action: #selector(handleReportClick), forControlEvents: .touchUpInside)
        
        return buttonStack
    }
    
    @objc func handleMessageClick(sender: UIButton){
        print("CHAT1: ", cellUser?["name"] ?? "")
        let un:String = cellUser?["name"] as! String
        if cellUser?["qbUserId"] != nil {
            let userQBId = (cellUser?["qbUserId"])! as? Int
            startChatWithUserQBId(uid: userQBId ?? 0, parent: nil, userNameToDisplay: un)
        }
        else{
            startChatWithUserQBId(uid: 0, parent: nil, userNameToDisplay: un)
        }
    }
    
    @objc func handleVideoClick(sender: UIButton){
        print("VIDEO", cellUser?["name"] ?? "")
    }
    
    @objc func handleReportClick(sender: UIButton){
        print("REPORT", cellUser?["name"] ?? "")
        reportUser(user: cellUser!, parent: nil)
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return cellPhotos.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            return ImageCellNode(userPhotoObject: self.userPhotosArray[indexPath.row], cellUser: self.cellUser!, index: indexPath.row)
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let width = UIScreen.main.bounds.width
        return ASSizeRange(min: CGSize(width: width, height: width), max: CGSize(width: width, height: width))
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
        //print("willDisplayItemWith: ", node.indexPath)
        handleDefaultUserPhotoView()
        if node.indexPath!.row > 0 {
            sendProfileView(viewedUser: cellUser!)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleSwipeForMore()
        self.stoppedScrolling()
    }
    
    func handleSwipeForMore(){
//        shouldHideMorePhotoNode = true
//        self.setNeedsLayout()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.stoppedScrolling()
        }
    }
    
    func stoppedScrolling() {
        handleDefaultUserPhotoView()
    }
    
    func handleDefaultUserPhotoView(){
        let center = self.view.convert((self._collectionNode?.view.center)!, to: self._collectionNode?.view)
        let index = self._collectionNode!.indexPathForItem(at: center)
        let x:Int = index!.row + 1
        //print("xxphoto: \(x) of \(userPhotosArray.count)")
        
        if x == 1 {
            handleMorePhotoView(isFirstCell: true, stringToDisplay: NSLocalizedString("Swipe For More", comment: ""))
        }
        else{
            handleMorePhotoView(isFirstCell: false, stringToDisplay: "\(x) / \(userPhotosArray.count)")
        }
        
        
    }
}
