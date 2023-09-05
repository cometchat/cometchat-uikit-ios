//
//  CometChatGroupEvents.swift
 
//
//  Created by Pushpsen Airekar on 13/05/22.
//

import UIKit
import CometChatSDK
import Foundation


 public protocol CometChatDetailEventListener {
    
    func onDetailOptionUpdate(templateID: String, oldOption: CometChatDetailsOption?, newOption:CometChatDetailsOption?)
    
    func onDetailOptionAdd(templateID: String, option:CometChatDetailsOption)
   
    func onDetailOptionRemove(templateID: String, option:CometChatDetailsOption)
}

public class  CometChatDetailEvents {
    
    static private var observer = [String: CometChatDetailEventListener]()
    
    public static func addListener(_ id: String,_ observer: CometChatDetailEventListener) {
        self.observer[id] = observer
    }
    
    public static func removeListener(_ id: String) {
        self.observer.removeValue(forKey: id)
    }
    
    
    internal static  func emitOnDetailOptionUpdate(templateID: String, oldOption: CometChatDetailsOption?, newOption:CometChatDetailsOption?) {
        self.observer.forEach({
            (key,observer) in
            observer.onDetailOptionUpdate(templateID: templateID, oldOption: oldOption, newOption: newOption)
        })
    }
    
    internal static  func emitOnDetailOptionAdd(templateID: String, option:CometChatDetailsOption) {
        self.observer.forEach({
            (key,observer) in
            observer.onDetailOptionAdd(templateID: templateID, option: option)
        })
    }
    
    internal static  func emitOnDetailOptionRemove(templateID: String, option:CometChatDetailsOption) {
        self.observer.forEach({
            (key,observer) in
            observer.onDetailOptionRemove(templateID: templateID, option: option)
        })
    }
    
   
}
