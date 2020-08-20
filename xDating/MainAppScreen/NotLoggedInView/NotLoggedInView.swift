//
//  NotLoggedInView.swift
//  xDating
//
//  Created by Alpaslan Bak on 20.08.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import Foundation
import UIKit

class NotLoggedInView: UIView {
    class var nibName : String {
        return "NotLoggedInView"
    }
    
    var message = "" {
        didSet {
            self.headerLabel.text = message
        }
    }
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    
    @IBAction func registerButtonAction(_ sender: Any) {
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.openSignUpScreen()
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.openLoginScreen()
    }
    
    let contentWidth: CGFloat = 350
    let contentHeight: CGFloat = 280
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fromNib()
        setupView()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fromNib()
        setupView()
     }
    
    func setupView(){
        headerLabel.text = NSLocalizedString("You are not logged in", comment: "")
        registerButton.setTitle(NSLocalizedString("Register", comment: ""), for: .normal)
        loginButton.setTitle(NSLocalizedString("Login", comment: ""), for: .normal)
    }
}
