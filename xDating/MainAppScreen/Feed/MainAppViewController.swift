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

class MainAppViewController: ASViewController<ASDisplayNode>, ASCollectionDataSource, ASCollectionDelegate, FeedCellNodeDelegate {
    
    func didButtonPressed(selectedCell: ImageCellNode) {
        print("YEEYYY")
        let secondViewController = PreviewViewController()
        secondViewController.modalPresentationStyle = .overCurrentContext
        secondViewController.modalPresentationStyle = .popover
        secondViewController.cellImage = selectedCell.imageNode.image
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .fade
        //transition.subtype = .fromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        
        present(secondViewController, animated: false, completion: nil)

    }
    
    @IBOutlet weak var asCollectionView: ASCollectionView!
    var collectionNodeMain: ASCollectionNode?
    
    @IBOutlet weak var missinDataWaitLabel: UILabel!
    @IBOutlet weak var missingDataWaitView: UIView!
    @IBOutlet weak var missingDataButton: UIButton!
    @IBOutlet weak var missingDataLabel: UILabel!
    @IBOutlet weak var missingDataView: UIView!
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
    
    @IBAction func missingDataAction(_ sender: Any) {
        print("MISSING DATA")
    }
    
    @IBAction func topButtonAction(_ sender: Any) {
        print("topButtonAction")
        
        collectionNodeMain?.setContentOffset(CGPoint.zero, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getInitialProfileViews()
        startProfileViewListener()
        
        missinDataWaitLabel.text = NSLocalizedString("Please Wait", comment: "")
        missingDataWaitView.isHidden = true
        
        
        missingDataView.layer.cornerRadius = 10
        missingDataView.layer.borderColor = UIColor.systemRed.withAlphaComponent(1.0).cgColor
        missingDataView.layer.borderWidth = 1
        missingDataView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.8)
        
        missingDataButton.layer.cornerRadius = 10
        missingDataButton.layer.borderColor = UIColor.init(hex: "118040").cgColor
        missingDataButton.layer.borderWidth = 1
        
        registrationView.layer.borderColor = UIColor.systemBlue.cgColor
        registrationView.layer.borderWidth = 1
        
        QBChat.instance.addDelegate(self)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(newUserBlock), name: Notification.Name("UserBlockedNotification"), object: nil)
        nc.addObserver(self, selector: #selector(userLoggedOut), name: Notification.Name("UserLoggedOut"), object: nil)
        nc.addObserver(self, selector: #selector(missingDataUpdated), name: Notification.Name("MissingDataUploaded"), object: nil)
        
        
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setLastOnline()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        missingDataView.isHidden = true
        checkMissingData()
        
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
    
    @objc func missingDataUpdated(){
        print("missingDataUpdated() - MAIN FEED")
        missingDataView.isHidden = true
        checkMissingData()
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
        self.view.bringSubviewToFront(self.missingDataView)
        getFeed()
    }
    
    
    ///NODE
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        return {
            let x:NSDictionary = self.feedArray[indexPath.row]  as! NSDictionary
            let fd:FeedCellNode = FeedCellNode(with: x, parent: self)
            fd.delegate = self
            return fd
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
        //print("main-scrollViewWillBeginDragging")
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
    
    func checkMissingData(){
        if !isUserLoggedIn() {
            return
        }
        missingDataWaitView.isHidden = true
        var isPhotoMissing:Bool = true
        var isLocationMissing:Bool = true
        
        guard let user = PFUser.current() else { return }
        
        let query = PFQuery(className:"_User")
        query.includeKey("location")
        query.getObjectInBackground(withId: user.objectId!) { (retreiveduser, error) in
            
            let quote = NSLocalizedString("You have some missing information in your profile:\n", comment: "")
            let font = UIFont(name: "HelveticaNeue-Bold", size: 16)
            let attributes = [NSAttributedString.Key.font: font]
            _ = NSAttributedString(string: quote, attributes: attributes as [NSAttributedString.Key : Any])

            let stringToDisplay = NSMutableAttributedString(string: quote)

            
            if retreiveduser!["defaultUserPhoto"] == nil{
                print("MISSING DATA -- USER PHOTO")
                let attributedQuote = NSAttributedString(string: NSLocalizedString("\n- Missing Photo", comment: ""), attributes: attributes as [NSAttributedString.Key : Any])
                stringToDisplay.append(attributedQuote)
            }
            else{
                isPhotoMissing = false
            }
            
            if retreiveduser!["location"] == nil{
                print("MISSING DATA -- LOCATION")
                let attributedQuote = NSAttributedString(string: NSLocalizedString("\n- Missing Location", comment: ""), attributes: attributes as [NSAttributedString.Key : Any])
                stringToDisplay.append(attributedQuote)
            }
            else{
                isLocationMissing = false
            }
            
            if isPhotoMissing{
                self.missingDataView.isHidden = false
                self.missingDataButton.setTitle(NSLocalizedString("Add Profile Photo", comment: ""), for: .normal)
                self.missingDataButton.addTarget(self, action: #selector(self.addPhotoAction(sender:)), for: .touchUpInside)
            }
            else{
                if isLocationMissing {
                    self.missingDataButton.removeTarget(self, action: #selector(self.addPhotoAction(sender:)), for: .touchUpInside)
                    self.missingDataView.isHidden = false
                    self.missingDataButton.setTitle(NSLocalizedString("Enter Your Location", comment: ""), for: .normal)
                    self.missingDataButton.addTarget(self, action:#selector(self.addLocationAction(sender:)), for: .touchUpInside)
                }
            }
            
            self.missingDataLabel.attributedText = stringToDisplay
            
            
        }
    }
    
    @objc func addPhotoAction(sender: UIButton){
        missingDataWaitView.isHidden = false
        missingDataView.bringSubviewToFront(missingDataWaitView)
        showPhotoVideoPicker(parent: self) { (image) in
            print("PHOTO UPLOADED");
        }
    }
    
    @objc func addLocationAction(sender: UIButton){
        let vc = EditProfileViewController()
        self.present(vc, animated: true, completion: nil)
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


