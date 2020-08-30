//
//  SettingsViewController.swift
//  xDating
//
//  Created by Alpaslan Bak on 30.08.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func closeButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }

    ///TABLEVIEW
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        else if section == 1 {
            return 3
        }
        else{
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("Notifications", comment: "")
        }
        else if section == 1 {
            return NSLocalizedString("General", comment: "")
        }
        else{
            return NSLocalizedString("Info", comment: "")
        }
    }
    
//    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "SettingsTableViewCell"
        var cell: SettingsTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? SettingsTableViewCell

        if cell == nil {
            tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? SettingsTableViewCell
        }
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.cellLabel.text = "New profile views"
                cell.cellSwitch.tag = 0

            }
            else if indexPath.row == 1{
                cell.cellLabel.text = "New messages"
                cell.cellSwitch.tag = 1
            }
        }

        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.cellLabel.text = "Setting test 1"
                cell.cellSwitch.tag = 2
            }
            else if indexPath.row == 1{
                cell.cellLabel.text = "Setting test 2"
                cell.cellSwitch.tag = 3
            }
            else if indexPath.row == 2{
                cell.cellLabel.text = "Setting test 3"
                cell.cellSwitch.tag = 4
            }
        }
        
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                cell.cellLabel.text = "Terms of service"
                cell.cellSwitch.isHidden = true
                cell.cellSwitch.tag = 5
            }
            else if indexPath.row == 1{
                cell.cellLabel.text = "Privacy policy"
                cell.cellSwitch.isHidden = true
                cell.cellSwitch.tag = 6
            }
        }
        
        cell.cellSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    @objc func switchChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        print("SWITCH.TAG: ", mySwitch.tag)
        print("SWITCH.isOn: ", mySwitch.isOn)
    }
}
