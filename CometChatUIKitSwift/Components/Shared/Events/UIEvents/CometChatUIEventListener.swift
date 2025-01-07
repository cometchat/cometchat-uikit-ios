//
//  CometChatUIEvents.swift
//  
//
//  Created by Pushpsen Airekar on 16/02/23.
//

import UIKit
import CometChatSDK
import Foundation

public protocol CometChatUIEventListener {
    func showPanel(id: [String:Any]?, alignment: UIAlignment, view: UIView?)
    func hidePanel(id: [String:Any]?, alignment: UIAlignment)
    func ccComposeMessage(id: [String: Any]?, message: BaseMessage)
    func openChat(user:User?, group:Group?)
    func onAiFeatureTapped(user:User?, group:Group?)
    func ccActiveChatChanged(id: [String:Any]?, lastMessage: BaseMessage?, user: User?, group: Group?)
    
    @available(*, deprecated, message: "Use `ccActiveChatChanged(_ message: TransientMessage)` instead")
    func onActiveChatChanged(id: [String:Any]?, lastMessage: BaseMessage?, user: User?, group: Group?)
}

public extension CometChatUIEventListener {
    func showPanel(id: [String: Any]?, alignment: UIAlignment, view: UIView?) {}
    func hidePanel(id: [String: Any]?, alignment: UIAlignment) {}
    func ccComposeMessage(id: [String: Any]?, message: BaseMessage) {}
    func openChat(user: User?, group: Group?) {}
    func onAiFeatureTapped(user:User?, group:Group?) {}
    func ccActiveChatChanged(id: [String:Any]?, lastMessage: BaseMessage?, user: User?, group: Group?) {}
    
    @available(*, deprecated, message: "Use `ccActiveChatChanged(_ message: TransientMessage)` instead")
    func onActiveChatChanged(id: [String: Any]?, lastMessage: BaseMessage?, user: User?, group: Group?) {}
}

public enum UIAlignment {
  case composerTop
  case composerBottom
  case messageListTop
  case messageListBottom
}
