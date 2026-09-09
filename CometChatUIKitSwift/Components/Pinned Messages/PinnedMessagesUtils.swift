//
//  PinnedMessagesUtils.swift
//  CometChatUIKitSwift
//

import Foundation
import UIKit
import CometChatSDK

public class PinnedMessagesUtils {

    public init() {}

    /// A one-line preview of the pinned message, used by the banner. The panel itself
    /// renders full message bubbles and does not call this.
    static func configureSubtitleView(
        message: BaseMessage,
        style: PinnedMessagesStyle,
        textFormatter: [CometChatTextFormatter]?
    ) -> UIView {

        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.font = style.previewFont
        label.textColor = style.previewTextColor
        label.numberOfLines = 1

        // Covers every category — text, media, custom and card — in one place.
        let rawContent = MessageUtils.quotedMessageText(for: message)

        let parsed = RichTextFormatterManager.shared.parseMarkdown(
            rawContent,
            baseFont: style.previewFont,
            baseColor: style.previewTextColor,
            addNewlinesAroundCodeBlocks: false
        )

        // Flatten to a single line for the row.
        let flattened = NSMutableAttributedString(attributedString: parsed)
        flattened.mutableString.replaceOccurrences(
            of: "\n",
            with: " ",
            options: [],
            range: NSRange(location: 0, length: flattened.length)
        )

        label.attributedText = flattened
        return label
    }
}
