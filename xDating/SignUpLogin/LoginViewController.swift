//
//  LoginViewController.swift
//  xDating
//
//  Created by Alpaslan Bak on 22.07.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.openMainScreen()
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        checkForm()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailLabel.text = NSLocalizedString("Email", comment: "")
        passwordLabel.text = NSLocalizedString("Password", comment: "")
        
    }


    func checkForm(){
        guard let emailStr = emailTextField.text, !emailStr.isEmpty else {
            displayAlert(alertTitle: NSLocalizedString("Missing Info", comment: ""), alertMessage: NSLocalizedString("Please enter your email", comment: ""), parent: self)
            return
        }
        
        guard let passwordStr = passwordTextField.text, !passwordStr.isEmpty else {
            displayAlert(alertTitle: NSLocalizedString("Missing Info", comment: ""), alertMessage: NSLocalizedString("Please enter a password", comment: ""), parent: self)
            return
        }
        
        if passwordStr.count < 6 {
            displayAlert(alertTitle: NSLocalizedString("Password too short", comment: ""), alertMessage: NSLocalizedString("You password must be minimum 6 characters", comment: ""), parent: self)
            return
        }
        print("ALL OK")
        
        displayWaitIndicator(message: NSLocalizedString("Loading", comment: ""))
        self.view.endEditing(true)
        
        
        login(emailStr: emailStr, passwordStr: passwordStr) { (success, error) in
            hideWaitIndicator()
            if success{
                print("LOGIN OK")
                let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.openMainScreen()
            }
            else{
                displayAlert(alertTitle: NSLocalizedString("Error", comment: ""), alertMessage: error!.localizedDescription, parent: self)
            }
        }
    }

}
