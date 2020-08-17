//
//  UserProfileViewController.swift
//  xDating
//
//  Created by Alpaslan Bak on 9.08.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit
import Parse

class UserProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bioView: UIView!
    var cellDict:NSDictionary?
    var cellPhotos:NSArray = []
    var cellUser:PFUser?
    var userPhotosArray:[UserPhotoObject] = []
    @IBOutlet weak var headerNameLabel: UILabel!
    @IBOutlet weak var bioLAbel: UILabel!
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        cellUser = cellDict?["user"] as? PFUser
        cellPhotos = cellDict?["photos"] as! NSArray
        
        cellPhotos.forEach({ (object) in
            let temp:UserPhotoObject = UserPhotoObject.init(pfObject: object as! PFObject)
            self.userPhotosArray.append(temp)
        })
        
        setupCollectionView()
        collectionView.reloadData()
        print("USERID: ", cellUser?.objectId ?? "")
        headerNameLabel.text = (cellUser?["name"] ?? "") as? String
        bioLAbel.text = (cellUser?["bio"] ?? "") as? String
        
        bioView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.6)
    }
    
    func setupCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib.init(nibName: "MyProfileGalleryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyProfileGalleryCollectionViewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cellPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyProfileGalleryCollectionViewCell", for: indexPath) as! MyProfileGalleryCollectionViewCell
        
        cell.handleCell(userPhotoObject: self.userPhotosArray[indexPath.row], cellUser: cellUser!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        //let width  = (self.view.frame.width)
        let width  = (self.collectionView.frame.width)
        let height  = (self.collectionView.frame.height)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row > 0 {
            sendProfileView(viewedUser: cellUser!)
        }
        
         if (indexPath.row == cellPhotos.count - 1 ) { //it's your last cell
           print("Load more data & reload your collection view")
         }
    }


}
