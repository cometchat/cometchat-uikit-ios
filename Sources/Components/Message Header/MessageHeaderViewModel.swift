//
//  MessageHeaderViewModel.swift
//  
//
//  Created by admin on 28/11/22.
//

import Foundation
import CometChatSDK
import UIKit

protocol MessageHeaderViewModelProtocol {
    var user: CometChatSDK.User? { get set }
    var group: CometChatSDK.Group?  { get set }
    var name: String? { get set }
    var updateGroupCount: ((Bool) -> Void)? { get set }
    var updateTypingStatus: ((Bool) -> Void)? { get set }
    var updateUserStatus: ((Bool) -> Void)? { get set }
}

public class MessageHeaderViewModel: NSObject, MessageHeaderViewModelProtocol {
    var user: User?
    var group: Group?
    var name: String?
    var updateTypingStatus: ((Bool) -> Void)?
    var updateUserStatus: ((Bool) -> Void)?
    var updateGroupCount: ((Bool) -> Void)?
    
    init(user: User) {
        super.init()
        self.user = user
    }
    
    init(group: Group) {
        super.init()
        self.group = group
    }

    public func connect() {
        CometChat.addUserListener("messages-header-user-listener", self)
        CometChat.addMessageListener("messages-header-message-listener", self)
        
        // New
        CometChat.addGroupListener("messages-header-groups-sdk-listener", self)
        CometChatGroupEvents.addListener("messages-header-group-event-listener", self)
    }
    
    public func disconnect() {
        CometChat.removeUserListener("messages-header-user-listener")
        CometChat.removeMessageListener("messages-header-message-listener")
//
        // New
        CometChat.removeGroupListener("messages-header-groups-sdk-listener")
        CometChatGroupEvents.removeListener("messages-header-group-event-listener")
    }
}
