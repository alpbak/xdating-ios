//
//  PreviewViewController.swift
//  xDating
//
//  Created by Alpaslan Bak on 11.09.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController, ImageScrollViewDelegate {
    
    @IBOutlet weak var imageScrollView: ImageScrollView!
    @IBAction func dismissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var cellImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageScrollView.setup()
        imageScrollView.imageScrollViewDelegate = self
        imageScrollView.imageContentMode = .aspectFit
        imageScrollView.initialOffset = .center
        imageScrollView.display(image: cellImage!)
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
