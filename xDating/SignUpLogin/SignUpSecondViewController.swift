//
//  SignUpSecondViewController.swift
//  xDating
//
//  Created by Alpaslan Bak on 21.07.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit
import Parse


class SignUpSecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var dataArray:[PFObject]?
    let cellReuseIdentifier = "cell"
    var selectedLocationObject:PFObject?
    
    @IBOutlet weak var aboutYouTextView: UITextView!
    @IBOutlet weak var aboutYouLabel: UILabel!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBAction func photoButtonAction(_ sender: Any) {
        showPhotoVideoPicker(parent: self)
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        if selectedLocationObject == nil {
            displayAlert(alertTitle: NSLocalizedString("Missing Info", comment: ""), alertMessage: NSLocalizedString("Please select your location", comment: ""), parent: self)
            return
        }
        saveLocation()
        print("okokok")
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
        nextButton.setTitle(NSLocalizedString("Save Bio & Location", comment: ""), for: .normal)
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
    
    func getLocationName(index:Int) -> String {
        let locationObject = self.dataArray?[index]
        let countryObject:PFObject = locationObject!["country"] as! PFObject
        let locationNameStr = locationObject?["name"] ?? ""
        let locationCountryStr = countryObject["name"] ?? ""
        
        //print(locationNameStr, " ", locationCountryStr )
        
        return "\(locationNameStr), \(locationCountryStr)"
    }
    
    func saveLocation(){
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
            self.returnToMainApp()
        }
    }
    
    func returnToMainApp(){
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.openMainScreen()
    }
    
    
}


