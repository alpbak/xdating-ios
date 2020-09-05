//
//  QuickbloxUtilities.swift
//  xDating
//
//  Created by Alpaslan Bak on 21.08.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import Foundation
import Quickblox
import QuickbloxWebRTC
import Parse

let QBDEFAULTPASSWORD:String = "qbpass1230!!*poghk"
private let chatManager = ChatManager.instance


func connectQuickBlox(){
    QBSettings.applicationID = 85647
    QBSettings.authKey = "hxdALsxfpvRyTqk"
    QBSettings.authSecret = "HKjjYYHqQYELfBz"
    QBSettings.accountKey = "BNwBVTpvQ5RLiXTjAJiW"
    QBSettings.autoReconnectEnabled = true
    QBSettings.reconnectTimerInterval = 5
    QBSettings.carbonsEnabled = true
    QBSettings.keepAliveInterval = 20
    QBSettings.streamManagementSendMessageTimeout = 0
    QBSettings.networkIndicatorManagerEnabled = false
}

func signupChat(userEmail:String, userPassword:String){
    let user = QBUUser()
    user.email = userEmail
    user.password = userPassword
    user.fullName = currentUserName()
    
    QBRequest.signUp(user, successBlock: { (qbresponse, qbuser) in
        print("CHAT SIGNUP SUCCESS-reponse: ", qbresponse)
        //print("CHAT SIGNUP USER: ", qbuser)
        saveQBUserId(qbUserId: Int(qbuser.id))
        loginChat(userEmail: userEmail, userPassword: userPassword)
        //connectToChat(user: qbuser)
        
    }) { (qberrorresponse) in
        print("signupChat-error: ", qberrorresponse.error!)
    }
}

func updateQBUser(user:QBUUser){
    let updateUserParameter = QBUpdateUserParameters()
    updateUserParameter.customData = PFUser.current()?.objectId
    
    QBRequest.updateCurrentUser(updateUserParameter, successBlock: {response, user in
        print("UPDATE QB USER - success")
    }, errorBlock: { (response) in
        print("UPDATE QB USER - error: ", response.error!)
    })
}

func loginChat(userEmail:String, userPassword:String){
    QBRequest.logIn(withUserEmail: userEmail, password: userPassword, successBlock: { (qbresponse, qbuser) in
        //print("CHAT LOGIN SUCCESS-reponse: ", qbresponse)
        print("CHAT LOGIN SUCCESS-isSuccess: ", qbresponse.isSuccess)
        //print("CHAT USER: ", qbuser)
        saveQBUserId(qbUserId: Int(qbuser.id))
        updateQBUser(user: qbuser)
        connectToChat(user: qbuser)
    }) { (qberrorresponse) in
        print("loginChat-error: ", qberrorresponse.error!)
    }
}

func checkQBAccountExists(userEmail:String){
    QBRequest.user(withEmail: userEmail, successBlock: { (response, user) in
        print("QB USER EXISTS")
        //print("checkQBAccountExists USER: ", user)
        loginChat(userEmail: currentUserEmail(), userPassword: QBDEFAULTPASSWORD)
    }, errorBlock: { (response) in
        print("QB USER NOT CREATED")
        //print("checkQBAccountExists-error: ", response.isSuccess)
        signupChat(userEmail: currentUserEmail(), userPassword: QBDEFAULTPASSWORD)
    })
}

func connectToChat(user: QBUUser) {
    Profile.synchronize(user)
    QBChat.instance.connect(withUserID: user.id, password: QBDEFAULTPASSWORD) { (error) in
        if error != nil{
            print("QBChat.instance connect - error: ", error!)
        }
        else{
            print("QBChat.instance CONNECTED")
        }
    }
}

func getUserWithId(uid:Int) -> QBUUser {
    let user = QBUUser()
    user.id = UInt(uid)
    
    return user
}

func startChatWithUserQBId(uid:Int, parent:UIViewController?, userNameToDisplay:String){
    print("startChatWithUserQBId")
    if !isUserLoggedIn() {
        print("USER NOT LOGGED IN")
        displayChatError(parent: parent, message: NSLocalizedString("Please login or register to start chatting", comment: ""))
        return
    }
    if uid == 0 {
        displayChatError(parent: parent, message: NSLocalizedString("The user can not chat at the moment", comment: ""))
        return
    }
    
    chatManager.createPrivateDialog(withOpponent: getUserWithId(uid: uid), completion: { (response, dialog) in
        guard let dialog = dialog else {
            if let error = response?.error {
                print("startChatWithUserQBId - error: ", error)
            }
            return
        }
        openNewDialog(dialog, parent: parent, userNameToDisplay: userNameToDisplay)
    })
}

private func displayChatError(parent:UIViewController?, message:String){
    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    let rootParent = appDelegate?.getRootVC()
    
    let mParent:UIViewController
    mParent = parent ?? rootParent!
    
    displayAlert(alertTitle: NSLocalizedString("", comment: ""),
                 alertMessage: message,
                 parent: mParent)
}

private func openNewDialog(_ newDialog: QBChatDialog, parent:UIViewController?, userNameToDisplay:String) {
    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    let rootParent = appDelegate?.getRootVC()
    
    let mParent:UIViewController
    mParent = parent ?? rootParent!
    
    let vc = ChatNewViewController()
    vc.dialogID = newDialog.id
    vc.userNameToDisplay = userNameToDisplay
    mParent.present(vc, animated: true, completion: nil)
}

func chatLogout(){
    
    QBChat.instance.disconnect { (error) in
        print("CHAT DISCONNECTED-error: ", error);
    }
    
}
