//
//  Extensions.swift
//  xDating
//
//  Created by Alpaslan Bak on 21.07.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


extension UICollectionView {
    
    var centerMostCell:UICollectionViewCell? {
        guard let superview = superview else { return nil }
        let centerInWindow = superview.convert(center, to: nil)
        guard visibleCells.count > 0 else { return nil }
        var closestCell:UICollectionViewCell?
        for cell in visibleCells {
            guard let sv = cell.superview else { continue }
            let cellFrameInWindow = sv.convert(cell.frame, to: nil)
            if cellFrameInWindow.contains(centerInWindow) {
                closestCell = cell
                break
            }
        }
        return closestCell
    }
    
}
