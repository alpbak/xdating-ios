//
//  MainScreenCollectionViewCell.swift
//  xDating
//
//  Created by Alpaslan Bak on 8.08.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit
import Parse

class MainScreenCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var lastOnlineLbel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var cellPhotos:NSArray = []
    var cellUser:PFUser?
    var userPhotosArray:[UserPhotoObject] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func setupCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib.init(nibName: "MyProfileGalleryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyProfileGalleryCollectionViewCell")
    }
    
    func setupCell(cellDict:NSDictionary){
        cellUser = nil
        cellPhotos = []
        userPhotosArray = []
        self.locationLabel.text = ""
        self.nameLabel.text = ""
        
        setupCollectionView()
        collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),at: .top, animated: false)
        
        cellUser = cellDict["user"] as? PFUser
        cellPhotos = cellDict["photos"] as! NSArray
        
//        print("cellUser: ", cellUser)
//        print("cellPhotos: ", cellPhotos)
        
        cellPhotos.forEach({ (object) in
            let temp:UserPhotoObject = UserPhotoObject.init(pfObject: object as! PFObject)
            self.userPhotosArray.append(temp)
        })
        
        collectionView.reloadData()
        setupCellTexts()
    }
    
    func setupCellTexts(){
        let name:String = cellUser?["name"] as? String ?? ""
        let age:Int = cellUser?["age"] as? Int ?? 18
        
        nameLabel.text = "\(name), \(age)"
        
        guard let locationObject:PFObject = cellUser?["location"] as? PFObject else{ return }
        locationObject.fetchIfNeededInBackground { (object, error) in
            let countryObject:PFObject = locationObject["country"] as! PFObject
            countryObject.fetchIfNeededInBackground { (cObject, error) in
                let location:String = locationObject["name"] as? String ?? ""
                let country:String = cObject?["name"] as? String ?? ""
                self.locationLabel.text = "\(location), \(country)"
            }
        }
        
        let lastOnline:Date = (cellUser?["lastOnline"] as? Date)!
        lastOnlineLbel.text = timeAgoSince(lastOnline)
        
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
        let width  = (contentView.frame.width)
        return CGSize(width: width, height: width)
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
