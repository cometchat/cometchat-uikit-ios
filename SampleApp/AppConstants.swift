//
//  AppConstents.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 17/10/24.
//

import Foundation
import UIKit

class AppConstants {
    
    static var APP_ID: String = "26580020f03ff346"
    static var AUTH_KEY: String = "4152b0366478871f0fa8d19a287dd6f5ed5f8eff"
    static var REGION: String = "in"
}


extension AppConstants{
    static func saveAppConstants(){
        UserDefaults.standard.set(APP_ID, forKey: "appID")
        UserDefaults.standard.set(AUTH_KEY, forKey: "authKey")
        UserDefaults.standard.set(REGION, forKey: "region")
    }
    
    static func retrieveAppConstants(){
        APP_ID = UserDefaults.standard.string(forKey: "appID") ?? AppConstants.APP_ID
        AUTH_KEY = UserDefaults.standard.string(forKey: "authKey") ?? AppConstants.AUTH_KEY
        REGION = UserDefaults.standard.string(forKey: "region") ?? AppConstants.REGION
    }
}
