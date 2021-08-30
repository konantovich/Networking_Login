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
    
    
    
    
    var bgSessionCompletionHandler: (()-> ())?//сюда сохраним completionHandler из handleEventsForBackgroundURLSession

    //будет перехватывать идентификатор нашей сессии. Необходимо сохранить захваченое значение из параметра completionHandler
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        
        print("Yo")
        
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
        
        /*
        //Facebook SDK
        let appId = Settings.appID //The Facebook App ID used by the SDK.
        if url.scheme != nil && url.scheme!.hasPrefix("fb\(appId ?? "Facebook id nil")") && url.host == "autorize" {
            return ApplicationDelegate.shared.application(app, open: url, options: options)
        }
        
        
        //Google SDK
        var handled: Bool
          handled = GIDSignIn.sharedInstance.handle(url)
          if handled {
            return true
          }
         */
        return GIDSignIn.sharedInstance.handle(url)
    }

    
    
    
    
    
  
   

        

}

