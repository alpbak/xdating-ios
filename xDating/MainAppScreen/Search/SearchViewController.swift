//
//  SearchViewController.swift
//  xDating
//
//  Created by Alpaslan Bak on 19.08.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit
import Parse
import AsyncDisplayKit

class SearchViewController: ASViewController<ASDisplayNode>, UITableViewDelegate, UITableViewDataSource, ASCollectionDataSource, ASCollectionDelegate {

    @IBOutlet weak var asCollectionView: ASCollectionView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var noViewersLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    
    var collectionNodeMain: ASCollectionNode?
    var feedArray:NSArray = []
    var searchDataArray:[PFObject]?
    let cellReuseIdentifier = "cell"
    var selectedLocationObject:PFObject?
    
    @IBAction func locationChanged(_ sender: Any) {
        guard let locString = locationTextField.text, !locString.isEmpty else {
            resetTableData()
            return
        }
        
        getLocation(str: locString) { (success, objects) in
            self.searchDataArray = objects
            self.handleTableData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        indicator.isHidden = true
        noViewersLabel.isHidden = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        locationLabel.text = NSLocalizedString("Location", comment: "")
        
        noViewersLabel.text = NSLocalizedString("Please enter a location to search", comment: "")
        setupNode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setLastOnline()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("SearchViewController - viewDidAppear")
    }
    
    func resetTableData(){
        self.searchDataArray?.removeAll()
        self.handleTableData()
    }
    
    func handleTableData(){
        if searchDataArray?.count == 0 {
            tableView.isHidden = true
        }
        else{
            tableView.isHidden = false
            tableView.reloadData()
        }
        
    }
    
    func handleUserSearchResults(results: Any){
        feedArray = results as! NSArray
        collectionNodeMain?.reloadData()
        indicator.isHidden = true
        if feedArray.count == 0 {
            noViewersLabel.text = NSLocalizedString("No users found. Please try another location", comment: "")
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
        
        collectionNodeMain = ASCollectionNode(frame: CGRect(x: 0, y: 0, width: asCollectionView.frame.size.width, height: asCollectionView.frame.size.height), collectionViewLayout: flowLayout)
        collectionNodeMain?.backgroundColor = UIColor.systemBackground
        collectionNodeMain?.dataSource = self
        collectionNodeMain?.delegate = self
        collectionNodeMain?.registerSupplementaryNode(ofKind: UICollectionView.elementKindSectionHeader)
        collectionNodeMain?.view.isScrollEnabled = true
        self.asCollectionView.addSubnode(collectionNodeMain!)
//        self.view.bringSubviewToFront(indicator)
//        self.view.bringSubviewToFront(noViewersLabel)
//        self.view.bringSubviewToFront(tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchDataArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as UITableViewCell
        cell.textLabel?.text = getLocationName(index: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        selectedLocationObject = self.searchDataArray?[indexPath.row]
        locationTextField.text = getLocationName(index: indexPath.row)
        resetTableData()
        searchUsers()
    }
    
    func getLocationName(index:Int) -> String {
        let locationObject = self.searchDataArray?[index]
        let countryObject:PFObject = locationObject!["country"] as! PFObject
        let locationNameStr = locationObject?["name"] ?? ""
        let locationCountryStr = countryObject["name"] ?? ""
                
        return "\(locationNameStr), \(locationCountryStr)"
    }
    
    func searchUsers(){
        //print("selectedLocationObject: ", selectedLocationObject)
        getSearchResuts(locationId: (selectedLocationObject?.objectId)!) { (success, results) in
            if success{
                self.handleUserSearchResults(results: results as Any)
            }
            else{
                print("SEARCHVIEW CLOUD ERROR")
            }
        }
        indicator.isHidden = false
    }
    

    ///NODE
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        return {
            let x:NSDictionary = self.feedArray[indexPath.row]  as! NSDictionary
            return FeedCellNode(with: x, parent: self)
            
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
//        let displayedCell:FeedCellNode = node as! FeedCellNode
//        setProfileObjectSeen(profileObject: displayedCell.profileViewObject!)
    }
}
