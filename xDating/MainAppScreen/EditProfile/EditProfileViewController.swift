//
//  EditProfileViewController.swift
//  xDating
//
//  Created by Alpaslan Bak on 29.08.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit
import Parse

class EditProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var ageTextField: UITextField!
    
    var dataArray:[PFObject]?
    let cellReuseIdentifier = "cell"
    var selectedLocationObject:PFObject?
    
    @IBOutlet weak var aboutYouTextView: UITextView!
    @IBOutlet weak var aboutYouLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func updateButtonAction(_ sender: Any) {
        checkForm()
    }
    
    @IBAction func locationChanged(_ sender: Any) {
        //print("what: ", locationTextField.text ?? "empty 3")
        
        guard let locString = locationTextField.text, !locString.isEmpty else {
            resetTableData()
            return
        }
        
        getLocation(str: locString) { (success, objects) in
            self.dataArray = objects
            self.handleTableData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        locationLabel.text = NSLocalizedString("Location", comment: "")
        
        aboutYouLabel.text = NSLocalizedString("About You", comment: "")
        nameLabel.text = NSLocalizedString("Name", comment: "")
        emailLabel.text = NSLocalizedString("Email", comment: "")
        ageLabel.text = NSLocalizedString("Age", comment: "")
        updateButton.setTitle(NSLocalizedString("Update", comment: ""), for: .normal)
        
        getUserDetails()
    }
    
    func getUserDetails(){
        guard let user = PFUser.current() else { return }
        
        user.fetchInBackground { (userObject, error) in
            self.setupuser()
        }
    }
    
    func setupuser(){
        guard let user = PFUser.current() else { return }
        
        emailTextField.text = user.email
        ageTextField.text = getUserAge(user: user)
        nameTextField.text = getUserName(user: user)
        
        getUserLocation(user: user) { (locStr) in
            self.locationTextField.text = locStr
        }
        
        aboutYouTextView.text = user["bio"] as? String
    }
    
    
    func getLocationName(index:Int) -> String {
        let locationObject = self.dataArray?[index]
        let countryObject:PFObject = locationObject!["country"] as! PFObject
        let locationNameStr = locationObject?["name"] ?? ""
        let locationCountryStr = countryObject["name"] ?? ""
        
        //print(locationNameStr, " ", locationCountryStr )
        
        return "\(locationNameStr), \(locationCountryStr)"
    }
    
    func resetTableData(){
        self.dataArray?.removeAll()
        self.handleTableData()
    }
    
    func handleTableData(){
        //print("handleTableData: ", dataArray?.count)
        if dataArray?.count == 0 {
            tableView.isHidden = true
        }
        else{
            tableView.isHidden = false
            tableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as UITableViewCell
        cell.textLabel?.text = getLocationName(index: indexPath.row)
        
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        selectedLocationObject = self.dataArray?[indexPath.row]
        locationTextField.text = getLocationName(index: indexPath.row)
        resetTableData()
    }
    
    func checkForm(){
        guard let user = PFUser.current() else { return }
        
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
        
        print("ALL OK")
        
        displayWaitIndicator(message: NSLocalizedString("Saving", comment: ""))
        self.view.endEditing(true)
        
        let ageInt:Int = Int(ageStr) ?? 18
        
        saveLocation()
        print("okokok")
        
        user.username = emailStr
        user["name"] = nameStr
        user["age"] = ageInt
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("NewMediaAdded"), object: nil)
        
    }
    
    func saveLocation(){
        if selectedLocationObject == nil {
            self.saveBio()
            return;
        }
        
        
        displayWaitIndicator(message: NSLocalizedString("Saving", comment: ""))
        self.view.endEditing(true)
        
        let userLocation:PFGeoPoint = selectedLocationObject?["location"] as! PFGeoPoint
        PFUser.current()!["geoLocation"] = userLocation
        PFUser.current()!["location"] = selectedLocationObject
        PFUser.current()?.saveInBackground(block: { (success, error) in
            print("USER LOCATION SAVED: - error: ", (error?.localizedDescription ?? "") as String)
            self.saveBio()
        })
    }
    
    func saveBio(){
        guard let bioStr = aboutYouTextView.text, !bioStr.isEmpty else {
            return
        }
        
        guard let user = PFUser.current() else { return }
        user["bio"] = bioStr
        user.saveInBackground { (success, error) in
            print("USER BIO SAVED: - error: ", (error?.localizedDescription ?? "") as String)
            hideWaitIndicator()
            displayAlert(alertTitle: NSLocalizedString("Success", comment: ""), alertMessage: NSLocalizedString("You profile is updated", comment: ""), parent: self)
            
        }
    }
}
