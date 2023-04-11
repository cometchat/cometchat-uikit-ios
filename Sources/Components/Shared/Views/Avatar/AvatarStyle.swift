//
//  AvatarStyle.swift
//  
//
//  Created by Abdullah Ansari on 27/09/22.
//

import UIKit

public final class AvatarStyle: BaseStyle {

    private(set) var textFont = CometChatTheme.typography.name
    private(set) var textColor: UIColor = .white.withAlphaComponent(0.9)
    private(set) var outerViewWidth:CGFloat = 20.0
    private(set) var outerViewSpacing: CGFloat = 20.0
    //override
    override public var background: UIColor {
        get {
            return CometChatTheme.palatte.accent400
        }
        set {}
    }
    
    override var cornerRadius: CometChatCornerStyle {
        get {
            return CometChatCornerStyle(cornerRadius: 20.0)
        }
        set {}
    }
    
    @discardableResult
    public func set(textFont: UIFont) -> Self {
        self.textFont = textFont
        return self
    }
    
    @discardableResult
    public func set(textColor: UIColor) -> Self {
        self.textColor = textColor
        return self
    }
    
    @discardableResult
    public func set(outerViewWidth: CGFloat) -> Self {
        self.outerViewWidth = outerViewWidth
        return self
    }
    
    @discardableResult
    public func set(outerViewSpacing: CGFloat) -> Self {
        self.outerViewSpacing = outerViewSpacing
        return self
    }
    
    
}
