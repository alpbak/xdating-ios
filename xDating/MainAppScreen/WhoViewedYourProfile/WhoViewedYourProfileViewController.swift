//
//  WhoViewedYourProfileViewController.swift
//  xDating
//
//  Created by Alpaslan Bak on 18.08.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class WhoViewedYourProfileViewController: ASViewController<ASDisplayNode>, ASCollectionDataSource, ASCollectionDelegate {
    
    
    
    
    @IBOutlet weak var notLoggedInView: NotLoggedInView!
    @IBOutlet weak var asCollectionView: ASCollectionView!
    var collectionNodeMain: ASCollectionNode?
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var noViewersLabel: UILabel!
    var feedArray:NSArray = []
    private let refreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("WhoViewedYourProfileViewController")
        notLoggedInView.isHidden = false
        noViewersLabel.text = NSLocalizedString("You have no profile viewers at this time", comment: "")
        noViewersLabel.isHidden = true
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        setupNode()
        getFeed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setLastOnline()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("WhoViewedYourProfileViewController - viewDidAppear")
        
        
        checkForLoggedIn()
        if isUserLoggedIn(){
            getFeed()
        }
    }
    
    func checkForLoggedIn(){
        if isUserLoggedIn(){
            notLoggedInView.isHidden = true
        }
        else{
            notLoggedInView.isHidden = false
            self.view.bringSubviewToFront(notLoggedInView)
            collectionNodeMain?.reloadData()
        }
    }
    
    @objc
    private func didPullToRefresh(_ sender: Any) {
        getFeed()
        refreshControl.endRefreshing()
    }
    
    func getFeed(){
        indicator.isHidden = false
        getProfileViewers { (success, results) in
            if success{
                self.handleResults(results: results as Any)
            }
            else{
                print("GET WHO VIEWED FROM CLOUD ERROR")
            }
        }
    }
    
    func handleResults(results: Any){
        feedArray = results as! NSArray
        collectionNodeMain?.reloadData()
        refreshControl.endRefreshing()
        indicator.isHidden = true
        if feedArray.count == 0 {
            noViewersLabel.isHidden = false
        }
        else{
            noViewersLabel.isHidden = true
        }
    }
    
    func setupNode(){
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        collectionNodeMain = ASCollectionNode(frame: asCollectionView.frame, collectionViewLayout: flowLayout)
        collectionNodeMain?.backgroundColor = UIColor.systemBackground
        collectionNodeMain?.dataSource = self
        collectionNodeMain?.delegate = self
        collectionNodeMain?.registerSupplementaryNode(ofKind: UICollectionView.elementKindSectionHeader)
        collectionNodeMain?.view.isScrollEnabled = true
        self.view.addSubnode(collectionNodeMain!)
        collectionNodeMain?.view.refreshControl = refreshControl
        self.view.bringSubviewToFront(indicator)
        self.view.bringSubviewToFront(noViewersLabel)
    }
    
    
    ///NODE
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        return {
            let x:NSDictionary = self.feedArray[indexPath.row]  as! NSDictionary
            return FeedCellNode(with: x)
            
        }
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return feedArray.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let width  = (collectionNode.frame.width)
        return ASSizeRange(min: CGSize(width: width, height: width+90), max: CGSize(width: width, height: width+90))
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let x:NSDictionary = feedArray[indexPath.row]  as! NSDictionary
        openUserProfile(cellDict: x)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
        let displayedCell:FeedCellNode = node as! FeedCellNode
        setProfileObjectSeen(profileObject: displayedCell.profileViewObject!)
    }
}
