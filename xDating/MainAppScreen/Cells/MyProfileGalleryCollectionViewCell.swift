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
import AsyncDisplayKit

class MyProfileGalleryCollectionViewCell: UICollectionViewCell, ASVideoNodeDelegate {
    
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var userImageView: UIImageView!
    
    var isVideoCell:Bool = false
    var videoUrl:String = ""
    var mCellUser:PFUser?
    var rootNode:ASDisplayNode?
    var alpVideoNode:ASVideoNode?
    var isVideoPlaying:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        rootNode = nil
        alpVideoNode = nil
        playerView.pause()
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        //hide or reset anything you want hereafter, for example
//        print("prepareForReuse()")
//    }
    
    func stopVideo(){
        if isVideoCell {
            
            
            if isVideoPlaying {
                isVideoPlaying = false
                print("STOP VIDEO: ", mCellUser?["name"] ?? "")
                playerView.pause()
                
            }
            
        }
    }
    
    func startVideo(){
        if isVideoCell {
            
            if !isVideoPlaying {
                isVideoPlaying = true
                print("START VIDEO: ", mCellUser?["name"] ?? "")
                guard let url = URL(string: videoUrl) else { return }
                playerView.play()
                
            }
            
        }
    }
    
    
    func handleCell(userPhotoObject:UserPhotoObject, cellUser:PFUser){
        playerView.pause()
        alpVideoNode?.pause()
        alpVideoNode = nil
        mCellUser = cellUser
        //print("userPhotoObject: ", userPhotoObject.imageFile.url)
        guard let photoUrl:String = userPhotoObject.imageFile.url else {
            return
        }
        
        if userPhotoObject.isVideo {
            isVideoCell = true
            playerView.isHidden = false
            userImageView.isHidden = true
            loadVideo(urlString: photoUrl)
            //loadVideoNode(urlString: photoUrl)
        }
        else{
            isVideoCell = false
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
        videoUrl = urlString
        playerView.setupAsset(with: url)
    }
    
    func loadVideoNode(urlString:String){
        rootNode = ASDisplayNode()
        rootNode?.frame = CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: contentView.frame.size.height)
        rootNode?.backgroundColor = UIColor.red
        
        playerView.addSubnode(rootNode!)
        
        self.alpVideoNode = ASVideoNode()
        self.alpVideoNode?.frame = CGRect(x: 0, y: 0, width: playerView.frame.size.width, height: playerView.frame.size.height)
        let mUrl:URL = URL.init(string: urlString)!
        let mAsset:AVAsset = AVAsset.init(url:mUrl)
        
        alpVideoNode?.asset = mAsset
        alpVideoNode?.delegate = self
        alpVideoNode?.shouldAutoplay = true
        alpVideoNode?.shouldAutorepeat = true
        
        rootNode?.addSubnode(alpVideoNode!)
        
        alpVideoNode?.play()
        
    }
    
    
    
    
    
}
