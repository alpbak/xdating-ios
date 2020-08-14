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

extension UIView {
    // MARK: - Config
    /// The default duration for fading-animations, measured in seconds.
    public static let defaultFadingAnimationDuration: TimeInterval = 1.0

    // MARK: - Public methods
    /// Updates the view visiblity.
    ///
    /// - Parameters:
    ///   - isHidden: The new view visibility.
    ///   - duration: The duration of the animation, measured in seconds.
    ///   - completion: Closure to be executed when the animation sequence ends. This block has no return value and takes a single Boolean
    ///                 argument that indicates whether or not the animations actually finished before the completion handler was called.
    ///
    /// - SeeAlso: https://developer.apple.com/documentation/uikit/uiview/1622515-animatewithduration
    public func animate(isHidden: Bool, duration: TimeInterval = UIView.defaultFadingAnimationDuration, completion: ((Bool) -> Void)? = nil) {
        if isHidden {
            fadeOut(duration: duration,
                    completion: completion)
        } else {
            fadeIn(duration: duration,
                   completion: completion)
        }
    }

    /// Fade out the current view by animating the `alpha` to zero and update the `isHidden` flag accordingly.
    ///
    /// - Parameters:
    ///   - duration: The duration of the animation, measured in seconds.
    ///   - completion: Closure to be executed when the animation sequence ends. This block has no return value and takes a single Boolean
    ///                 argument that indicates whether or not the animations actually finished before the completion handler was called.
    ///
    /// - SeeAlso: https://developer.apple.com/documentation/uikit/uiview/1622515-animatewithduration
    public func fadeOut(duration: TimeInterval = UIView.defaultFadingAnimationDuration, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration,
                       animations: {
                           self.alpha = 0.0
                       },
                       completion: { isFinished in
                           // Update `isHidden` flag accordingly:
                           //  - set to `true` in case animation was completely finished.
                           //  - set to `false` in case animation was interrupted, e.g. due to starting of another animation.
                           self.isHidden = isFinished

                           completion?(isFinished)
        })
    }

    /// Fade in the current view by setting the `isHidden` flag to `false` and animating the `alpha` to one.
    ///
    /// - Parameters:
    ///   - duration: The duration of the animation, measured in seconds.
    ///   - completion: Closure to be executed when the animation sequence ends. This block has no return value and takes a single Boolean
    ///                 argument that indicates whether or not the animations actually finished before the completion handler was called.
    ///
    /// - SeeAlso: https://developer.apple.com/documentation/uikit/uiview/1622515-animatewithduration
    public func fadeIn(duration: TimeInterval = UIView.defaultFadingAnimationDuration, completion: ((Bool) -> Void)? = nil) {
        if isHidden {
            // Make sure our animation is visible.
            isHidden = false
        }

        UIView.animate(withDuration: duration,
                       animations: {
                           self.alpha = 1.0
                       },
                       completion: completion)
    }
}
