//
//  CustomConfiguration.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 12/03/24.
//

import Foundation

public class AdditionalConfiguration {
    public var textFormatter: [CometChatTextFormatter] = [CometChatMentionsFormatter()]
    public var messageBubbleStyle: (incoming: MessageBubbleStyle, outgoing: MessageBubbleStyle) = CometChatMessageBubble.style
    
    public var actionBubbleStyle: GroupActionBubbleStyle = CometChatMessageBubble.actionBubbleStyle
    public var conversationsStyle: ConversationsStyle = CometChatConversations.style
    public var callActionBubbleStyle: CallActionBubbleStyle = CometChatMessageBubble.callActionBubbleStyle
    
    public init(){
        
    }
}

extension AdditionalConfiguration {
    @discardableResult
    public func set(textFormatter: [CometChatTextFormatter]) -> Self {
        self.textFormatter = textFormatter
        return self
    }
}
