//
//  SavedMessagesUtils.swift
//  CometChatUIKitSwift
//

import Foundation
import UIKit
import CometChatSDK

public class SavedMessagesUtils {

    public init() {}

    /// A one-line preview of the saved message: `[type icon] Sender: text`.
    ///
    /// The preview is built by the shared datasource rather than re-derived here, so a saved
    /// row reads exactly like the same message in the conversation list — every category
    /// (text, media, poll, sticker, card, deleted) stays in one place.
    ///
    /// The datasource keys off `Conversation`, so the saved message is wrapped in one. It
    /// prefixes the sender for group messages, keyed off the *message's* `receiverType` —
    /// the wrapper's type is never read — which is the whole of the prefixing the design
    /// asks for: group rows read `Name: text`, 1:1 rows carry no prefix.
    static func configureSubtitleView(
        message: BaseMessage,
        style: SavedMessagesStyle,
        textFormatter: [CometChatTextFormatter]?
    ) -> UIView {

        let previewLabel = UILabel().withoutAutoresizingMaskConstraints()
        previewLabel.font = style.listItemSubTitleFont
        previewLabel.textColor = style.listItemSubTitleTextColor
        previewLabel.numberOfLines = 1

        let additionalConfiguration = AdditionalConfiguration()
        additionalConfiguration.conversationsStyle = conversationsStyle(from: style)
        additionalConfiguration.textFormatter = textFormatter ?? []

        let preview = ChatConfigurator.getDataSource().getLastConversationMessage(
            conversation: wrap(message: message),
            additionalConfiguration: additionalConfiguration
        ) ?? NSAttributedString(string: "")

        let line = NSMutableAttributedString(attributedString: preview)

        // Flatten to a single line for the row.
        line.mutableString.replaceOccurrences(
            of: "\n",
            with: " ",
            options: [],
            range: NSRange(location: 0, length: line.length)
        )

        previewLabel.attributedText = line
        return previewLabel
    }

    /// The shared preview and tail builders read only these fields off the conversation.
    ///
    /// `conversationType` is never read by `getLastConversationMessage` — it branches on the
    /// message's own `receiverType` — so the value here is immaterial.
    ///
    /// `updatedAt` carries `savedAt` because the tail builder dates the row off it, and this
    /// list is ordered by when things were saved. `unreadMessageCount` stays 0 so the badge
    /// hides.
    private static func wrap(message: BaseMessage) -> Conversation {
        let conversation = Conversation()
        conversation.lastMessage = message
        conversation.conversationType = .user
        conversation.updatedAt = message.savedAt
        conversation.unreadMessageCount = 0
        return conversation
    }

    /// Carries the saved list's fonts and colours into the shared preview builder, which
    /// styles against `ConversationsStyle`.
    private static func conversationsStyle(from style: SavedMessagesStyle) -> ConversationsStyle {
        var conversationsStyle = ConversationsStyle()
        conversationsStyle.listItemSubTitleFont = style.listItemSubTitleFont
        conversationsStyle.listItemSubTitleTextColor = style.listItemSubTitleTextColor
        conversationsStyle.messageTypeImageTint = style.messageTypeImageTint
        return conversationsStyle
    }

    /// The save time, not the send time — this list is ordered by when things were saved.
    ///
    /// Built by the conversation list's own tail builder so a saved row's timestamp matches
    /// the Chats row exactly — same `dayDate` wording, same right alignment, same position on
    /// the title line. The wrapper carries `savedAt` in `updatedAt`, which is the only field
    /// the builder reads for the date.
    ///
    /// The badge and pin indicator it can also draw both no-op here: the wrapper's unread
    /// count is 0, which hides the badge, and `pinnedAt` stays at its 0 sentinel.
    static func configureTailView(
        message: BaseMessage,
        dateStyle: DateStyle,
        dateTimeFormatter: CometChatDateTimeFormatter
    ) -> UIView {
        return ConversationsUtils().configureTailView(
            conversation: wrap(message: message),
            badgeStyle: BadgeStyle(),
            dateStyle: dateStyle,
            datePattern: nil,
            dateTimeFormatter: dateTimeFormatter
        )
    }
}
