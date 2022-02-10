//
//  CometChatStore.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 16/12/21.
//

import Foundation
import CometChatPro

enum ConfigurationMode {
    
    case enabled
    case disabled

    var value: Bool {
        switch self {
        case .enabled:  return true
        case .disabled:  return false
        }
    }
}

public struct CometChatStore {
    
    struct conversations {
        
        static var conversationType: CometChat.ConversationType = .none
        static var hideGroupActions: Bool = true
        static var hideDeletedMessages: Bool = true
        static var hideUnreadCount: Bool = false
        static var hideTypingIndicator: Bool = false
        static var hideReadReceipts: Bool = false
        static var hideDeleteConversation: Bool = false
        static var hideStatusIndicator: Bool = false
    }
    
}
