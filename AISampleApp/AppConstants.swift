import Foundation
import UIKit

/// Your CometChat credentials — get them from https://app.cometchat.com/
/// (App ID and Region on the app overview, Auth Key under API & Auth Keys).
class AppConstants {

    static var APP_ID: String = "XXXXXXXXX"
    static var AUTH_KEY: String = "XXXXXXXXX"
    static var REGION: String = "XXXXXXXXX"
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
