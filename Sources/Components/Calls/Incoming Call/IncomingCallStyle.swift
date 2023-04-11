//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 08/03/23.
//

import UIKit

public final class IncomingCallStyle: BaseStyle  {

    private(set) var titleColor = CometChatTheme.palatte.accent
    private(set) var titleFont = CometChatTheme.typography.largeHeading2
    private(set) var subtitleColor = CometChatTheme.palatte.accent600
    private(set) var subtitleFont = CometChatTheme.typography.subtitle1
    
    public override init() {}
    
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
    public func set(subtitleColor: UIColor) -> Self {
        self.subtitleColor = subtitleColor
        return self
    }
    
    @discardableResult
    public func set(subtitleFont: UIFont) -> Self {
        self.subtitleFont = subtitleFont
        return self
    }
    
}
