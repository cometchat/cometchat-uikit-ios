//
//  CometChatUserEvents.swift
 
//
//  Created by Pushpsen Airekar on 13/05/22.
//

import UIKit
import CometChatSDK
import Foundation


@objc public protocol CometChatUserEventListener {

    func onUserBlock(user: User)
    func onUserUnblock(user: User)
}

public class CometChatUserEvents {
    
    static private var observer = [String: CometChatUserEventListener]()
    
    @objc public static func addListener(_ id: String,_ observer: CometChatUserEventListener) {
        self.observer[id] = observer
    }
    @objc public static func removeListener(_ id: String) {
        self.observer.removeValue(forKey: id)
    }
    
    internal static  func emitOnUserBlock(user: User) {
        self.observer.forEach({
            (key,observer) in
            observer.onUserBlock(user: user)
        })
    }
    
    internal static  func emitOnUserUnblock(user: User) {
        self.observer.forEach({
            (key,observer) in
            observer.onUserUnblock(user: user)
        })
    }

}
