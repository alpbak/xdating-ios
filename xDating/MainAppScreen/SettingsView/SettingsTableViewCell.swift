//
//  SettingsTableViewCell.swift
//  xDating
//
//  Created by Alpaslan Bak on 30.08.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    @IBOutlet weak var cellSwitch: UISwitch!
    @IBOutlet weak var cellLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
