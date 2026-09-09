//
//  ThreadedMessageHeaderViewModel.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 15/10/24.
//

import Foundation
import CometChatSDK

public protocol ThreadedMessageHeaderViewModelProtocol {
    var parentMessage: BaseMessage? { get set }
    var incrementCount: (() -> Void)? { get set }
    var templates : [String: CometChatMessageTemplate]? { get set}
    /// Fired when the follow state changes elsewhere, e.g. from the action sheet.
    var onThreadSubscriptionChanged: ((_ isSubscribed: Bool) -> Void)? { get set }

    func connect()
    func disconnect()
}

public class ThreadedMessageHeaderViewModel: ThreadedMessageHeaderViewModelProtocol {

    /// Seam over the listener registries, so `connect()`/`disconnect()` symmetry is
    /// assertable without a live SDK. Defaults to the real registrar.
    internal var listeners: ListenerRegistering = SDKListenerRegistrar.shared

    /// Listeners are keyed by id, and registering a duplicate id evicts the previous
    /// listener — so a fixed id would leave one of two live headers silently deaf.
    public var listenerRandomID = Date().timeIntervalSince1970

    public var user: User?
    public var group: Group?
    public var parentMessage: BaseMessage? {
        didSet {
            self.user = parentMessage?.receiver as? User
            self.group = parentMessage?.receiver as? Group
        }
    }
    public var incrementCount: (() -> Void)?
    public var templates: [String : CometChatMessageTemplate]?
    public var onThreadSubscriptionChanged: ((_ isSubscribed: Bool) -> Void)?

    open func connect() {
        listeners.add(.messageEvents, id: "threaded-messages-message-listener-\(listenerRandomID)", listener: self)
        listeners.add(.threadEvents, id: "threaded-messages-thread-listener-\(listenerRandomID)", listener: self)
    }

    open func disconnect() {
        listeners.remove(.messageEvents, id: "threaded-messages-message-listener-\(listenerRandomID)")
        listeners.remove(.threadEvents, id: "threaded-messages-thread-listener-\(listenerRandomID)")
    }

}

//Thread Event
extension ThreadedMessageHeaderViewModel: CometChatThreadEventListener {

    public func ccThreadSubscriptionChanged(parentMessageId: Int, isSubscribed: Bool) {
        guard parentMessageId == parentMessage?.id else { return }
        // The message object is the source of truth, so stamp it as well as notifying —
        // otherwise a re-read of `parentMessage` (or a remount) would see a stale flag.
        parentMessage?.threadSubscribed = isSubscribed
        onThreadSubscriptionChanged?(isSubscribed)
    }
}

//Message Event
extension ThreadedMessageHeaderViewModel: CometChatMessageEventListener {
    public func onFormMessageReceived(message: FormMessage) {
        if message.parentMessageId == parentMessage?.id {
            self.incrementCount?()
        }
    }
    
    public func onSchedulerMessageReceived(message: SchedulerMessage) {
        if message.parentMessageId == parentMessage?.id {
            self.incrementCount?()
        }
    }
    
    public func onCardMessageReceived(message: CardMessage) {
        if message.parentMessageId == parentMessage?.id {
            self.incrementCount?()
        }
    }
    
    public func onCustomInteractiveMessageReceived(message: CustomInteractiveMessage) {
        if message.parentMessageId == parentMessage?.id {
            self.incrementCount?()
        }
    }
    
    public func ccMessageSent(message: BaseMessage, status: MessageStatus) {
        if parentMessage?.id == message.parentMessageId {
            switch status {
            case .inProgress:
                if let user = user{
                    if user.blockedByMe || user.hasBlockedMe{
                        break
                    }else{
                        self.incrementCount?()
                    }
                } else {
                    self.incrementCount?()
                }
            case .success:
                break
            case .error:
                break
            }
        }
    }
    
    public func onTextMessageReceived(textMessage: CometChatSDK.TextMessage) {
        if textMessage.parentMessageId == parentMessage?.id {
            self.incrementCount?()
        }
        
    }

    public func onMediaMessageReceived(mediaMessage: CometChatSDK.MediaMessage) {
        if mediaMessage.parentMessageId == parentMessage?.id {
            self.incrementCount?()
        }
        
    }

    public func onCustomMessageReceived(customMessage: CometChatSDK.CustomMessage) {
        if customMessage.parentMessageId == parentMessage?.id {
            self.incrementCount?()
        }
        
    }
    
    public func onMessageEdited(message: BaseMessage) {
        if message.id == self.parentMessage?.id {
            self.parentMessage = message
            //TODO: CC Update Message Bubble
        }
    }
    
    public func onMessageDeleted(message: BaseMessage) {
        if message.id == self.parentMessage?.id {
            self.parentMessage = message
            //TODO: CC Update Message Bubble
        }
    }
    
    public func ccMessageDeleted(message: BaseMessage) {
        if message.id == self.parentMessage?.id {
            self.parentMessage?.deletedAt = Double(Int(NSDate().timeIntervalSince1970))
            //TODO: CC Update Message Bubble
        }
    }
    
    public func ccMessageEdited(message: BaseMessage, status: MessageStatus) {
        if message.id == self.parentMessage?.id {
            self.parentMessage = message
            //TODO: CC Update Message Bubble
        }
    }
    
}
