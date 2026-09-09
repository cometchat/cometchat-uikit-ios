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
    /// Hides the action-sheet option only. Ignored while the thread-subscription feature
    /// gate is off, which already hides both surfaces.
    public var hideThreadSubscriptionOption: Bool = false
    public var hideVideoCallButton: Bool = false
    public var hideVoiceCallButton: Bool = false

    /// Ships dark: the pin/save backend is not deployed yet, so both features stay
    /// off until the integrator opts in.
    public var enablePinMessage: Bool = false
    public var hidePinMessageOption: Bool = false
    public var enableSaveMessage: Bool = false
    public var hideSaveMessageOption: Bool = false

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

// MARK: - Direction-aware bubble sub-style lookup

/// Reads one sub-style without binding the whole `MessageBubbleStyle`, which is
/// large enough that copying it per nested decorator overflowed the stack when a
/// message list was pushed from an already-deep context.
///
/// Deliberately concrete rather than generic over a `KeyPath`: a generic version
/// routes the value through an opaque buffer, reintroducing the copy.
extension AdditionalConfiguration {

    func textBubbleStyle(_ isLoggedInUser: Bool) -> TextBubbleStyle {
        isLoggedInUser ? messageBubbleStyle.outgoing.textBubbleStyle
                       : messageBubbleStyle.incoming.textBubbleStyle
    }

    func deleteBubbleStyle(_ isLoggedInUser: Bool) -> DeleteBubbleStyle {
        isLoggedInUser ? messageBubbleStyle.outgoing.deleteBubbleStyle
                       : messageBubbleStyle.incoming.deleteBubbleStyle
    }

    func imageBubbleStyle(_ isLoggedInUser: Bool) -> ImageBubbleStyle {
        isLoggedInUser ? messageBubbleStyle.outgoing.imageBubbleStyle
                       : messageBubbleStyle.incoming.imageBubbleStyle
    }

    func videoBubbleStyle(_ isLoggedInUser: Bool) -> VideoBubbleStyle {
        isLoggedInUser ? messageBubbleStyle.outgoing.videoBubbleStyle
                       : messageBubbleStyle.incoming.videoBubbleStyle
    }

    func audioBubbleStyle(_ isLoggedInUser: Bool) -> AudioBubbleStyle {
        isLoggedInUser ? messageBubbleStyle.outgoing.audioBubbleStyle
                       : messageBubbleStyle.incoming.audioBubbleStyle
    }

    func fileBubbleStyle(_ isLoggedInUser: Bool) -> FileBubbleStyle {
        isLoggedInUser ? messageBubbleStyle.outgoing.fileBubbleStyle
                       : messageBubbleStyle.incoming.fileBubbleStyle
    }

    func aiAssistantBubbleStyle(_ isLoggedInUser: Bool) -> AIAssistantBubbleStyle {
        isLoggedInUser ? messageBubbleStyle.outgoing.aiAssistantBubbleStyle
                       : messageBubbleStyle.incoming.aiAssistantBubbleStyle
    }

    func linkPreviewBubbleStyle(_ isLoggedInUser: Bool) -> LinkPreviewBubbleStyle {
        isLoggedInUser ? messageBubbleStyle.outgoing.linkPreviewBubbleStyle
                       : messageBubbleStyle.incoming.linkPreviewBubbleStyle
    }

    func messageTranslationBubbleStyle(_ isLoggedInUser: Bool) -> MessageTranslationBubbleStyle {
        isLoggedInUser ? messageBubbleStyle.outgoing.messageTranslationBubbleStyle
                       : messageBubbleStyle.incoming.messageTranslationBubbleStyle
    }

    func pollBubbleStyle(_ isLoggedInUser: Bool) -> PollBubbleStyle {
        isLoggedInUser ? messageBubbleStyle.outgoing.pollBubbleStyle
                       : messageBubbleStyle.incoming.pollBubbleStyle
    }

    func stickersBubbleStyle(_ isLoggedInUser: Bool) -> StickerBubbleStyle {
        isLoggedInUser ? messageBubbleStyle.outgoing.stickersBubbleStyle
                       : messageBubbleStyle.incoming.stickersBubbleStyle
    }

    func collaborativeWhiteboardBubbleStyle(_ isLoggedInUser: Bool) -> CollaborativeBubbleStyle {
        isLoggedInUser ? messageBubbleStyle.outgoing.collaborativeWhiteboardBubbleStyle
                       : messageBubbleStyle.incoming.collaborativeWhiteboardBubbleStyle
    }
}
