//
//  File.swift
//  
//
//  Created by Abdullah Ansari on 03/02/23.
//

import Foundation
import CometChatSDK

extension ConversationsViewModel: CometChatMessageEventListener {
    
    func onMessageSent(message: BaseMessage, status: MessageStatus) {
        if status == .success {
            update(lastMessage: message)
        }
        print("ConversationsViewModel - events - onMessageSent")
    }
    
    func onMessageEdit(message: BaseMessage, status: MessageStatus) {
        /*
         if incoming message and last message is matching
         updateConversation()
         */
        
        print("ConversationsViewModel - events - onMessageEdit")
    }
    
    func onMessageDelete(message: BaseMessage) {
        /*
         
         // if incoming message and last message is matching.
            then { update conversation }
         
         */
        
        print("ConversationsViewModel - events - onMessageDelete")
    }

    func onMessageReply(message: BaseMessage, status: MessageStatus) {
        
        print("ConversationsViewModel - events - onMessageReply")
    }
    
    func onMessageRead(message: BaseMessage) {
        
        /*
         if incoming message && last message is matching
            reset unread count.
         */
        
        print("ConversationsViewModel - events - onMessageRead")
        
    }
    
    func onParentMessageUpdate(message: BaseMessage) {
        
        print("ConversationsViewModel - events - onParentMessageUpdate")
    }
    
    func onLiveReaction(reaction: TransientMessage) {
        
        print("ConversationsViewModel - events - onLiveReaction")
    }
    
    func onMessageError(error: CometChatException) {
        
        print("ConversationsViewModel - events - onMessageError")
    }
    
    func onVoiceCall(user: User) {
        
        print("ConversationsViewModel - events - onVoiceCall - User")
    }
    
    func onVoiceCall(group: Group) {
        
        print("ConversationsViewModel - events - onVoiceCall - Group")
    }
    
    func onVideoCall(user: User) {
        
        print("ConversationsViewModel - events - onVideoCall - User")
    }
    
    func onVideoCall(group: Group) {
     
        print("ConversationsViewModel - events - onVideoCall - Group")
    }
    
    func onViewInformation(user: User) {
        
        print("ConversationsViewModel - events - onViewInformation - User")
    }
    
    func onViewInformation(group: Group) {
        
        print("ConversationsViewModel - events - onViewInformation - Group")
    }
    
    func onError(message: BaseMessage?, error: CometChatException) {
        
        print("ConversationsViewModel - events - onError")
    }
    
    func onMessageReact(message: BaseMessage, reaction: CometChatMessageReaction) {
        
        print("ConversationsViewModel - events - onMessageReact")
    }
    
}

extension ConversationsViewModel : CometChatMessageDelegate {
    
    public func onTextMessageReceived(textMessage: TextMessage) {
        /// this is for sound.
        newMessageReceived?(textMessage)
        update(lastMessage: textMessage)
        print("ConversationsViewModel - sdk - onTextMessageReceived")
    }
    
    public func onMediaMessageReceived(mediaMessage: MediaMessage) {
        newMessageReceived?(mediaMessage)
        update(lastMessage: mediaMessage)
        print("ConversationsViewModel - sdk - onMediaMessageReceived")
    }
    
    public func onCustomMessageReceived(customMessage: CustomMessage) {
        newMessageReceived?(customMessage)
        update(lastMessage: customMessage)
        print("ConversationsViewModel - sdk - onCustomMessageReceived")
    }
    
    public func onTypingStarted(_ typingDetails: TypingIndicator) {
        print("onTypingStarted")
        if let row = getConversationRow(with: typingDetails) {
            updateTypingIndicator?(row,typingDetails , true)
        }
        print("ConversationsViewModel - sdk - onTypingStarted")
    }
    
    public func onTypingEnded(_ typingDetails: TypingIndicator) {
        if let row = getConversationRow(with: typingDetails) {
            updateTypingIndicator?(row, typingDetails, false)
        }
        print("onTypingEnded")
        print("ConversationsViewModel - sdk - onTypingEnded")
    }
    
    func onMessageDeleted(message: BaseMessage) {
        update(lastMessage: message)
        print("ConversationsViewModel - sdk - onMessageDeleted")
    }
}
