//
//  MessageComposerViewModel.swift
//  Created by Ajay Verma on 16/12/22.
//

import Foundation
import CometChatSDK

protocol MessageComposerViewModelProtocol {
    var user: CometChatSDK.User? { get set }
    var group: CometChatSDK.Group? { get set }
    var message: BaseMessage? { get set }
    var parentMessageId: Int? { get set }
    var reset: ((Bool) -> ())? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
    var isSoundForMessageEnabled: (() -> ())? { get set }
    var typingIndicator: TypingIndicator? { get set }
}

open class MessageComposerViewModel: NSObject, MessageComposerViewModelProtocol {
    var isSoundForMessageEnabled: (() -> ())?
    var parentMessageId: Int?
    var reset: ((Bool) -> ())?
    var failure: ((CometChatException) -> Void)?
    var user: User?
    var group: Group?
    var message: BaseMessage?
    var typingIndicator: TypingIndicator?
    
    init(user: User) {
        super.init()
        self.user = user
        setTypingIndicator()
    }
    
    init(group: Group) {
        super.init()
        self.group = group
        setTypingIndicator()
    }
}

extension MessageComposerViewModel {
    
    public func setupBaseMessage(message: String) -> BaseMessage {
        let message: String = message.trimmingCharacters(in: .whitespacesAndNewlines)
        var textMessage: TextMessage?
        if !message.isEmpty {
            if let uid = self.user?.uid {
                textMessage = TextMessage(receiverUid: uid, text: message, receiverType: .user)
            } else if let guid = self.group?.guid {
                textMessage = TextMessage(receiverUid: guid, text: message, receiverType: .group)
            }
            textMessage?.muid = "\(NSDate().timeIntervalSince1970)"
            textMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
            textMessage?.sender = CometChat.getLoggedInUser()
            if let parentMessageId = parentMessageId {
                textMessage?.parentMessageId = parentMessageId
            }
        }
        
        isSoundForMessageEnabled?()
        reset?(true)
        return textMessage!
    }
    
    public func setupBaseMessage(url: String) -> BaseMessage {
        var mediaMessage: MediaMessage?
        if !url.isEmpty {
            if let uid = self.user?.uid {
                mediaMessage = MediaMessage(receiverUid: uid, fileurl: url, messageType: .audio, receiverType: .user)
            } else if let guid = self.group?.guid {
                mediaMessage = MediaMessage(receiverUid: guid, fileurl: url, messageType: .audio, receiverType: .group)
            }
            mediaMessage?.muid = "\(NSDate().timeIntervalSince1970)"
            mediaMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
            mediaMessage?.sender = CometChat.getLoggedInUser()
            if let parentMessageId = parentMessageId {
                mediaMessage?.parentMessageId = parentMessageId
            }
        }
        
        isSoundForMessageEnabled?()
        reset?(true)
        return mediaMessage!
    }
    
    public func sendTextMessageToUser(message: String) {
        self.reset?(true)
        let message: String = message.trimmingCharacters(in: .whitespacesAndNewlines)
        if !message.isEmpty {
            guard let uid = self.user?.uid else { return }
            let textMessage = TextMessage(receiverUid: uid, text: message, receiverType: .user)
            textMessage.muid =  "\(NSDate().timeIntervalSince1970)"
            textMessage.sentAt = Int(Date().timeIntervalSince1970)
            textMessage.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
            textMessage.sender = CometChat.getLoggedInUser()
            if let parentMessageId = self.parentMessageId {
                textMessage.parentMessageId = parentMessageId
            }
            self.isSoundForMessageEnabled?()
            CometChatMessageEvents.emitOnMessageSent(message: textMessage, status: .inProgress)
            MessageComposerBuilder.textMessage(message: textMessage) { result in
                switch result {
                case .success(let updatedTextMessage):
                    CometChatMessageEvents.emitOnMessageSent(message: updatedTextMessage, status: .success)
                case .failure(let error):
                    textMessage.metaData = ["error": true]
                    CometChatMessageEvents.emitOnError(message: textMessage, error: error)
                }
            }
        }
    }
    
    public func sendTextMessageToGroup(message: String) {
        reset?(true)
        let message: String = message.trimmingCharacters(in: .whitespacesAndNewlines)
        if !message.isEmpty {
            guard let guid = self.group?.guid else { return }
            let textMessage = TextMessage(receiverUid: guid, text: message, receiverType: .group)
            textMessage.muid = "\(NSDate().timeIntervalSince1970)"
            textMessage.sentAt = Int(Date().timeIntervalSince1970)
            textMessage.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
            textMessage.sender = CometChat.getLoggedInUser()
            if let parentMessageId = parentMessageId {
                textMessage.parentMessageId = parentMessageId
            }
            isSoundForMessageEnabled?()
            // Broadcasting the message sent's event with inProgress status.
            CometChatMessageEvents.emitOnMessageSent(message: textMessage, status: .inProgress)
            MessageComposerBuilder.textMessage(message: textMessage) { result in
                switch result {
                case .success(let updatedTextMessage):
                    // Broadcasting the message sent's event with sucess status.
                    CometChatMessageEvents.emitOnMessageSent(message: updatedTextMessage, status: .success)
                case .failure(let error):
                    textMessage.metaData = ["error": true]
                    // Broadcasting the message error's event.
                    CometChatMessageEvents.emitOnError(message: textMessage, error: error)
                }
                
            }
        }
    }
    
    public func sendMediaMessageToUser(url: String, type: CometChat.MessageType) {
        guard let uid =  self.user?.uid else { return }
        let mediaMessage = MediaMessage(receiverUid: uid, fileurl: url, messageType: type, receiverType: .user)
        mediaMessage.muid = "\(NSDate().timeIntervalSince1970)"
        mediaMessage.sentAt = Int(Date().timeIntervalSince1970)
        mediaMessage.sender = CometChat.getLoggedInUser()
        mediaMessage.metaData = ["fileURL": url]
        mediaMessage.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
        if let parentMessageId = parentMessageId {
            mediaMessage.parentMessageId = parentMessageId
        }
        isSoundForMessageEnabled?()
        CometChatMessageEvents.emitOnMessageSent(message: mediaMessage, status: .inProgress)
        MessageComposerBuilder.mediaMessage(message: mediaMessage) {(result) in
            switch result {
            case .success(let updatedMediaMessage):
                CometChatMessageEvents.emitOnMessageSent(message: updatedMediaMessage, status: .success)
            case .failure(let error):
                mediaMessage.metaData = ["error": true]
                CometChatMessageEvents.emitOnError(message: mediaMessage, error: error)
            }
        }
    }
    
    public func sendMediaMessageToGroup(url: String, type: CometChat.MessageType) {
        guard let uid =  self.group?.guid else { return }
        let mediaMessage = MediaMessage(receiverUid: uid, fileurl: url, messageType: type, receiverType: .group)
        if let parentMessageId = parentMessageId {
            mediaMessage.parentMessageId = parentMessageId
        }
        mediaMessage.muid = "\(NSDate().timeIntervalSince1970)"
        mediaMessage.sentAt = Int(Date().timeIntervalSince1970)
        mediaMessage.sender = CometChat.getLoggedInUser()
        mediaMessage.metaData = ["fileURL": url]
        mediaMessage.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
        isSoundForMessageEnabled?()
        CometChatMessageEvents.emitOnMessageSent(message: mediaMessage, status: .inProgress)
        MessageComposerBuilder.mediaMessage(message: mediaMessage) { (result) in
            switch result {
            case .success(let updatedMediaMessage):
                CometChatMessageEvents.emitOnMessageSent(message: updatedMediaMessage, status: .success)
            case .failure(let error):
                mediaMessage.metaData = ["error": true]
                CometChatMessageEvents.emitOnError(message: mediaMessage, error: error)
            }
        }
    }
    
    public func editTextMessage(textMessage: TextMessage, message: String?) {
        let message: String = message?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !message.isEmpty {
            textMessage.text = message
            isSoundForMessageEnabled?()
            CometChatMessageEvents.emitOnMessageEdit(message: textMessage, status: .inProgress)
            MessageComposerBuilder.editMessage(message: textMessage) { [weak self] result in
                switch result {
                case .success(let updatedTextMessage):
                    DispatchQueue.main.async { [weak self] in
                        guard let this = self else { return }
                        this.reset?(true)
                        // updated_text_message get as Action_message.
                        if let updatedTextMessage = updatedTextMessage as? TextMessage {
                            CometChatMessageEvents.emitOnMessageEdit(message: updatedTextMessage, status: .success)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async { [weak self] in
                        guard let this = self else { return }
                        this.reset?(true)
                        textMessage.metaData = ["error": true]
                        CometChatMessageEvents.emitOnError(message: textMessage, error: error)
                    }
                }
                
            }
        }
    }
    
    public func onLiveReactionClick() {
        if let user = self.user {
            let liveReaction = TransientMessage(receiverID: user.uid ?? "", receiverType: .user, data: ["type":MetadataConstants.liveReaction, "reaction": "heart"])
            CometChat.sendTransientMessage(message: liveReaction)
            // Broadcasting live reaction's event
            CometChatMessageEvents.emitOnLiveReaction(reaction: liveReaction)
            
        } else if let group = self.group {
            // TODO:- Needs to ask receiverType is correct ?
            let liveReaction = TransientMessage(receiverID: group.guid , receiverType: .group, data: ["type":MetadataConstants.liveReaction, "reaction": "heart"])
            CometChat.sendTransientMessage(message: liveReaction)
            // Broadcasting live reaction's event
            CometChatMessageEvents.emitOnLiveReaction(reaction: liveReaction)
        }
    }
    
    private func setTypingIndicator() {
        if let user = user {
            typingIndicator = TypingIndicator(receiverID: user.uid ?? "", receiverType: .user)
        }
        
        if let group = group {
            typingIndicator = TypingIndicator(receiverID: group.guid , receiverType: .group)
        }
    }
    
    public func startTyping() {
        if let typingIndicator = self.typingIndicator {
            CometChat.startTyping(indicator: typingIndicator)
        }
    }
    
    public func endTyping() {
        if let typingIndicator = self.typingIndicator {
            CometChat.endTyping(indicator: typingIndicator)
        }
    }
}

