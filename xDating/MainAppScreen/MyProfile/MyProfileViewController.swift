//
//  MyProfileViewController.swift
//  xDating
//
//  Created by Alpaslan Bak on 22.07.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit
import Parse
import AsyncDisplayKit
import NewYorkAlert

class MyProfileViewController: UIViewController, UICollectionViewDelegateFlowLayout, ASCollectionDataSource, ASCollectionDelegate {

    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bioView: UIView!
    @IBOutlet weak var headerNameLabel: UILabel!
    @IBOutlet weak var bioLAbel: UILabel!
    @IBOutlet weak var headerLocationLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var editLabel: UILabel!
    @IBOutlet weak var addMediaButton: UIButton!
    @IBOutlet weak var addMediaLabel: UILabel!
    @IBOutlet weak var profilePhotoContainer: UIView!
    @IBOutlet weak var profilePhotoLabel: UILabel!
    @IBOutlet weak var setDefaultPhotoButton: UIButton!
    @IBOutlet weak var notLoggedInView: NotLoggedInView!
    
    @IBAction func settingsButtonAction(_ sender: Any) {
        let vc = SettingsViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        let vc = EditProfileViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func setDefaultPhotoButtonAction(_ sender: Any) {
        let selectedCell:ImageCellNode = currentDisplayedCell as! ImageCellNode
        let object:PFObject = self.userPhotoObjectsArray[selectedCell.indexPath!.row]
        
        displayChangePhotoAlert(image: (selectedCell.imageNode.image ?? UIImage.init(named: "delete"))!, objectToDelete: object)
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        let selectedCell:ImageCellNode = currentDisplayedCell as! ImageCellNode
        let object:PFObject = self.userPhotoObjectsArray[selectedCell.indexPath!.row]
        let displayedPhotoUrl:String = (selectedCell.mUserPhotoObject?.imageFile.url)!
        if displayedPhotoUrl == defaultProfilePhotoFileUrl {
            displayAlert(alertTitle: NSLocalizedString("Warning", comment: ""),
                         alertMessage: NSLocalizedString("You can't delete your profile photo", comment: ""),
                         parent: self)
        }
        else{
            displayDeleteAlert(image: (selectedCell.imageNode.image ?? UIImage.init(named: "delete"))!, objectToDelete: object)
        }
    }
    
    var userPhotosArray:[UserPhotoObject] = []
    var userPhotoObjectsArray:[PFObject] = []
    var collectionNodeMain: ASCollectionNode?
    var currentDisplayedCell:ASCellNode?
    var defaultUserPhotoObject:PFObject?
    var defaultProfilePhotoFileUrl:String?
    
    @IBAction func addPhotoVideo(_ sender: Any) {
        displayLoadingView()
        //showPhotoVideoPicker(parent: self)
        showPhotoVideoPicker(parent: self) { (image) in
            
        }
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        hideLoadingView()
        getUserDetails()
        checkForLoggedIn()
    }
    
    @IBAction func userLoggedOut(_ sender: Any) {
        print("userLoggedOut ACTION")
        hideLoadingView()
        getUserDetails()
        checkForLoggedIn()
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func logoutAction(_ sender: Any) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNode()
        
        notLoggedInView.isHidden = false
        editLabel.text = NSLocalizedString("Edit", comment: "")
        settingsLabel.text = NSLocalizedString("Settings", comment: "")
        addMediaLabel.text = NSLocalizedString("Add", comment: "")
        profilePhotoLabel.text = NSLocalizedString("This is your profile photo", comment: "")
        setDefaultPhotoButton.setTitle(NSLocalizedString("Make this your pfofile photo", comment: ""), for: .normal)
        profilePhotoContainer.isHidden = true
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(refreshAction(_:)), name: Notification.Name("NewMediaAdded"), object: nil)
        nc.addObserver(self, selector: #selector(userLoggedOut(_:)), name: Notification.Name("UserLoggedOut"), object: nil)
        
        if isUserLoggedIn(){
            getUserDetails()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkForLoggedIn()
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
    
    func checkForLoggedIn(){
        if isUserLoggedIn(){
            notLoggedInView.isHidden = true
        }
        else{
            notLoggedInView.isHidden = false
            self.view.bringSubviewToFront(notLoggedInView)
            self.userPhotosArray.removeAll()
            collectionNodeMain?.reloadData()
        }
    }
    
    func getUserDetails(){
        self.userPhotosArray.removeAll()
        self.userPhotoObjectsArray.removeAll()
        guard let user = PFUser.current() else { return }
        
        let query = PFQuery(className:"_User")
        query.includeKey("location")
        query.getObjectInBackground(withId: user.objectId!) { (retreiveduser, error) in
            self.setupuser(user: retreiveduser as! PFUser)
        }
        
//        user.fetchInBackground { (userObject, error) in
//            self.setupuser()
//        }
    }
    
    func setupuser(user:PFUser){
        //guard let user = PFUser.current() else { return }
        defaultUserPhotoObject = user["defaultUserPhoto"] as? PFObject
                
                guard let photoRelation:PFRelation<PFObject> = user["userPhotos"] as? PFRelation<PFObject> else { return }
                photoRelation.query().findObjectsInBackground { (objects, error) in
                    self.userPhotosArray.removeAll()
                    
                    objects?.forEach({ (object) in
                        let temp:UserPhotoObject = UserPhotoObject.init(pfObject: object)
                        self.userPhotosArray.append(temp)
                        self.userPhotoObjectsArray.append(object)
                        
                        if object.objectId == self.defaultUserPhotoObject?.objectId{
                            self.defaultProfilePhotoFileUrl = temp.imageFile.url
                        }
                    })
                    self.collectionNodeMain?.reloadData()
                }
                
                headerNameLabel.text = getUserNameAndAge(user: user)
                getUserLocation(user: user) { (locStr) in
                    self.headerLocationLabel.text = locStr
                }
                
                bioLAbel.text = user["bio"] as? String
    }
    
    
    ///NODE
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return userPhotosArray.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            return ImageCellNode(userPhotoObject: self.userPhotosArray[indexPath.row], cellUser: PFUser.current()!, index: indexPath.row)
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let width = UIScreen.main.bounds.width
        return ASSizeRange(min: CGSize(width: width, height: width*1.1), max: CGSize(width: width, height: width*1.1))
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
        currentDisplayedCell = node
        handleDefaultUserPhotoView()
        
        if node.indexPath!.row > 0 {
            sendProfileView(viewedUser: PFUser.current()!)
        }
        
//        if (node.indexPath!.row == userPhotosArray.count - 1 ) { //it's your last cell
//            print("Load more data & reload your collection view")
//        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let w:UserPhotoObject = self.userPhotosArray[indexPath.row]
        let vc = ImageViewerViewController()
        vc.imageUrl = w.imageFile.url ?? ""
        self.present(vc, animated: true, completion: nil)
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
        handleDefaultUserPhotoView()
    }
    
    func handleDefaultUserPhotoView(){
        let center = self.view.convert((self.collectionNodeMain?.view.center)!, to: self.collectionNodeMain?.view)
        let index = self.collectionNodeMain!.indexPathForItem(at: center)
        //print(index ?? "index not found")
        
        let centerCell:ImageCellNode = collectionNodeMain?.nodeForItem(at: index!) as! ImageCellNode
        
        handleProfileViewContainer(node: centerCell)
    }
    
    func handleProfileViewContainer(node:ASCellNode){
        profilePhotoContainer.isHidden = false
        let selectedCell:ImageCellNode = node as! ImageCellNode
        let displayedPhotoUrl:String = (selectedCell.mUserPhotoObject?.imageFile.url)!
        
        if displayedPhotoUrl == defaultProfilePhotoFileUrl {
            //profilePhotoContainer.isHidden = false
            if !selectedCell.isForVideo {
                setDefaultPhotoButton.isHidden = true
                profilePhotoLabel.isHidden = false
            }
            else{
                profilePhotoContainer.isHidden = true
            }
            
        }
        else{
            profilePhotoLabel.isHidden = true
            setDefaultPhotoButton.isHidden = false
        }
    }
    
    func displayLoadingView(){
        displayWaitIndicator(message: "Loading media")

    }
    
    func hideLoadingView(){
        hideWaitIndicator()
    }
 
    func displayDeleteAlert(image:UIImage, objectToDelete:PFObject){
        let alert = NewYorkAlertController(title: NSLocalizedString("Delete?", comment: ""),
                                           message: NSLocalizedString("Are you sure you want to delete this image?", comment: ""), style: .alert)
        alert.addImage(image)

        let ok = NewYorkButton(title: "OK", style: .default) { _ in
            self.deleteImage(objectToDelete: objectToDelete)
        }
        let cancel = NewYorkButton(title: "Cancel", style: .cancel)

        alert.addButton(ok)
        alert.addButton(cancel)

        present(alert, animated: true)
    }
    
    func deleteImage(objectToDelete:PFObject){
        displayWaitIndicator(message: NSLocalizedString("Deleting", comment: ""))
        deletePhotoObject(objectToDelete: objectToDelete) { (success) in
            hideWaitIndicator()
            self.getUserDetails()
        }
    }
    
    func displayChangePhotoAlert(image:UIImage, objectToDelete:PFObject){
        let alert = NewYorkAlertController(title: NSLocalizedString("Change?", comment: ""),
                                           message: NSLocalizedString("Are you sure you want to change your profile photo?", comment: ""), style: .alert)
        alert.addImage(image)

        let ok = NewYorkButton(title: "OK", style: .default) { _ in
            self.changePhoto(objectToDelete: objectToDelete)
        }
        let cancel = NewYorkButton(title: "Cancel", style: .cancel)

        alert.addButton(ok)
        alert.addButton(cancel)

        present(alert, animated: true)
    }
    
    func changePhoto(objectToDelete:PFObject){
        displayWaitIndicator(message: NSLocalizedString("Deleteing", comment: ""))
        
        changeDefaultUserPhoto(newUserPhotoObject: objectToDelete) { (success) in
            hideWaitIndicator()
            self.getUserDetails()
        }
    }
}
