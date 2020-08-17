//
//  ImageViewerViewController.swift
//  xDating
//
//  Created by Alpaslan Bak on 17.08.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit
import Kingfisher

class ImageViewerViewController: UIViewController, ImageScrollViewDelegate {
    
    @IBOutlet weak var imageScrollView: ImageScrollView!
    
    var imageUrl:String = ""
    @IBOutlet weak var waitIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let downloader = ImageDownloader.default
        downloader.downloadImage(with: URL(string: imageUrl)!) { result in
            switch result {
            case .success(let value):
                print(value.image)
                self.handleImage(image: value.image)
            case .failure(let error):
                print(error)
            }
        }
        
        imageScrollView.setup()
        imageScrollView.imageScrollViewDelegate = self
        imageScrollView.imageContentMode = .aspectFit
        imageScrollView.initialOffset = .center
        
    }
    
    func handleImage(image:UIImage){
        waitIndicator.isHidden = true
        imageScrollView.display(image: image)
    }


    func imageScrollViewDidChangeOrientation(imageScrollView: ImageScrollView) {
        print("Did change orientation")
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print("scrollViewDidEndZooming at scale \(scale)")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("scrollViewDidScroll at offset \(scrollView.contentOffset)")
    }
}
