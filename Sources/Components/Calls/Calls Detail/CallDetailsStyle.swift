//
//  File.swift
//  
//
//  Created by Ajay Verma on 09/03/23.
//

import Foundation
import UIKit

public final class CallDetailsStyle: BaseStyle {
    private(set) var titleColor = CometChatTheme.palatte.accent
    private(set) var titleFont = CometChatTheme.typography.largeHeading
    private(set) var listItemTitleColor = CometChatTheme.palatte.accent
    private(set) var listItemTitleFont = CometChatTheme.typography.largeHeading2
    private(set) var listItemsubTitleColor = CometChatTheme.palatte.accent700
    private(set) var listItemsubTitleFont = CometChatTheme.typography.text2
    private(set) var backIconTint = CometChatTheme.palatte.primary
    private(set) var privateGroupIconBackgroundColor = #colorLiteral(red: 0, green: 0.7843137255, blue: 0.4352941176, alpha: 1)
    private(set) var protectedGroupIconBackgroundColor = #colorLiteral(red: 0.968627451, green: 0.6470588235, blue: 0, alpha: 1)
    private(set) var onlineStatusColor: UIColor = CometChatTheme.palatte.success
    
    override public var background: UIColor {
        get {
            return CometChatTheme.palatte.secondary
        }
        set {}
    }
    
    @discardableResult
    public func set(titleColor: UIColor) -> Self {
        self.titleColor = titleColor
        return self
    }
    
    @discardableResult
    public func set(titleFont: UIFont) -> Self {
        self.titleFont = titleFont
        return self
    }
    
    @discardableResult
    public func set(backIconTint: UIColor) -> Self {
        self.backIconTint = backIconTint
        return self
    }
    
    @discardableResult
    public func set(privateGroupIconBackgroundColor: UIColor) -> Self {
        self.privateGroupIconBackgroundColor = privateGroupIconBackgroundColor
        return self
    }
    
    @discardableResult
    public func set(protectedGroupIconBackgroundColor: UIColor) -> Self {
        self.protectedGroupIconBackgroundColor = protectedGroupIconBackgroundColor
        return self
    }
    
    @discardableResult
    public func set(onlineStatusColor: UIColor) -> Self {
        self.onlineStatusColor = onlineStatusColor
        return self
    }
}

