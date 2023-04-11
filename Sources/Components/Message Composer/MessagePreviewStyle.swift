//
//  MessagePreviewStyle.swift
//  
//
//  Created by Abdullah Ansari on 26/09/22.
//

import UIKit

public final class MessagePreviewStyle: BaseStyle {

    private(set) var messagePreviewTitleColor = CometChatTheme.palatte.accent600
    private(set) var messagePreviewTitleFont = CometChatTheme.typography.text3
    private(set) var messagePreviewSubtitleColor = CometChatTheme.palatte.accent600
    private(set) var messagePreviewSubtitleFont = CometChatTheme.typography.subtitle2
    private(set) var closeButtonTint = CometChatTheme.palatte.accent500
    
    @discardableResult
    public func set(messagePreviewTitleColor: UIColor) -> Self {
        self.messagePreviewTitleColor = messagePreviewTitleColor
        return self
    }
    
    @discardableResult
    public func set(messagePreviewTitleFont: UIFont) -> Self {
        self.messagePreviewTitleFont = messagePreviewTitleFont
        return self
    }
    
    @discardableResult
    public func set(messagePreviewSubtitleColor: UIColor) -> Self {
        self.messagePreviewSubtitleColor = messagePreviewSubtitleColor
        return self
    }
    
    @discardableResult
    public func set(messagePreviewSubtitleFont: UIFont) -> Self {
        self.messagePreviewSubtitleFont = messagePreviewSubtitleFont
        return self
    }

    @discardableResult
    public func set(closeButtonTint: UIColor) -> Self {
        self.closeButtonTint = closeButtonTint
        return self
    }
    
}
