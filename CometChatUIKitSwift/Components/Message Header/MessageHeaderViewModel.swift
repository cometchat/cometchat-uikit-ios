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
    var onUpdate: (() -> Void)? { get set }
    var hideUserStatus : (()->Void)? {get set}
    var unHideUserStatus : (()->Void)? {get set}
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
    public var unHideUserStatus : (()->Void)?
    public var onUpdate: (() -> Void)? 

    /// Seam over the non-hermetic SDK call (logged-in user, used by the group
    /// scope-change handler). Defaults to the live SDK-backed implementation so
    /// existing callers are unaffected; tests inject a fake.
    internal var service: MessageHeaderServicing

    /// Seam over the listener registries, so `connect()`/`disconnect()` symmetry is
    /// assertable without a live SDK. Defaults to the real registrar.
    internal var listeners: ListenerRegistering

    public override init() {
        self.service = LiveMessageHeaderService()
        self.listeners = SDKListenerRegistrar.shared
        super.init()
    }

    /// Test/internal seam: inject a custom service. Listeners are registered separately
    /// via `connect()` (called by the view), so this init registers no real SDK listeners.
    internal init(service: MessageHeaderServicing,
                  listeners: ListenerRegistering = SDKListenerRegistrar.shared) {
        self.service = service
        self.listeners = listeners
        super.init()
    }

    public func set(user: User) {
        self.user = user
    }
    
    public func set(group: Group) {
        self.group = group
    }

    public func connect() {
        listeners.add(.userSDK, id: "messages-header-user-listener-\(listenerRandomId)", listener: self)
        listeners.add(.messageEvents, id: "messages-header-message-listener-\(listenerRandomId)", listener: self)
        listeners.add(.groupSDK, id: "messages-header-groups-sdk-listener-\(listenerRandomId)", listener: self)
        listeners.add(.groupEvents, id: "messages-header-group-event-listener-\(listenerRandomId)", listener: self)
        listeners.add(.userEvents, id: "messages-header-user-event-listener-\(listenerRandomId)", listener: self)
    }

    public func disconnect() {
        listeners.remove(.userSDK, id: "messages-header-user-listener-\(listenerRandomId)")
        listeners.remove(.messageSDK, id: "messages-header-message-listener-\(listenerRandomId)")
        listeners.remove(.groupSDK, id: "messages-header-groups-sdk-listener-\(listenerRandomId)")
        listeners.remove(.groupEvents, id: "messages-header-group-event-listener-\(listenerRandomId)")
        listeners.remove(.userEvents, id: "messages-header-user-event-listener-\(listenerRandomId)")
    }
    
    
    public func checkBlockedStatus() -> Bool {
        var status = false
        if let _user = user {
            status = _user.hasBlockedMe || _user.blockedByMe
        }
        
        return status
    }
    
}
