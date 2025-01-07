//
//  CardBubbleStyle.swift
//  
//
//  Created by Abhishek Saralaya on 25/10/23.
//

import Foundation
import UIKit

public final class CardBubbleStyle: BaseStyle {
    private var textColor: UIColor = CometChatTheme_v4.palatte.accent900
    
    private var textFont: UIFont = CometChatTheme_v4.typography.text1
    
    private var progressBarTintColor: UIColor = CometChatTheme_v4.palatte.accent900
    private var buttonDisableTextColor: UIColor = CometChatTheme_v4.palatte.accent500
    private var imageBubbleStyle: ImageBubbleStyle = ImageBubbleStyle()
    private var contentBackgroundColor: UIColor = CometChatTheme_v4.palatte.accent
    private var buttonSeparatorColor: UIColor = CometChatTheme_v4.palatte.accent900
    
    private var contentRadius: CGFloat = 0
    
    private var buttonBackgroundColor: UIColor = CometChatTheme_v4.palatte.primary
    private var buttonTextColor: UIColor = CometChatTheme_v4.palatte.secondary
    private var buttonTextFont: UIFont = CometChatTheme_v4.typography.text1
    
    public override init() {
        super.init()
        let cornerstyle = CometChatCornerStyle(cornerRadius: 10)
        set(cornerRadius: cornerstyle)
    }
    
    public override func set(background: UIColor) -> Self {
        super.set(background: background)
        return self
    }
    
    public override func set(borderWidth: CGFloat) -> Self {
        super.set(borderWidth: borderWidth)
        return self
    }
    
    public override func set(cornerRadius: CometChatCornerStyle) -> Self {
        super.set(cornerRadius: cornerRadius)
        return self
    }
    
    public override func set(borderColor: UIColor) -> Self {
        super.set(borderColor: borderColor)
        return self
    }
    
    public func set(textColor: UIColor) -> Self {
        self.textColor = textColor
        return self
    }
    
    public func set(textFont: UIFont) -> Self {
        self.textFont = textFont
        return self
    }
    
    public func set(progressBarTintColor: UIColor) -> Self {
        self.progressBarTintColor = progressBarTintColor
        return self
    }
    
    public func set(buttonDisableTextColor: UIColor) -> Self {
        self.buttonDisableTextColor = buttonDisableTextColor
        return self
    }
    
    public func set(contentBackgroundColor: UIColor) -> Self {
        self.contentBackgroundColor = contentBackgroundColor
        return self
    }
    
    public func set(buttonSeparatorColor: UIColor) -> Self {
        self.buttonSeparatorColor = buttonSeparatorColor
        return self
    }
    
    public func set(contentRadius: CGFloat) -> Self {
        self.contentRadius = contentRadius
        return self
    }
    
    public func set(buttonBackgroundColor: UIColor) -> Self {
        self.buttonBackgroundColor = buttonBackgroundColor
        return self
    }
    
    public func set(buttonTextColor: UIColor) -> Self {
        self.buttonTextColor = buttonTextColor
        return self
    }
    
    public func set(buttonTextFont: UIFont) -> Self {
        self.buttonTextFont = buttonTextFont
        return self
    }
    
    public func set(imageBubbleStyle: ImageBubbleStyle) -> Self {
        self.imageBubbleStyle = imageBubbleStyle
        return self
    }
    
    public func getTextColor() -> UIColor {
        return textColor;
    }
    
    public func getTextFont() -> UIFont {
        return textFont;
    }
    
    public func getProgressBarTintColor() -> UIColor {
        return progressBarTintColor;
    }
    
    public func getButtonBackgroundColor() -> UIColor {
        return buttonBackgroundColor;
    }
    
    public func getButtonTextColor() -> UIColor {
        return buttonTextColor;
    }
    
    public func getButtonTextFont() -> UIFont {
        return buttonTextFont;
    }
    
    public func getContentBackgroundColor() -> UIColor {
        return contentBackgroundColor;
    }
    
    public func getImageBubbleStyle() -> ImageBubbleStyle {
        return imageBubbleStyle
    }
    
    public func getButtonDisableTextColor() -> UIColor {
        return buttonDisableTextColor
    }
    
    public func getButtonSeparatorColor() -> UIColor {
        return buttonSeparatorColor
    }
    
    public func getContentRadius() -> CGFloat {
        return contentRadius
    }
}
