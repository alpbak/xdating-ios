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
import Quickblox
import ParseLiveQuery

class MainAppViewController: ASViewController<ASDisplayNode>, ASCollectionDataSource, ASCollectionDelegate {
    
    @IBOutlet weak var asCollectionView: ASCollectionView!
    var collectionNodeMain: ASCollectionNode?
    
    @IBOutlet weak var registrationView: UIView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var regisrationStackView: UIStackView!
    @IBOutlet weak var registrationStackViewHeight: NSLayoutConstraint!
    
    var feedArray:NSArray = []
    private let refreshControl = UIRefreshControl()
    var profilesUptading = false
    
    @IBAction func loginButtonAction(_ sender: Any) {
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.openLoginScreen()
    }
    
    @IBAction func signUp(_ sender: Any) {
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.openSignUpScreen()
    }
    
    var client : ParseLiveQuery.Client!
    var subscription : Subscription<ProfileView>!
    
    @IBAction func topButtonAction(_ sender: Any) {
        print("topButtonAction")
        
        collectionNodeMain?.setContentOffset(CGPoint.zero, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getInitialProfileViews()
        startProfileViewListener()
        
        registrationView.layer.borderColor = UIColor.systemBlue.cgColor
        registrationView.layer.borderWidth = 1
        
        QBChat.instance.addDelegate(self)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(newUserBlock), name: Notification.Name("UserBlockedNotification"), object: nil)
        nc.addObserver(self, selector: #selector(userLoggedOut), name: Notification.Name("UserLoggedOut"), object: nil)
        
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
    
    @objc func userLoggedOut(){
        print("userLoggedOut() - MAIN FEED")
        handleStartup()
        self.tabBarController?.tabBar.items?[3].badgeValue = nil
        
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
            registrationView.isHidden = true
        }
        else{
            registerButton.isHidden = false
            loginButton.isHidden = false
            registrationView.isHidden = false
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
        self.view.bringSubviewToFront(self.registrationView)
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

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("main-scrollViewWillBeginDragging")
        if !isUserLoggedIn() {
            registrationView.fadeOut()
        }
        
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.stoppedScrolling()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.stoppedScrolling()
        }
    }

    func stoppedScrolling() {
        if !isUserLoggedIn() {
            registrationView.fadeIn()
        }
        
    }
    
    func setUnreadMessageCount(){
        if !isUserLoggedIn() {
            return
        }
        let chatManager = ChatManager.instance
        chatManager.updateStorage()
        chatManager.storage.setTotalUnreadMessageCount { (unreadMessageCount) in
            if unreadMessageCount == 0 {
                self.tabBarController?.tabBar.items?[3].badgeValue = nil
            }
            else{
                self.tabBarController?.tabBar.items?[3].badgeValue = "\(unreadMessageCount)"
            }
        }
    }
    
    func getInitialProfileViews(){
        getProfileViewsCount { (unseenProfileViewCount) in
            self.setProfileViewVadge(unseenProfileViewCount: Int(unseenProfileViewCount))
        }
    }
    
    func startProfileViewListener(){
        guard let user = PFUser.current() else { return }
        
        var profileQuery: PFQuery<ProfileView> {
            return (ProfileView.query()!
                .whereKey("viewed", equalTo: user)
                .whereKeyExists("viewer")
                .whereKey("notSeen", equalTo: true)
                .order(byAscending: "createdAt")) as! PFQuery<ProfileView>
        }
        
        
        client = ParseLiveQuery.Client()
        //        subscription = client.subscribe(profileQuery)
        //            // handle creation events, we can also listen for update, leave, enter events
        //            .handle(Event.created) { _, armor in
        //                print("\(armor)")
        //        }
        
        subscription = client.subscribe(profileQuery).handleEvent({ (profiles, event) in
            print("ABC-profiles: ", profiles)
            //print("ABC-event: ", event)
            
            self.updateProfileViewBadge(query: profiles)
            
            //                switch event {
            //                case .entered(_):
            //                    print("ABC-ENTERED")
            //                case .left(_):
            //                    print("ABC-LEFT")
            //                case .created(_):
            //                    print("ABC-CREATED")
            //                case .updated(_):
            //                    print("ABC-UPDATED")
            //                case .deleted(_):
            //                    print("ABC-DELETED")
            //                }
        })
    }
    
    func updateProfileViewBadge(query:PFQuery<ProfileView>){
        
        if !profilesUptading {
            profilesUptading = true
            query.countObjectsInBackground { (unseenProfileViewCount, error) in
                //print("ABC- COUNT: ", unseenProfileViewCount)
                self.setProfileViewVadge(unseenProfileViewCount: Int(unseenProfileViewCount))
                self.profilesUptading = false
            }
        }
    }
    
    func setProfileViewVadge(unseenProfileViewCount:Int){
        //print("ABC-setProfileViewVadge:")
        if unseenProfileViewCount == 0 {
            self.tabBarController?.tabBar.items?[1].badgeValue = nil
        }
        else{
            self.tabBarController?.tabBar.items?[1].badgeValue = "\(unseenProfileViewCount)"
        }
    }
}

extension MainAppViewController : QBChatDelegate {
    func chatDidReceive(_ message: QBChatMessage) {
        //print("ALPP - chatDidReceive")
        setUnreadMessageCount()
    }
    func chatDidConnect() {
        //print("ALPP - chatDidConnect")
        setUnreadMessageCount()
    }
    func chatDidReconnect() {
        //print("ALPP - chatDidReconnect")
    }
    func chatDidDisconnectWithError(_ error: Error) {
        //print("ALPP - chatDidDisconnectWithError")
    }
    func chatDidNotConnectWithError(_ error: Error) {
        //print("ALPP - chatDidNotConnectWithError")
    }
}
