//
//  CometChatUIEvents.swift
//  
//
//  Created by Pushpsen Airekar on 16/02/23.
//

import UIKit
import CometChatSDK
import Foundation


public enum UIAlignment {
  case composerTop
  case composerBottom
  case messageListTop
  case messageListBottom
}

public protocol UIEventHandler {
    
}

public protocol CometChatUIEventListener {
    func showPanel(id: [String:Any]?, alignment: UIAlignment, view: UIView?)
    func hidePanel(id: [String:Any]?, alignment: UIAlignment)
    func onActiveChatChanged(id: [String:Any]?, lastMessage: BaseMessage?, user: User?, group: Group?)
    func openChat(user:User?, group:Group?)
}

public class CometChatUIEvents : UIEventHandler {
    
    static private var observer = [String: CometChatUIEventListener]()
    
    public static func addListener(_ id: String,_ observer: CometChatUIEventListener) {
        self.observer[id] = observer
    }
    
    public static func removeListener(_ id: String) {
        self.observer.removeValue(forKey: id)
    }
    
    internal static  func emitShowPanel(id: [String:Any]?, alignment: UIAlignment, view: UIView?) {
        self.observer.forEach({
            (key,observer) in
            observer.showPanel(id: id, alignment: alignment, view: view)
        })
    }
    
    internal static  func emitHidePanel(id: [String:Any]?, alignment: UIAlignment) {
        self.observer.forEach({
            (key,observer) in
            observer.hidePanel(id: id, alignment: alignment)
        })
    }
    
    internal static  func emitOnActiveChatChanged(id: [String:Any]?, lastMessage: BaseMessage?, user: User?, group: Group?) {
        self.observer.forEach({
            (key,observer) in
            observer.onActiveChatChanged(id: id, lastMessage: lastMessage, user: user, group: group)
        })
    }
    
    internal static  func emitOnOpenChat(user: User?, group: Group?) {
        self.observer.forEach({
            (key,observer) in
            observer.openChat(user: user, group: group)
        })
    }
}
