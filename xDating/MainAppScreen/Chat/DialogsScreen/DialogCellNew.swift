//
//  DialogCellNew.swift
//  xDating
//
//  Created by Alpaslan Bak on 22.08.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit
import Quickblox
import Parse
import SDWebImage

class DialogCellNew: UITableViewCell {
    
    @IBOutlet weak var checkBoxImageView: UIImageView!
    @IBOutlet weak var checkBoxView: UIView!
    @IBOutlet weak var lastMessageDateLabel: UILabel!
    @IBOutlet weak var dialogLastMessage: UILabel!
    @IBOutlet weak var dialogName: UILabel!
    @IBOutlet weak var dialogAvatarLabel: UILabel!
    @IBOutlet weak var unreadMessageCounterLabel: UILabel!
    @IBOutlet weak var unreadMessageCounterHolder: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var openProfileButton: UIButton!
    @IBAction func openProfileAction(_ sender: Any) {
        print("OPENNN")
        if cellUser == nil {
            return
        }
        openUserProfileForUser(user: cellUser!)
    }
    
    var cellUser:PFUser?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkBoxImageView.contentMode = .scaleAspectFit
        unreadMessageCounterHolder.layer.cornerRadius = 12.0
        dialogAvatarLabel.setRoundedLabel(cornerRadius: 20.0)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        checkBoxView.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        let markerColor = unreadMessageCounterHolder.backgroundColor
        
        super.setSelected(selected, animated: animated)
        
        unreadMessageCounterHolder.backgroundColor = markerColor
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
        let markerColor = unreadMessageCounterHolder.backgroundColor
        
        super.setHighlighted(highlighted, animated: animated)
        
        unreadMessageCounterHolder.backgroundColor = markerColor
    }
    
    func setupUserPhoto(){
        print("Alp-setupUserPhoto")
        cellUser?.fetchInBackground(block: { (user, error) in
            let photoObject:PFObject = user?["defaultUserPhoto"] as! PFObject
            
            photoObject.fetchIfNeededInBackground { (object, error) in
                let photoFile:PFFileObject = object?["imageFile"] as! PFFileObject
                chatUserPhotoUrls[self.cellUser!.objectId!] = photoFile.url
                let defaults = UserDefaults.standard
                defaults.setValue(chatUserPhotoUrls, forKey: "chatUserPhotoUrls")
                self.displayPhoto(urlStr: photoFile.url ?? "")
            }
            
            
        })
    }
    
    func displayPhoto(urlStr:String){
        self.userImageView.isHidden = false
        //openProfileButton.isHidden = false
        self.userImageView.sd_setImage(with: URL(string: urlStr)) { (image, error, cacheType, url) in
        }
    }
    
    func setupCell(index:Int, chatDialog:QBChatDialog, cellModel:DialogTableViewCellModel){
        //print("SETUP CELL-:", cellModel.dialogUser)
        
        let defaults = UserDefaults.standard
        let dictValue = defaults.value(forKey: "chatUserPhotoUrls")
        if dictValue != nil {
            chatUserPhotoUrls = dictValue as! [String : String]
        }
        
        userImageView.isHidden = true
        //openProfileButton.isHidden = true
        
        if cellModel.dialogUser?.customData != nil {
            cellUser = PFUser()
            cellUser?.objectId = cellModel.dialogUser?.customData
                        
            if chatUserPhotoUrls.keys.contains((cellModel.dialogUser?.customData)!) {
                displayPhoto(urlStr: chatUserPhotoUrls[(cellModel.dialogUser?.customData)!]!)
            }
            else{
                setupUserPhoto()
            }
        }
        else{
            print("Alp-SETUP CELL-USEROBJECT ID: NOUSERID")
        }
        
        
        self.isExclusiveTouch = true
        self.contentView.isExclusiveTouch = true
        self.tag = index
        
        //let chatDialog = dialogs[index]
        //let cellModel = DialogTableViewCellModel(dialog: chatDialog)
        
        //tableView.allowsMultipleSelection = false
        self.checkBoxImageView.isHidden = true
        self.checkBoxView.isHidden = true
        self.unreadMessageCounterLabel.isHidden = false
        self.unreadMessageCounterHolder.isHidden = false
        self.lastMessageDateLabel.isHidden = false
        self.contentView.backgroundColor = .clear
        
        if let dateSend = chatDialog.lastMessageDate {
            self.lastMessageDateLabel.text = setupDate(dateSend)
        } else if let dateUpdate = chatDialog.updatedAt {
            self.lastMessageDateLabel.text = setupDate(dateUpdate)
        }
        
        self.unreadMessageCounterLabel.text = cellModel.unreadMessagesCounterLabelText
        self.unreadMessageCounterHolder.isHidden = cellModel.unreadMessagesCounterHiden
        
        self.dialogLastMessage.text = chatDialog.lastMessageText
        if chatDialog.lastMessageText == nil && chatDialog.lastMessageID != nil {
            self.dialogLastMessage.text = "[Attachment]"
        }
        if let dateSend = chatDialog.lastMessageDate {
            self.lastMessageDateLabel.text = setupDate(dateSend)
        } else if let dateUpdate = chatDialog.updatedAt {
            self.lastMessageDateLabel.text = setupDate(dateUpdate)
        }
        
        self.dialogName.text = cellModel.textLabelText
        self.dialogAvatarLabel.backgroundColor = UInt(chatDialog.createdAt!.timeIntervalSince1970).generateColor()
        self.dialogAvatarLabel.text = String(cellModel.textLabelText.stringByTrimingWhitespace().capitalized.first ?? Character("C"))
        
    }
}
