//
//  SignUpViewController.swift
//  xDating
//
//  Created by Alpaslan Bak on 20.07.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var genderControl: UISegmentedControl!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var passwordAgainLabel: UILabel!
    @IBOutlet weak var passwordAgainTextField: UITextField!
    var isFemale:Bool = false
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.openMainScreen()
    }
    
    @IBAction func registerButtonAction(_ sender: Any) {
        checkForm()
    }
    
    @IBAction func genderControlAction(_ sender: Any) {
        if genderControl.selectedSegmentIndex == 0 {
            isFemale = false
        }
        else{
            isFemale = true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let keyboardHelper = KeyboardHelper()
        //keyboardHelper.addTo(view: self.view)
        
        passwordAgainTextField.keyboardOffset = 20
        
        self.hideKeyboardWhenTappedAround()

        nameLabel.text = NSLocalizedString("Name", comment: "")
        emailLabel.text = NSLocalizedString("Email", comment: "")
        passwordLabel.text = NSLocalizedString("Password", comment: "")
        ageLabel.text = NSLocalizedString("Age", comment: "")
        passwordAgainLabel.text = NSLocalizedString("Password Again", comment: "")
        genderControl.setTitle(NSLocalizedString("I am a man", comment: ""), forSegmentAt: 0)
        genderControl.setTitle(NSLocalizedString("I am a woman", comment: ""), forSegmentAt: 1)
    }
    
    func checkForm(){
        
        guard let nameStr = nameTextField.text, !nameStr.isEmpty else {
            displayAlert(alertTitle: NSLocalizedString("Missing Info", comment: ""), alertMessage: NSLocalizedString("Please enter your name", comment: ""), parent: self)
            return
        }
        
        guard let emailStr = emailTextField.text, !emailStr.isEmpty else {
            displayAlert(alertTitle: NSLocalizedString("Missing Info", comment: ""), alertMessage: NSLocalizedString("Please enter your email", comment: ""), parent: self)
            return
        }
        
        guard let ageStr = ageTextField.text, !ageStr.isEmpty else {
            displayAlert(alertTitle: NSLocalizedString("Missing Info", comment: ""), alertMessage: NSLocalizedString("Please enter your age", comment: ""), parent: self)
            return
        }
        
        guard let passwordStr = passwordTextField.text, !passwordStr.isEmpty else {
            displayAlert(alertTitle: NSLocalizedString("Missing Info", comment: ""), alertMessage: NSLocalizedString("Please enter a password", comment: ""), parent: self)
            return
        }
        
        guard let passwordAgainStr = passwordTextField.text, !passwordAgainStr.isEmpty else {
            displayAlert(alertTitle: NSLocalizedString("Missing Info", comment: ""), alertMessage: NSLocalizedString("Please enter your password again", comment: ""), parent: self)
            return
        }
        
        if passwordStr.count < 6 {
            displayAlert(alertTitle: NSLocalizedString("Password too short", comment: ""), alertMessage: NSLocalizedString("You password must be minimum 6 characters", comment: ""), parent: self)
            return
        }
        
        if passwordStr != passwordAgainStr{
            displayAlert(alertTitle: NSLocalizedString("Password Error", comment: ""), alertMessage: NSLocalizedString("Your passwords do not match", comment: ""), parent: self)
        }
        

        print("ALL OK")
        
        displayWaitIndicator(message: NSLocalizedString("Loading", comment: ""))
        self.view.endEditing(true)
        
        let ageInt:Int = Int(ageStr) ?? 18
        
        signUp(emailStr: emailStr, passwordStr: passwordStr, nameStr: nameStr, isFemale: isFemale, age: ageInt) { (success, error) in
            hideWaitIndicator()
            if success{
                print("SIGNUP OK")
                let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.openSignUpSecondScreen()
            }
            else{
                displayAlert(alertTitle: NSLocalizedString("Error", comment: ""), alertMessage: error!.localizedDescription, parent: self)
            }
        }
    }




}
