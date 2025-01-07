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
    
    func connect()
    func disconnect()
}

public class ThreadedMessageHeaderViewModel: ThreadedMessageHeaderViewModelProtocol {
    
    public var user: User?
    public var group: Group?
    public var parentMessage: BaseMessage? {
        didSet {
            self.user = parentMessage?.receiver as? User
            self.group = parentMessage?.receiver as? Group
        }
    }
    public var incrementCount: (() -> Void)?
    
    open func connect() {
        CometChatMessageEvents.addListener("threaded-messages-message-listener", self)
    }
    
    open func disconnect() {
        CometChatMessageEvents.removeListener("threaded-messages-message-listener")
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
