//
//  GroupWithMessageStyle.swift
//  
//
//  Created by Abdullah Ansari on 23/09/22.
//

import UIKit

public final class GroupsWithMessageStyle: BaseStyle {
   
    private(set) var messageTextColor = CometChatTheme.palatte.accent500
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
