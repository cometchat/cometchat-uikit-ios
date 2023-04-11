//
//  ConversationsWithMessagesStyle.swift
//  
//
//  Created by Abdullah Ansari on 31/08/22.
//

import UIKit

public final class ConversationsWithMessagesStyle: BaseStyle {

    private(set) var messageTextColor = CometChatTheme.palatte.accent600
    private(set) var messageTextFont = CometChatTheme.typography.largeHeading
    
    @discardableResult
    public func set(messageTextColor: UIColor) -> Self {
        self.messageTextColor = messageTextColor
        return self
    }
    
    @discardableResult
    public func set(messageTextFont: UIFont) -> Self {
        self.messageTextFont = messageTextFont
        return self
    }
    
}
