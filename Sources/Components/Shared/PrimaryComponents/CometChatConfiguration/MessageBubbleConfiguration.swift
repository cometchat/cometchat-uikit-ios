//
//  MessageBubbleConfiguration.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 15/02/22.
//

import Foundation


public class  MessageBubbleConfiguration : CometChatConfiguration {
    
    var dateConfiguration: DateConfiguration?
    var messageReceiptConfiguration: MessageReceiptConfiguration?
    var avatarConfiguration: AvatarConfiguration?
    var timeAlignment: UIKitConstants.MessageBubbleTimeAlignmentConstants = .bottom
    var sentMessageInputData: SentMessageInputData?
    var receivedMessageInputData: ReceivedMessageInputData?
    
    public func set(dateConfiguration: DateConfiguration) -> Self {
        self.dateConfiguration = dateConfiguration
        return self
    }
    
    public func set(messageReceiptConfiguration: MessageReceiptConfiguration) -> Self {
        self.messageReceiptConfiguration = messageReceiptConfiguration
        return self
    }
    
    public func set(avatarConfiguration: AvatarConfiguration) -> Self {
        self.avatarConfiguration = avatarConfiguration
        return self
    }
    
    public func set(timeAlignment: UIKitConstants.MessageBubbleTimeAlignmentConstants) -> Self {
        self.timeAlignment = timeAlignment
        return self
    }
    
    public func set(sentMessageInputData: SentMessageInputData) -> Self {
        self.sentMessageInputData = sentMessageInputData
        return self
    }
    
    public func set(receivedMessageInputData: ReceivedMessageInputData) -> Self {
        self.receivedMessageInputData = receivedMessageInputData
        return self
    }
    
}
