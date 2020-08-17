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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mApplication: UIApplication!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        CommonKeyboard.shared.enabled = true
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        mApplication = application
        connectParse()
        
        //setRootViewController(MainAppViewController())
        openMainScreen()
        return true
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
            $0.server = "https://parseapi.back4app.com"
        }
        Parse.initialize(with: configuration)
        
        saveInstallationObject()
        print("isUserLoggedIn(): ", isUserLoggedIn())
        checkAnonymousUser()
    }
    
    func saveInstallationObject(){
            if let installation = PFInstallation.current(){
                installation.saveInBackground {
                    (success: Bool, error: Error?) in
                    if (success) {
                        //print("You have successfully connected your app to Back4App!")
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
            }
        }
    }


}

