//
//  AppDelegate.swift
//  xDating
//
//  Created by Alpaslan Bak on 21.07.2020.
//  Copyright © 2020 Alpaslan Bak. All rights reserved.
//

import UIKit
import Parse
import CommonKeyboard
import UserNotifications
import Quickblox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var mApplication: UIApplication!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        CommonKeyboard.shared.enabled = true
        self.window = UIWindow(frame: UIScreen.main.bounds)
        mApplication = application
        connectQuickBlox()
        connectParse()
        openMainScreen()
        return true
    }
    
    /// NOTIFICATION START
    func getNotificationPermission(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .carPlay ]) {
            (granted, error) in
            print("NOTIFICATION-Permission granted: \(granted)")
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("NOTIFICATION- settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        createInstallationOnParse(deviceTokenData: deviceToken)
        
        ///QuickBlox Push Registration
        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            return
        }
        let deviceIdentifier = identifierForVendor.uuidString
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNS
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = deviceToken
        QBRequest.createSubscription(subscription, successBlock: { (response, objects) in
            print("QB Push Subscription response: ", response)
        }, errorBlock: { (response) in
            debugPrint("[AppDelegate] createSubscription error: \(String(describing: response.error))")
        })
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("NOTIFICATION-Failed to register: \(error)")
    }

    func createInstallationOnParse(deviceTokenData:Data){
        if let installation = PFInstallation.current(){
            installation.setDeviceTokenFrom(deviceTokenData)
            installation.saveInBackground {
                (success: Bool, error: Error?) in
                if (success) {
                    print("NOTIFICATION-You have successfully saved your push installation to Back4App!")
                } else {
                    if let myError = error{
                        print("NOTIFICATION-Error saving parse installation \(myError.localizedDescription)")
                    }else{
                        print("Uknown error")
                    }
                }
            }
        }
    }

    // MARK: - AppDelegate
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("didReceiveRemoteNotification: ", userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], didReceiveRemoteNotification completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {
        
        print("didReceiveRemoteNotification-didReceiveRemoteNotification: ", userInfo)
        
    }
    /// NOTIFICATION END
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        QBChat.instance.disconnect { (error) in
            print("applicationDidEnterBackground-chat did disconnect: error: ", error)
        }
       }
    
    func applicationWillTerminate(_ application: UIApplication) {
       QBChat.instance.disconnect { (error) in
           print("applicationDidEnterBackground-chat did disconnect: error: ", error)
       }
       }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        checkChat()
       }
    
    func openMainScreen(){
        let rootController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        assert(rootController != nil, "no user interface, must be the D day")
        setRootViewController(rootController!)
    }
    
    func setRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard animated, let window = self.window else {
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
            return
        }
        
        window.rootViewController = vc
        window.makeKeyAndVisible()
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionFlipFromLeft,
                          animations: nil,
                          completion: nil)
    }
    
    func openSignUpScreen(){
        print("openSignUpScreen")
        setRootViewController(SignUpViewController())
    }
    
    func openSignUpSecondScreen(){
        print("openSignUpScreen")
        setRootViewController(SignUpSecondViewController())
    }
    
    func getRootVC() -> UIViewController {
        return (self.window?.rootViewController)!
    }
    
    func openLoginScreen(){
        print("openLoginScreen")
        setRootViewController(LoginViewController())
    }
    
    func connectParse(){
        let configuration = ParseClientConfiguration {
            $0.applicationId = "Er4D5b5gWUWuwSkKp3BL3olrJaIlE4kNxNqzoIU8"
            $0.clientKey = "0Sh5MFlkJlCP0bafUnuoYqlfdchDHPZSLJnYe7Vp"
            //$0.server = "https://parseapi.back4app.com"
            $0.server = "https://xdating.b4a.app"
            
            
        }
        Parse.initialize(with: configuration)
        
        saveInstallationObject()
        print("isUserLoggedIn(): ", isUserLoggedIn())
        checkAnonymousUser()
    }
    
    func saveInstallationObject(){
        if let installation = PFInstallation.current(){
            
            let userdefaults = UserDefaults.standard
            if isKeyPresentInUserDefaults(key: "newprofileNotification"){
                installation["newprofileNotification"] = userdefaults.bool(forKey: "newprofileNotification")
            } else {
                userdefaults.set(true, forKey: "newprofileNotification")
                installation["newprofileNotification"] = true
            }
            
            if isKeyPresentInUserDefaults(key: "newmessageNotification"){
                installation["newmessageNotification"] = userdefaults.bool(forKey: "newmessageNotification")
            } else {
                userdefaults.set(true, forKey: "newmessageNotification")
                installation["newmessageNotification"] = true
            }
            
            installation.saveInBackground {
                (success: Bool, error: Error?) in
                if (success) {
                    print("Installation saved!!!")
                } else {
                    if let myError = error{
                        print(myError.localizedDescription)
                    }else{
                        print("Uknown error")
                    }
                }
            }
        }
    }
    
    func checkAnonymousUser(){
        if PFUser.current() == nil{
            createAnonymousUser()
        }
        else{
            print("ANONYMOUS USER ALREADY CREATED")
            print("USER OBJECT ID: ", PFUser.current()?.objectId ?? "aa3")
            checkChat()
        }
    }
    
    func createAnonymousUser(){
        PFAnonymousUtils.logIn { (user, error) in
            if (error != nil){
                print("createAnonymousUser - create error: ", error?.localizedDescription ?? "aa1")
            }
            else{
                print("ANONYMOUS USER CREATED")
                print("USER OBJECT ID: ", PFUser.current()?.objectId ?? "aa2")
                self.checkChat()
            }
        }
    }
    
    func checkChat(){
        if isUserLoggedIn() {
            checkQBAccountExists(userEmail: currentUserEmail())
        }
    }
    
    
}

