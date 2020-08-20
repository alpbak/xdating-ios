//
//  UserProfileViewController.swift
//  xDating
//
//  Created by Alpaslan Bak on 9.08.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit
import Parse
import AsyncDisplayKit
import NewYorkAlert

class UserProfileViewController: UIViewController, UICollectionViewDelegateFlowLayout, ASCollectionDataSource, ASCollectionDelegate {
    
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bioView: UIView!
    @IBOutlet weak var headerNameLabel: UILabel!
    @IBOutlet weak var bioLAbel: UILabel!
    @IBOutlet weak var headerLocationLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var videoLabel: UILabel!
    @IBOutlet weak var reportLabel: UILabel!
    @IBOutlet weak var blockLabel: UILabel!
    
    var cellDict:NSDictionary?
    var cellPhotos:NSArray = []
    var cellUser:PFUser?
    var userPhotosArray:[UserPhotoObject] = []
    var collectionNodeMain: ASCollectionNode?
    
    @IBAction func messageAction(_ sender: Any) {
        print("MESSAGE")
    }
    
    @IBAction func videoAction(_ sender: Any) {
        print("VIDEO")
    }
    
    @IBAction func reportAction(_ sender: Any) {
        reportUser(user: cellUser!, parent: self)
    }
    
    @IBAction func blockAction(_ sender: Any) {
        displayBlockAlert(parent: self) { (success) in
            if success{
                self.doBlock()
            }
        }
    }
    
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cellUser = cellDict?["user"] as? PFUser
        cellPhotos = cellDict?["photos"] as! NSArray
        
        sendProfileView(viewedUser: cellUser!)
        
        messageLabel.text = NSLocalizedString("Message", comment: "")
        videoLabel.text = NSLocalizedString("Video", comment: "")
        reportLabel.text = NSLocalizedString("Report", comment: "")
        blockLabel.text = NSLocalizedString("Block", comment: "")
        
        cellPhotos.forEach({ (object) in
            let temp:UserPhotoObject = UserPhotoObject.init(pfObject: object as! PFObject)
            self.userPhotosArray.append(temp)
        })
        
        setupNode()
        
        collectionView.reloadData()
        print("USERID: ", cellUser?.objectId ?? "")
        
        headerNameLabel.text = getUserNameAndAge(user: cellUser!)
        getUserLocation(user: cellUser!) { (locStr) in
            self.headerLocationLabel.text = locStr
        }
        bioLAbel.text = (cellUser?["bio"] ?? "") as? String
        
        bioView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.6)
    }
    
    func setupNode(){
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        collectionNodeMain = ASCollectionNode(frame: CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: collectionView.frame.size.height), collectionViewLayout: flowLayout)
        collectionNodeMain?.backgroundColor = UIColor.systemBackground
        collectionNodeMain?.dataSource = self
        collectionNodeMain?.delegate = self
        //collectionNodeMain?.registerSupplementaryNode(ofKind: UICollectionView.elementKindSectionHeader)
        collectionNodeMain?.view.isScrollEnabled = true
        self.collectionView.addSubnode(collectionNodeMain!)
        collectionNodeMain?.view.isPagingEnabled = true
    }
    
    
    
    ///NODE
    
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
        return ASSizeRange(min: CGSize(width: width, height: width*1.1), max: CGSize(width: width, height: width*1.1))
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
        if node.indexPath!.row > 0 {
            sendProfileView(viewedUser: cellUser!)
        }
        
        if (node.indexPath!.row == cellPhotos.count - 1 ) { //it's your last cell
            print("Load more data & reload your collection view")
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let w:UserPhotoObject = self.userPhotosArray[indexPath.row]
        let vc = ImageViewerViewController()
        vc.imageUrl = w.imageFile.url ?? ""
        self.present(vc, animated: true, completion: nil)
    }
    
    func doBlock(){
        blockUser(userToBlock: cellUser!) { (success) in
            displayAlertWithCompletion(alertTitle: NSLocalizedString("User Blocked", comment: ""),
                                       alertMessage: NSLocalizedString("The user has been blocked succesfully.", comment: ""),
                                       parent: self) { (success) in
                                        self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
