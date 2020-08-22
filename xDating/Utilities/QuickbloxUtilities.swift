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

let QBDEFAULTPASSWORD:String = "qbpass1230!!*poghk"



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
    
    QBRequest.signUp(user, successBlock: { (qbresponse, qbuser) in
        print("CHAT SIGNUP SUCCESS-reponse: ", qbresponse)
        //print("CHAT SIGNUP USER: ", qbuser)
        saveQBUserId(qbUserId: Int(qbuser.id))
        connectToChat(user: qbuser)
        
    }) { (qberrorresponse) in
        print("signupChat-error: ", qberrorresponse.error!)
    }
}

func loginChat(userEmail:String, userPassword:String){
    QBRequest.logIn(withUserEmail: userEmail, password: userPassword, successBlock: { (qbresponse, qbuser) in
        //print("CHAT LOGIN SUCCESS-reponse: ", qbresponse)
        print("CHAT LOGIN SUCCESS-isSuccess: ", qbresponse.isSuccess)
        //print("CHAT USER: ", qbuser)
        saveQBUserId(qbUserId: Int(qbuser.id))
        
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
