//
//  CustomConfiguration.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 12/03/24.
//

import Foundation

public class AdditionalConfiguration {
    public var textFormatter: [CometChatTextFormatter] = [CometChatMentionsFormatter()]
    public var messageBubbleStyle: (incoming: MessageBubbleStyle, outgoing: MessageBubbleStyle) = CometChatMessageBubble.style
    
    public var actionBubbleStyle: GroupActionBubbleStyle = CometChatMessageBubble.actionBubbleStyle
    public var conversationsStyle: ConversationsStyle = CometChatConversations.style
    public var callActionBubbleStyle: CallActionBubbleStyle = CometChatMessageBubble.callActionBubbleStyle
    public var searchStyle: SearchStyle = CometChatSearch.style
    
    
    public var hideImageAttachmentOption: Bool = false
    public var hideVideoAttachmentOption: Bool = false
    public var hideAudioAttachmentOption: Bool = false
    public var hideFileAttachmentOption: Bool = false
    public var hidePollsOption: Bool = false
    public var hideCollaborativeDocumentOption: Bool = false
    public var hideCollaborativeWhiteboardOption: Bool = false
    public var hideAttachmentButton: Bool = false
    public var hideVoiceRecordingButton: Bool = false
    public var hideStickersButton: Bool = false
    
    public var hideFlagMessageOption: Bool = false
    public var hideReplyInThreadOption: Bool = false
    public var hideTranslateMessageOption: Bool = false
    public var hideEditMessageOption: Bool = false
    public var hideDeleteMessageOption: Bool = false
    public var hideReactionOption: Bool = false
    public var hideMessagePrivatelyOption: Bool = false
    public var hideCopyMessageOption: Bool = false
    public var hideMessageInfoOption: Bool = false
    public var hideShareMessageOption: Bool = false
    public var hideReplyMessageOption: Bool = false
    public var showMarkAsUnreadOption: Bool = false
    public var hideVideoCallButton: Bool = false
    public var hideVoiceCallButton: Bool = false

    /// When true (default), messages that carry attachments render with the new
    /// per-type batch bubbles (Images/Video/Audios/Files). When false, they fall back
    /// to the deprecated single-attachment bubbles. Mirrors the message list's
    /// `enableMultipleAttachments` flag.
    public var enableMultipleAttachments: Bool = true

    public init(){
        
    }
}

extension AdditionalConfiguration {
    @discardableResult
    public func set(textFormatter: [CometChatTextFormatter]) -> Self {
        self.textFormatter = textFormatter
        return self
    }
}
