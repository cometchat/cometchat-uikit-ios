//
//  AppDelegate.swift
//  Demo
//
//  Created by CometChat Inc. on 16/12/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.
//

import UIKit
import CometChatSDK
import CometChatUIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
   
    var window: UIWindow?
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.initialization()
                
        if CometChat.getLoggedInUser() != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainVC = storyboard.instantiateViewController(withIdentifier: "home") as! Home
            let navigationController: UINavigationController = UINavigationController(rootViewController: mainVC)
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.navigationBar.prefersLargeTitles = true
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        }
        return true
        
       
    }
    
    
    
    func initialization() {
        if(AppConstants.APP_ID.contains("Enter") || AppConstants.APP_ID.contains("ENTER") || AppConstants.APP_ID.contains("NULL") || AppConstants.APP_ID.contains("null") || AppConstants.APP_ID.count == 0) {

        } else {
            let uikitSettings = UIKitSettings()
            uikitSettings.set(appID: AppConstants.APP_ID)
                .set(authKey: AppConstants.AUTH_KEY)
                .set(region: AppConstants.REGION)
//                .overrideAdminHost(AppConstants.API_HOST)
//                .overrideClientHost(AppConstants.CLIENT_HOST)
                .subscribePresenceForAllUsers()
                .build()
            
            CometChatUIKit.init(uiKitSettings: uikitSettings, result: {
                result in
                switch result {
                case .success(_):
                    CometChat.setSource(resource: "uikit-v4", platform: "ios", language: "swift")
                    break
                case .failure(let error):
                    print( "Initialization Error:  \(error.localizedDescription)")
                    print( "Initialization Error Description:  \(error.localizedDescription)")
                    break
                }
            })
        }
    }
}
