//
//  UsersWithMessagesStyle.swift
//  
//
//  Created by Abdullah Ansari on 23/09/22.
//

import UIKit

public final class UsersWithMessagesStyle: BaseStyle {

    private(set) var messageTextFont = CometChatTheme.typography.largeHeading
    private(set) var messageTextColor = CometChatTheme.palatte.accent600
    
    public override init() {}
    
    @discardableResult
    public func set(messageTextFont: UIFont) -> Self {
        self.messageTextFont = messageTextFont
        return self
    }
    
    @discardableResult
    public func set(messageTextColor: UIColor) -> Self {
        self.messageTextColor = messageTextColor
        return self
    }
}
