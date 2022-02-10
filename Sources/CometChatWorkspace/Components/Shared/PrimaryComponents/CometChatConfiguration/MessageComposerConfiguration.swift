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
    
    public func setCornerRadius(cornerRadius: Int) -> MessageComposerConfiguration {
        self.cornerRadius = cornerRadius
        return self
    }
    
    public func getCornerRadius() -> Int? {
        return cornerRadius
    }
    
    public func setBorderWidth(borderWidth: CGFloat) -> MessageComposerConfiguration {
        self.borderWidth = borderWidth
        return self
    }
    
    public func getBorderWidth() -> CGFloat? {
        return borderWidth
    }
    
    public func setWidth(width: CGFloat) -> MessageComposerConfiguration {
        self.width = width
        return self
    }
    
    public func getWidth() -> CGFloat? {
        return width
    }
    
    public func setHeight(height: CGFloat) -> MessageComposerConfiguration {
        self.height = height
        return self
    }
    
    public func getHeight() -> CGFloat? {
        return height
    }
    
    public func setTextSize(size: CGFloat) -> MessageComposerConfiguration {
        self.textSize = size
        return self
    }
    
    public func getTextSize() -> CGFloat? {
        return textSize
    }
    
    public func setMaxLines(numberOfLines: Int) -> MessageComposerConfiguration {
        self.maxLines = numberOfLines
        return self
    }
    
    public func getMaxLines() -> Int? {
        return maxLines
    }
    
    public func hideAttachment(bool: Bool) -> MessageComposerConfiguration {
        self.isAttachmentVisible = bool
        return self
    }
    
    public func isAttachmentHidden() -> Bool? {
        return isAttachmentVisible
    }
    
    public func hideMicrophone(bool: Bool) -> MessageComposerConfiguration {
        self.isMicrophoneVisible = bool
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
