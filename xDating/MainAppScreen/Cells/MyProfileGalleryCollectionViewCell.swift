//
//  MyProfileGalleryCollectionViewCell.swift
//  xDating
//
//  Created by Alpaslan Bak on 22.07.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit
import Kingfisher
import AVFoundation
import Parse

class MyProfileGalleryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var userImageView: UIImageView!
    var mCellUser:PFUser?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        //hide or reset anything you want hereafter, for example
//        print("prepareForReuse()")
//    }
    
    
    func handleCell(userPhotoObject:UserPhotoObject, cellUser:PFUser){
        mCellUser = cellUser
        //print("userPhotoObject: ", userPhotoObject.imageFile.url)
        guard let photoUrl:String = userPhotoObject.imageFile.url else {
            return
        }
        
        if userPhotoObject.isVideo {
            playerView.isHidden = false
            userImageView.isHidden = true
            loadVideo(urlString: photoUrl)
        }
        else{
            playerView.isHidden = true
            userImageView.isHidden = false
            loadImage(urlString: photoUrl)
        }
    }
    
    func loadImage(urlString:String){
        let url = URL(string: urlString)
        let processor = DownsamplingImageProcessor(size: self.contentView.bounds.size)
            |> RoundCornerImageProcessor(cornerRadius: 0)
        userImageView.kf.indicatorType = .activity
        userImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholderImage"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in
//            switch result {
//            case .success(let value):
//                print("Task done for: \(value.source.url?.absoluteString ?? "")")
//            case .failure(let error):
//                print("Job failed: \(error.localizedDescription)")
//            }
        }
    }
    
    func loadVideo(urlString:String){
        print("LOAD VIDEO: ", urlString)
        guard let url = URL(string: urlString) else { return }
        playerView.play(with: url)
    }
    
    
    
}
