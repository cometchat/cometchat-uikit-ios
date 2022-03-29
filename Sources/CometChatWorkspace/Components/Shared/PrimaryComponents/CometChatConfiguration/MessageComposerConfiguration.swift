//
//  MessageComposerConfiguration.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 07/02/22.
//

import Foundation
import UIKit


public class MessageComposerConfiguration: CometChatConfiguration {

    private var cornerRadius: Int?
    private var borderWidth: CGFloat?
    private var width: CGFloat?
    private var height: CGFloat?
    private var textSize: CGFloat?
    private var maxLines: Int?
    private var isAttachmentVisible,isMicrophoneVisible,isLiveReactionVisible,isSendButtonVisible: Bool?
    
    public func set(cornerRadius: Int) -> MessageComposerConfiguration {
        self.cornerRadius = cornerRadius
        return self
    }
    
    public func getCornerRadius() -> Int? {
        return cornerRadius
    }
    
    public func set(borderWidth: CGFloat) -> MessageComposerConfiguration {
        self.borderWidth = borderWidth
        return self
    }
    
    public func getBorderWidth() -> CGFloat? {
        return borderWidth
    }
    
    public func set(width: CGFloat) -> MessageComposerConfiguration {
        self.width = width
        return self
    }
    
    public func getWidth() -> CGFloat? {
        return width
    }
    
    public func set(height: CGFloat) -> MessageComposerConfiguration {
        self.height = height
        return self
    }
    
    public func getHeight() -> CGFloat? {
        return height
    }
    
    public func set(textSize: CGFloat) -> MessageComposerConfiguration {
        self.textSize = textSize
        return self
    }
    
    public func getTextSize() -> CGFloat? {
        return textSize
    }
    
    public func set(maxLines: Int) -> MessageComposerConfiguration {
        self.maxLines = maxLines
        return self
    }
    
    public func getMaxLines() -> Int? {
        return maxLines
    }
    
    public func hide(attachment: Bool) -> MessageComposerConfiguration {
        self.isAttachmentVisible = attachment
        return self
    }
    
    public func isAttachmentHidden() -> Bool? {
        return isAttachmentVisible
    }
    
    public func hide(microphone: Bool) -> MessageComposerConfiguration {
        self.isMicrophoneVisible = microphone
        return self
    }
    
    public func isMicrophoneHidden() -> Bool? {
        return isMicrophoneVisible
    }
    
    public func hideLiveReaction(bool: Bool) -> MessageComposerConfiguration {
        self.isLiveReactionVisible = bool
        return self
    }
    
    public func isLiveReactionHidden() -> Bool? {
        return isLiveReactionVisible
    }
    
    
    public func hideSendButton(bool: Bool) -> MessageComposerConfiguration {
        self.isSendButtonVisible = bool
        return self
    }
    
    public func isSendButtonHidden() -> Bool? {
        return isSendButtonVisible
    }
    
    
}
