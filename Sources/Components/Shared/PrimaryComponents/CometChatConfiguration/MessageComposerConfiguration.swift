//
//  MessageComposerConfiguration.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 07/02/22.
//

import Foundation
import UIKit


public class MessageComposerConfiguration: CometChatConfiguration {

    private var maxLines: Int = 5
    private var placeholderText: String = "TYPE_A_MESSAGE".localize()
    private var hideAttachment = false
    private var hideMicrophone = true
    private var hideLiveReaction = false
    private var hideSticker = false
    private var hideEmoji = false
    private var hideSendButton = false
    private var enableTypingIndicator = true
    private var enableSoundForMessages = true
    var hideMessageComposer: Bool = false
    var messageTypes: [CometChatMessageTemplate]?
    var excludeMessageTypes: [CometChatMessageTemplate]?
    
    
    @discardableResult
    public func set(messageTypes: [CometChatMessageTemplate]) -> Self {
        self.messageTypes = messageTypes
        return self
    }
    @discardableResult
    public func set(excludeMessageTypes: [CometChatMessageTemplate]) -> Self {
       print("MessageComposerConfiguration excludeMessageTypes: \(excludeMessageTypes)")
        self.excludeMessageTypes = excludeMessageTypes
        return self
    }
    
    @discardableResult
    public func set(maxLines: Int) -> Self {
        self.maxLines = maxLines
        return self
    }
    @discardableResult
    public func getMaxLines() -> Int {
        return maxLines
    }
    @discardableResult
    public func set(placeholderText: String) -> Self {
        self.placeholderText = placeholderText
        return self
    }
    @discardableResult
    public func getPlaceholderText() -> String {
        return placeholderText
    }
    
    @discardableResult
    public func hide(attachment: Bool) -> Self {
        self.hideAttachment = attachment
        return self
    }
    @discardableResult
    public func isAttachmentHidden() -> Bool {
        return hideAttachment
    }
    
    @discardableResult
    public func hide(sticker: Bool) -> Self {
        self.hideSticker = sticker
        return self
    }
    @discardableResult
    public func isStickerHidden() -> Bool {
        return hideSticker
    }
    @discardableResult
    public func isTypingIndicatorEnabled() -> Bool {
        return enableTypingIndicator
    }
    
    @discardableResult
    public func isEmojiHidden() -> Bool {
        return hideEmoji
    }
    
    @discardableResult
    public func hide(microphone: Bool) -> Self {
        self.hideMicrophone = microphone
        return self
    }

    @discardableResult
    public func hide(liveReaction: Bool) -> Self {
        self.hideLiveReaction = liveReaction
        return self
    }
    @discardableResult
    public func isLiveReactionHidden() -> Bool {
        return hideLiveReaction
    }
    @discardableResult
    public func hide(sendButton: Bool) -> Self {
        self.hideSendButton = sendButton
        return self
    }
    @discardableResult
    public func isSendButtonHidden() -> Bool {
        return hideSendButton
    }
    @discardableResult
    public func hide(emoji: Bool) -> Self {
        self.hideEmoji = hideEmoji
        return self
    }
    @discardableResult
    public func enable(typingIndicator: Bool) -> Self {
        self.enableTypingIndicator = typingIndicator
        return self
    }
    
    @discardableResult
    public func enable(soundForMessages: Bool) -> Self {
        self.enableSoundForMessages = soundForMessages
        return self
    }
    
    @discardableResult
    public func isSoundEnabled() -> Bool {
        return enableSoundForMessages
    }
    
    @discardableResult
    @objc public func hide(messageComposer: Bool) -> Self {
        self.hideMessageComposer = messageComposer
        return self
    }

}
