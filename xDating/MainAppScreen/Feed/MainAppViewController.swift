//
//  MainAppViewController.swift
//  xDating
//
//  Created by Alpaslan Bak on 21.07.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit
import Parse
import AsyncDisplayKit

class MainAppViewController: ASViewController<ASDisplayNode>, ASCollectionDataSource, ASCollectionDelegate {
    
    @IBOutlet weak var asCollectionView: ASCollectionView!
    var collectionNodeMain: ASCollectionNode?
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var regisrationStackView: UIStackView!
    @IBOutlet weak var registrationStackViewHeight: NSLayoutConstraint!
    
    var feedArray:NSArray = []
    private let refreshControl = UIRefreshControl()
    
    @IBAction func loginButtonAction(_ sender: Any) {
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.openLoginScreen()
    }
    
    @IBAction func signUp(_ sender: Any) {
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.openSignUpScreen()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNode()
        //self.overrideUserInterfaceStyle = .dark
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        getFeed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLastOnline()
        handleStartup()
        
    }
    
    @objc
    private func didPullToRefresh(_ sender: Any) {
        getFeed()
        refreshControl.endRefreshing()
    }
    
    @objc func getFeed(){
        setLastOnline()
        refreshControl.beginRefreshing()
        getFeedFromCloud { (success, results) in
            if success{
                self.handleResults(results: results as Any)
            }
            else{
                print("GET FEED FROM CLOUD ERROR")
            }
        }
    }
    
    func handleResults(results: Any){
        feedArray = results as! NSArray
        collectionNodeMain?.reloadData()
        refreshControl.endRefreshing()
    }
    
    func handleStartup(){
        if isUserLoggedIn() {
            registerButton.isHidden = true
            loginButton.isHidden = true
            regisrationStackView.isHidden = true
            registrationStackViewHeight.constant = 0
        }
        else{
            registerButton.isHidden = false
            loginButton.isHidden = false
            regisrationStackView.isHidden = false
            registrationStackViewHeight.constant = 70
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
    }
    
    
    ///NODE
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        return {
            let x:NSDictionary = self.feedArray[indexPath.row]  as! NSDictionary
            return FeedCellNode(with: x)
            
        }
    }
    
//    func collectionNode(_ collectionNode: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNode {
//        let textCellNode = ASTextCellNode()
//        textCellNode.frame = CGRect.zero
//        return textCellNode
//    }
    
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
}

