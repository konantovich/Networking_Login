//
//  AppDelegate.swift
//  Networking_Get_Post
//
//  Created by Antbook on 01.08.2021.
//


// Swift
//
// AppDelegate.swift
import UIKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    
    var bgSessionCompletionHandler: (()-> ())?
    
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        
        print("Yo")
        print("Update from Git")
        
        bgSessionCompletionHandler = completionHandler
         
    }
    
    
    
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        //To connect Firebase when your app starts up 
        FirebaseApp.configure()
        
        //Facebook login
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
       

        return true
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
   
        return GIDSignIn.sharedInstance.handle(url)
    }

 

}

