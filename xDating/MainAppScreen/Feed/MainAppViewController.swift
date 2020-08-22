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
    
    @IBAction func topButtonAction(_ sender: Any) {
        print("topButtonAction")
        collectionNodeMain?.setContentOffset(CGPoint.zero, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(newUserBlock), name: Notification.Name("UserBlockedNotification"), object: nil)
        
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        //setupNode()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setLastOnline()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        setupNode()
        handleStartup()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        print("traitCollectionDidChange")
        collectionNodeMain?.view.overrideUserInterfaceStyle = .dark
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        print("willTransition")
    }
    
    @objc func newUserBlock(){
        print("NEW BLOCK")
        feedArray = cleanUpBlockedUsers(arrayToCheck: feedArray) as NSArray
        collectionNodeMain?.reloadData()
    }
    
    @objc
    private func didPullToRefresh(_ sender: Any) {
        getFeed()
        refreshControl.endRefreshing()
    }
    
    @objc func getFeed(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            displayWaitIndicator(message: NSLocalizedString("Loading", comment: ""))
        })
        
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
        hideWaitIndicator()
    }
    
    func handleStartup(){
        if isUserLoggedIn() {
            registerButton.isHidden = true
            loginButton.isHidden = true
            regisrationStackView.isHidden = true
            //registrationStackViewHeight.constant = 0
        }
        else{
            registerButton.isHidden = false
            loginButton.isHidden = false
            regisrationStackView.isHidden = false
            //registrationStackViewHeight.constant = 70
        }
        
    }
    
    func setupNode(){
        if collectionNodeMain != nil {
            return
        }
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
        self.view.bringSubviewToFront(self.regisrationStackView)
        getFeed()
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
}

