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
            if parentMessage?.id != oldValue?.id {
                replyCounter = ThreadReplyCounter(base: parentMessage?.replyCount ?? 0)
            }
            self.user = parentMessage?.receiver as? User
            self.group = parentMessage?.receiver as? Group
        }
    }
    public var incrementCount: (() -> Void)?
    /// Offline ON: the whole count to show (the base from the SDK plus own pending replies).
    internal var onReplyCountChanged: ((Int) -> Void)?
    internal var replyCounter = ThreadReplyCounter()
    public var templates: [String : CometChatMessageTemplate]?
    public var onThreadSubscriptionChanged: ((_ isSubscribed: Bool) -> Void)?
    /// Fired after `parentMessage` is edited or deleted, so the header can rebuild the
    /// parent bubble. May be called off the main thread.
    public var onParentMessageUpdated: (() -> Void)?

    open func connect() {
        listeners.add(.messageEvents, id: "threaded-messages-message-listener-\(listenerRandomID)", listener: self)
        listeners.add(.threadEvents, id: "threaded-messages-thread-listener-\(listenerRandomID)", listener: self)
        listeners.add(.offlineHub, id: "threaded-messages-offline-hub-listener-\(listenerRandomID)", listener: self as OfflineHubObserver)
    }

    open func disconnect() {
        listeners.remove(.messageEvents, id: "threaded-messages-message-listener-\(listenerRandomID)")
        listeners.remove(.threadEvents, id: "threaded-messages-thread-listener-\(listenerRandomID)")
        listeners.remove(.offlineHub, id: "threaded-messages-offline-hub-listener-\(listenerRandomID)")
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
            self.replyReceived(message)
        }
    }
    
    public func onSchedulerMessageReceived(message: SchedulerMessage) {
        if message.parentMessageId == parentMessage?.id {
            self.replyReceived(message)
        }
    }
    
    public func onCardMessageReceived(message: CardMessage) {
        if message.parentMessageId == parentMessage?.id {
            self.replyReceived(message)
        }
    }
    
    public func onCustomInteractiveMessageReceived(message: CustomInteractiveMessage) {
        if message.parentMessageId == parentMessage?.id {
            self.replyReceived(message)
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
                        ownReplyPending(message)
                    }
                } else {
                    ownReplyPending(message)
                }
            case .success:
                // Offline ON: the ack never counts the reply again.
                if OfflineGate.isOn(), let key = ThreadReplyCounter.key(of: message) { replyCounter.acked(key: key) }
            case .error:
                break
            }
        }
    }

    /// An own reply is on its way. OFF: today's +1 per send. ON: +1 once per reply, tracked by key.
    private func ownReplyPending(_ message: BaseMessage) {
        guard OfflineGate.isOn(), let key = ThreadReplyCounter.key(of: message) else {
            self.incrementCount?()
            return
        }
        if replyCounter.addPending(key: key) { onReplyCountChanged?(replyCounter.count) }
    }

    /// A reply from someone else arrived. A swept one is already in the fresher parent the SDK
    /// delivers, so it is not added here (ON).
    private func replyReceived(_ message: BaseMessage) {
        if OfflineGate.isOn() {
            guard !MessageIdentity.isSyncDelivered(message) else { return }
            replyCounter.receivedReply()
            onReplyCountChanged?(replyCounter.count)
        } else {
            self.incrementCount?()
        }
    }

    /// Offline ON: an own reply that was discarded is taken back from the count.
    public func ccMessageSendStateChanged(message: BaseMessage, state: CometChatMessageSendState, reason: CometChat.MessageFailureReason?) {
        guard state == .discarded, parentMessage?.id == message.parentMessageId,
              let key = ThreadReplyCounter.key(of: message) else { return }
        if replyCounter.removePending(key: key) { onReplyCountChanged?(replyCounter.count) }
    }

    public func onTextMessageReceived(textMessage: CometChatSDK.TextMessage) {
        if textMessage.parentMessageId == parentMessage?.id {
            self.replyReceived(textMessage)
        }
        
    }

    public func onMediaMessageReceived(mediaMessage: CometChatSDK.MediaMessage) {
        if mediaMessage.parentMessageId == parentMessage?.id {
            self.replyReceived(mediaMessage)
        }
        
    }

    public func onCustomMessageReceived(customMessage: CometChatSDK.CustomMessage) {
        if customMessage.parentMessageId == parentMessage?.id {
            self.replyReceived(customMessage)
        }
        
    }
    
    public func onMessageEdited(message: BaseMessage) {
        if message.id == self.parentMessage?.id {
            self.parentMessage = message
            self.onParentMessageUpdated?()
        }
    }
    
    public func onMessageDeleted(message: BaseMessage) {
        if message.id == self.parentMessage?.id {
            self.parentMessage = message
            self.onParentMessageUpdated?()
        }
    }
    
    public func ccMessageDeleted(message: BaseMessage) {
        if message.id == self.parentMessage?.id {
            self.parentMessage?.deletedAt = message.deletedAt > 0 ? message.deletedAt : Double(Int(NSDate().timeIntervalSince1970))
            self.onParentMessageUpdated?()
        }
    }
    
    public func ccMessageEdited(message: BaseMessage, status: MessageStatus) {
        if message.id == self.parentMessage?.id {
            self.parentMessage = message
            self.onParentMessageUpdated?()
        }
    }
    
}

// MARK: - Offline hub

extension ThreadedMessageHeaderViewModel: OfflineHubObserver {

    /// The SDK delivered a fresher copy of the parent: its reply count replaces ours and the local
    /// adds are cleared.
    func offlineMessagesUpdated(_ event: OfflineMessagesUpdatedEvent) {
        guard event.gen == OfflineHub.shared.gen, let id = parentMessage?.id,
              let fresher = event.messages.first(where: { $0.id == id }) else { return }
        replyCounter.replaceParent(replyCount: fresher.replyCount)
        onReplyCountChanged?(replyCounter.count)
    }

    func offlineSessionChanged(gen: Int) {
        replyCounter = ThreadReplyCounter(base: parentMessage?.replyCount ?? 0)
    }
}
