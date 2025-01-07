//
//  File.swift
//  
//
//  Created by Admin on 14/08/23.
//

import Foundation
import CometChatSDK

protocol MediRecorderViewModelProtocol {
    var user: CometChatSDK.User? { get set }
    var group: CometChatSDK.Group? { get set }
    var message: BaseMessage? { get set }
    var parentMessageId: Int? { get set }
    var reset: ((Bool) -> ())? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
}

open class MediaRecorderViewModel: NSObject, MediRecorderViewModelProtocol {
    var parentMessageId: Int?
    var reset: ((Bool) -> ())?
    var failure: ((CometChatException) -> Void)?
    var user: User?
    var group: Group?
    var message: BaseMessage?
    
    init(user: User) {
        super.init()
        self.user = user
    }
    
    init(group: Group) {
        super.init()
        self.group = group
    }
}

extension MediaRecorderViewModel {
    
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
        reset?(true)
        return mediaMessage!
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
        CometChatMessageEvents.ccMessageSent(message: mediaMessage, status: .inProgress)
        MessageComposerBuilder.mediaMessage(message: mediaMessage) {(result) in
            switch result {
            case .success(let updatedMediaMessage):
                CometChatMessageEvents.ccMessageSent(message: updatedMediaMessage, status: .success)
            case .failure(let error):
                mediaMessage.metaData = ["error": true]
                CometChatMessageEvents.ccMessageSent(message: mediaMessage, status: .error)
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
        CometChatMessageEvents.ccMessageSent(message: mediaMessage, status: .inProgress)
        MessageComposerBuilder.mediaMessage(message: mediaMessage) { (result) in
            switch result {
            case .success(let updatedMediaMessage):
                CometChatMessageEvents.ccMessageSent(message: updatedMediaMessage, status: .success)
            case .failure(_):
                mediaMessage.metaData = ["error": true]
                CometChatMessageEvents.ccMessageSent(message: mediaMessage, status: .error)            }
        }
    }
}
