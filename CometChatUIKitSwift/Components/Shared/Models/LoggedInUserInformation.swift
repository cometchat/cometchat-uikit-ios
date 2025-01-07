//
//  LoggedInUserInformation.swift
//  
//
//  Created by Abdullah Ansari on 01/12/22.
//

import Foundation
import CometChatSDK


final class LoggedInUserInformation {
    
    static func isLoggedInUser(uid: String?) -> Bool {
        guard let loggedInUID = CometChat.getLoggedInUser()?.uid, let uid = uid else { return false }
        return uid == loggedInUID
    }
    
    static func getName() -> String {
        guard let name = CometChat.getLoggedInUser()?.name else { return ""}
        return name
    }
    
    static func getUID() -> String {
        guard let uid = CometChat.getLoggedInUser()?.uid else { return "" }
        return uid
    }
    
    static func getUser() -> User? {
        guard let user = CometChat.getLoggedInUser() else { return nil }
        return user
    }
    
}
