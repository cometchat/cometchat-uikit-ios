//
//  ImageBubbleStyle.swift
//
//
//  Created by Abdullah Ansari on 31/08/22.
//

import UIKit

public final class ImageBubbleStyle: BaseStyle {
    
    var activityIndicatorTint: UIColor = CometChatTheme.palatte.primary
    var captionTextColor = CometChatTheme.palatte.accent900
    var captionTextFont = CometChatTheme.typography.text1
    override var background: UIColor {
        get {
            return .clear
        }
        
        set {
            super.background = newValue
        }
    }
    
    override var borderWidth: CGFloat {
        get {
            return 1.0
        }
        
        set {
            super.borderWidth = newValue
        }
    }
    
    @discardableResult
    public func set(activityIndicatorTint: UIColor) -> Self {
        self.activityIndicatorTint = activityIndicatorTint
        return self
    }
    
    @discardableResult
    public func set(captionTextColor: UIColor) -> Self {
        self.captionTextColor = captionTextColor
        return self
    }
    
    @discardableResult
    public func set(captionTextFont: UIFont) -> Self {
        self.captionTextFont = captionTextFont
        return self
    }
}
