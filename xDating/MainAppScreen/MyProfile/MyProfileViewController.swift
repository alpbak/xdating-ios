//
//  MyProfileViewController.swift
//  xDating
//
//  Created by Alpaslan Bak on 22.07.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit
import Parse
class MyProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    

    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var userPhotosArray:[UserPhotoObject] = []
    
    @IBAction func addPhotoVideo(_ sender: Any) {
        showPhotoVideoPicker(parent: self)
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        getUserDetails()
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        PFUser.logOutInBackground { (error) in
            print("LOGGED OUT")
            self.tabBarController?.selectedIndex = 0

        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupCollectionView()
        checkForLoggedIn()
        if isUserLoggedIn(){
            getUserDetails()
        }
        
        
    }
    
    func checkForLoggedIn(){
        if isUserLoggedIn(){
            addPhotoButton.isHidden = false
            refreshButton.isHidden = false
        }
        else{
            addPhotoButton.isHidden = true
            refreshButton.isHidden = true
            nameLabel.text = "REGISTER OR LOGIN!!"
            locationLabel.text = "REGISTER OR LOGIN!!"
            bioLabel.text = "REGISTER OR LOGIN!!"
            self.userPhotosArray.removeAll()
            collectionView.reloadData()
        }
    }
    
    func getUserDetails(){
        guard let user = PFUser.current() else { return }
        //print("USER: ", user)
        
        guard let photoRelation:PFRelation<PFObject> = user["userPhotos"] as? PFRelation<PFObject> else { return }
        photoRelation.query().findObjectsInBackground { (objects, error) in
            self.userPhotosArray.removeAll()
            
            objects?.forEach({ (object) in
                let temp:UserPhotoObject = UserPhotoObject.init(pfObject: object)
                self.userPhotosArray.append(temp)
            })
            self.collectionView.reloadData()
        }
        
        guard let locationObject:PFObject = user["location"] as? PFObject else{ return }
        locationObject.fetchIfNeededInBackground { (object, error) in
            self.locationLabel.text = locationObject["name"] as? String
        }
        
        nameLabel.text = user["name"] as? String
        bioLabel.text = user["bio"] as? String
        
//        print("00000")
//
//        guard let userPhotosArray:[PFObject] = user["userPhotosArray"] as? [PFObject] else{ return }
//
//        print("userPhotosArray: ", userPhotosArray)
//
//        for object:PFObject in userPhotosArray {
//            let temp:UserPhotoObject = UserPhotoObject.init(pfObject: object)
//            print("IMG URL: ", temp.imageFile.url)
//
//        }
        
    }
    
    func setupCollectionView(){
        collectionView.register(UINib.init(nibName: "MyProfileGalleryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyProfileGalleryCollectionViewCell")
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.userPhotosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyProfileGalleryCollectionViewCell", for: indexPath) as! MyProfileGalleryCollectionViewCell
        
        cell.handleCell(userPhotoObject: self.userPhotosArray[indexPath.row], cellUser: PFUser.current()!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let width  = (view.frame.width)
        return CGSize(width: width, height: width)
    }
}
