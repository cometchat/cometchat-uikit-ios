//
//  MessageHeaderViewModel.swift
//  
//
//  Created by admin on 28/11/22.
//
import Foundation
import CometChatSDK
import UIKit

public protocol MessageHeaderViewModelProtocol {
    var user: CometChatSDK.User? { get set }
    var group: CometChatSDK.Group?  { get set }
    var name: String? { get set }
    var updateGroupCount: ((Group) -> Void)? { get set }
    var updateTypingStatus: ((_ user: User?, _ isTyping: Bool) -> Void)? { get set }
    var updateUserStatus: ((Bool) -> Void)? { get set }
    var hideUserStatus : (()->Void)? {get set}
    var listenerRandomId: TimeInterval { get set }
    
    func set(user: User)
    func set(group: Group)
    func connect()
    func disconnect()
    func checkBlockedStatus() -> Bool
}

public class MessageHeaderViewModel: NSObject, MessageHeaderViewModelProtocol {
    public var user: User?
    public var group: Group?
    public var name: String?
    public var updateTypingStatus: ((_ user: User?, _ isTyping: Bool) -> Void)?
    public var updateUserStatus: ((Bool) -> Void)?
    public var updateGroupCount: ((Group) -> Void)?
    public var listenerRandomId = Date().timeIntervalSince1970
    public var hideUserStatus : (()->Void)?
    
    public override init() {
        super.init()
    }
    
    public func set(user: User) {
        self.user = user
    }
    
    public func set(group: Group) {
        self.group = group
    }

    public func connect() {
        CometChat.addUserListener("messages-header-user-listener-\(listenerRandomId)", self)
        CometChatMessageEvents.addListener("messages-header-message-listener-\(listenerRandomId)", self)
        CometChat.addGroupListener("messages-header-groups-sdk-listener-\(listenerRandomId)", self)
        CometChatGroupEvents.addListener("messages-header-group-event-listener-\(listenerRandomId)", self)
    }
    
    public func disconnect() {
        CometChat.removeUserListener("messages-header-user-listener-\(listenerRandomId)")
        CometChat.removeMessageListener("messages-header-message-listener-\(listenerRandomId)")
        CometChat.removeGroupListener("messages-header-groups-sdk-listener-\(listenerRandomId)")
        CometChatGroupEvents.removeListener("messages-header-group-event-listener-\(listenerRandomId)")
    }
    
    
    public func checkBlockedStatus() -> Bool {
        var status = false
        if let _user = user {
            status = _user.hasBlockedMe || _user.blockedByMe
        }
        
        return status
    }
    
}
