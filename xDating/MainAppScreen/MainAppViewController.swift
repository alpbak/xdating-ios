//
//  MainAppViewController.swift
//  xDating
//
//  Created by Alpaslan Bak on 21.07.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit
import Parse

class MainAppViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var regisrationStackView: UIStackView!
    @IBOutlet weak var registrationStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
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
        collectionView.delegate = self
        collectionView.dataSource = self
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControl // iOS 10+

        setupCollectionView()
        
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
        collectionView.reloadData()
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
    
    func setupCollectionView(){
        collectionView.register(UINib.init(nibName: "MainScreenCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MainScreenCollectionViewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        feedArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainScreenCollectionViewCell", for: indexPath) as! MainScreenCollectionViewCell
        
        let x:NSDictionary = feedArray[indexPath.row]  as! NSDictionary
        cell.setupCell(cellDict: x)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        //let width  = (view.frame.width)
        let width  = (collectionView.frame.width)
        return CGSize(width: width, height: width+20)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let x:NSDictionary = feedArray[indexPath.row]  as! NSDictionary
        
        let vc = UserProfileViewController()
        vc.cellDict = x
        self.present(vc, animated: true) {
            
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        print("willDisplay: ", indexPath.row)
//        //let mCell:MainScreenCollectionViewCell = cell as! MainScreenCollectionViewCell
//
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        print("didEndDisplaying: ", indexPath.row)
//        //let mCell:MainScreenCollectionViewCell = cell as! MainScreenCollectionViewCell
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if collectionView.centerMostCell != nil {
//            let centerCell:MainScreenCollectionViewCell = collectionView.centerMostCell as! MainScreenCollectionViewCell
//            centerCell.startVideos()
//
//            //print("WHAT: ", centerCell.cellUser?["name"])
//
//
//            for cell in collectionView.visibleCells as [UICollectionViewCell]    {
//                //let indexPath = collectionView.indexPath(for: cell as UICollectionViewCell)
//                let invisibleCell:MainScreenCollectionViewCell = cell as! MainScreenCollectionViewCell
//                invisibleCell.stopVideos()
//            }
//
//        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //print("scrollViewWillBeginDragging")
        handleVideos()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //print("scrollViewDidEndDecelerating")
        handleVideos()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //print("scrollViewWillEndDragging-velocity. ", velocity)
        if velocity.y == 0{
            handleVideos()
        }
        
    }
    
    func handleVideos(){
        if collectionView.centerMostCell != nil {
            let centerCell:MainScreenCollectionViewCell = collectionView.centerMostCell as! MainScreenCollectionViewCell
            centerCell.startVideos()
            
            //print("WHAT: ", centerCell.cellUser?["name"])
            
            
            for cell in collectionView.visibleCells as [UICollectionViewCell]    {
                //let indexPath = collectionView.indexPath(for: cell as UICollectionViewCell)
                let invisibleCell:MainScreenCollectionViewCell = cell as! MainScreenCollectionViewCell
                if invisibleCell != centerCell {
                    invisibleCell.stopVideos()
                }
                
            }
            
        }
    }
}


