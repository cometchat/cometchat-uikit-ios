//
//  SearchUtils.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 07/08/25.
//

import Foundation
import UIKit
import CometChatSDK

public class SearchUtils {
    
    public init() {}
    
    public func configureTailView(
        conversation: Conversation,
        badgeStyle: BadgeStyle,
        dateStyle: DateStyle,
        datePattern: String?,
        dateTimeFormatter: CometChatDateTimeFormatter
    ) -> UIView {
        let tailView = UIView().withoutAutoresizingMaskConstraints()
        
        let dateLabel = CometChatDate().withoutAutoresizingMaskConstraints()
        dateLabel.textAlignment = .right
        dateLabel.dateTimeFormatter = dateTimeFormatter
        if let datePattern = datePattern, !datePattern.isEmpty {
            dateLabel.text = datePattern
        } else {
            dateLabel.set(pattern: .dayDate)
            dateLabel.set(timestamp: Int(conversation.updatedAt))
        }
        dateLabel.style = dateStyle
        tailView.addSubview(dateLabel)
        
        let badgeCount = CometChatBadge().withoutAutoresizingMaskConstraints()
        badgeCount.set(count: conversation.unreadMessageCount)
        badgeCount.style = badgeStyle
        badgeCount.clipsToBounds = true
        tailView.addSubview(badgeCount)
        
        badgeCount.pin(anchors: [.trailing, .bottom], to: tailView)
        badgeCount.topAnchor.pin(equalTo: dateLabel.bottomAnchor, constant: CometChatSpacing.Spacing.s2).isActive = true
        dateLabel.pin(anchors: [.top, .trailing, .leading], to: tailView)
        
        return tailView
    }

    public func configureMessageTailView(
        message: BaseMessage,
        badgeStyle: BadgeStyle,
        dateStyle: DateStyle,
        datePattern: String?,
        dateTimeFormatter: CometChatDateTimeFormatter
    ) -> UIView {
        let tailView = UIView().withoutAutoresizingMaskConstraints()
        
        let dateLabel = CometChatDate().withoutAutoresizingMaskConstraints()
        dateLabel.textAlignment = .right
        dateLabel.dateTimeFormatter = dateTimeFormatter
        if let datePattern = datePattern, !datePattern.isEmpty {
            dateLabel.text = datePattern
        } else {
            dateLabel.set(pattern: .dayDate)
            dateLabel.set(timestamp: Int(message.sentAt))
        }
        dateLabel.style = dateStyle
        tailView.addSubview(dateLabel)
        dateLabel.pin(anchors: [.top, .trailing, .leading], to: tailView)
        
        return tailView
    }
    
    static public func configureSubtitleView(
        conversation: Conversation,
        isTypingEnabled: Bool,
        receiptStyle: ReceiptStyle,
        disableReceipt: Bool,
        textFormatter: [CometChatTextFormatter],
        typingIndicator: TypingIndicator? = nil,
        typingIndicatorStyle: TypingIndicatorStyle,
        searchStyle: SearchStyle
    ) -> UIView {
                
        let subTitleView = UIStackView()
        subTitleView.alignment = .leading
        subTitleView.distribution = .fillProportionally
        subTitleView.axis = .vertical
        subTitleView.spacing = 1
        
        let typing = UILabel().withoutAutoresizingMaskConstraints()
        typing.font = typingIndicatorStyle.textFont
        typing.textColor = typingIndicatorStyle.textColor
        if conversation.lastMessage?.receiverType == .user {
            typing.text = ConversationConstants.typingText
        } else {
            typing.text = (typingIndicator?.sender?.name ?? "") + " " + ConversationConstants.isTyping
        }
        typing.heightAnchor.constraint(equalToConstant: searchStyle.listItemSubTitleFont.lineHeight).isActive = true
                
        let lastStackView = UIStackView()
        lastStackView.alignment = .center
        lastStackView.distribution = .fill
        lastStackView.axis = .horizontal
        lastStackView.spacing = CometChatSpacing.Spacing.s1
        
        let reciept = CometChatReceipt()
        reciept.style = receiptStyle
        
        let lastMessage = UILabel().withoutAutoresizingMaskConstraints()
        lastMessage.font = searchStyle.listItemSubTitleFont
        lastMessage.textColor = searchStyle.listItemSubTitleTextColor
        lastMessage.numberOfLines = 1
        
        let subTitleImage = UIImageView().withoutAutoresizingMaskConstraints()
        subTitleImage.heightAnchor.constraint(equalToConstant: 16).isActive = true
        subTitleImage.widthAnchor.constraint(equalToConstant: 16).isActive = true
        subTitleImage.tintColor = CometChatTheme.iconColorSecondary
        
        if let lastMessage = conversation.lastMessage, lastMessage.deletedAt == 0 {
            reciept.disable(receipt: disableReceipt)
            reciept.set(receipt: MessageReceiptUtils.get(receiptStatus: lastMessage))
            reciept.style = receiptStyle
        }
        
        let additionalConfiguration = AdditionalConfiguration()
        additionalConfiguration.searchStyle = searchStyle
        additionalConfiguration.textFormatter = textFormatter
        
        // Get the formatted attributed string from getLastConversationMessage
        let formattedContent = ChatConfigurator.getDataSource()
            .getLastConversationMessage(conversation: conversation, additionalConfiguration: additionalConfiguration)
            ?? NSAttributedString(string: "")

        if let keyword = CometChatSearch.sharedSearchKeyword, !keyword.isEmpty {
            // Apply search highlighting to the formatted content
            let mutableContent = NSMutableAttributedString(attributedString: formattedContent)
            applySearchHighlight(
                to: mutableContent,
                keyword: keyword,
                normalFont: searchStyle.listItemSubTitleFont,
                highlightFont: UIFont.boldSystemFont(ofSize: searchStyle.listItemSubTitleFont.pointSize)
            )
            lastMessage.attributedText = mutableContent
        } else {
            lastMessage.attributedText = formattedContent
        }
        
        if let lastMessage = conversation.lastMessage, lastMessage.parentMessageId != 0 {
            subTitleImage.image = UIImage(
                named: "messages-thread",
                in: CometChatUIKit.bundle,
                compatibleWith: nil
            )?.withRenderingMode(
                .alwaysTemplate
            )
            subTitleImage.tintColor = searchStyle.messageTypeImageTint
            lastStackView.addArrangedSubview(subTitleImage)
        } else {
            if !disableReceipt {
                if LoggedInUserInformation.isLoggedInUser(uid: conversation.lastMessage?.sender?.uid) &&
                    conversation.lastMessage?.messageCategory != .action
                {
                    lastStackView.addArrangedSubview(reciept)
                }
            }
        }
        
        lastStackView.addArrangedSubview(lastMessage)
        
        if isTypingEnabled {
            subTitleView.addArrangedSubview(typing)
        } else {
            subTitleView.addArrangedSubview(lastStackView)
        }
        
        return subTitleView
    }
    
    static func configureMessageSubtitleView(
        message: BaseMessage,
        searchStyle: SearchStyle,
        textFormatter: [CometChatTextFormatter]?,
        searchKeyword: String
    ) -> UIView {

        let label = UILabel()
        label.font = searchStyle.listItemSubTitleFont
        label.textColor = searchStyle.listItemSubTitleTextColor
        label.numberOfLines = 1
        
        // Extract text content: TextMessage text, or CardMessage text/fallback
        let rawContent: String
        if let textMsg = message as? TextMessage {
            rawContent = textMsg.text
        } else if message.messageCategory == .card, let cardMsg = message as? CometChatSDK.CardMessage {
            rawContent = cardMsg.getText() ?? cardMsg.getFallbackText() ?? "CARD_MESSAGE".localize()
        } else {
            rawContent = ""
        }
        let font = searchStyle.listItemSubTitleFont
        let color = searchStyle.listItemSubTitleTextColor
        
        // Parse markdown with formatting (no newlines around code blocks for single-line display)
        var parsedContent = RichTextFormatterManager.shared.parseMarkdown(
            rawContent,
            baseFont: font,
            baseColor: color,
            addNewlinesAroundCodeBlocks: false
        )
        
        // Flatten to single line: replace newlines with spaces
        let mutableParsed = NSMutableAttributedString(attributedString: parsedContent)
        let fullRange = NSRange(location: 0, length: mutableParsed.length)
        mutableParsed.mutableString.replaceOccurrences(of: "\n", with: " ", options: [], range: fullRange)
        
        let isGroupMessage = message.receiverType == .group

        // Sender name (only for group)
        let senderName: String? = {
            guard isGroupMessage else { return nil }
            return message.sender?.name
        }()

        let attributedText = NSMutableAttributedString()

        if let senderName {
            let senderAttributes: [NSAttributedString.Key: Any] = [
                .font: searchStyle.listItemSubTitleFont,
                .foregroundColor: searchStyle.listItemSubTitleTextColor
            ]
            attributedText.append(
                NSAttributedString(string: "\(senderName): ", attributes: senderAttributes)
            )
        }

        // Apply text formatters (like mentions) on top of the parsed markdown
        if let formatters = textFormatter,
           !formatters.isEmpty,
           let textMessage = message as? TextMessage {

            // Create a copy with original text for mention processing
            // We use the original textMessage.text because it contains the mention tags <@uid:...>
            let formattedMessage = TextMessage(
                receiverUid: textMessage.receiverUid,
                text: textMessage.text,
                receiverType: textMessage.receiverType
            )
            formattedMessage.sender = textMessage.sender
            formattedMessage.senderUid = textMessage.senderUid
            formattedMessage.mentionedUsers = textMessage.mentionedUsers
            formattedMessage.mentionedMe = textMessage.mentionedMe

            // Process mentions - this will convert <@uid:...> to @username with proper styling
            let mentionProcessed = MessageUtils.processTextFormatter(
                message: formattedMessage,
                textFormatter: formatters,
                formattingType: .MESSAGE_BUBBLE
            )

            // Now parse the mention-processed text for markdown formatting
            let mentionProcessedText = mentionProcessed.string
            let finalParsed = RichTextFormatterManager.shared.parseMarkdown(
                mentionProcessedText,
                baseFont: font,
                baseColor: color,
                addNewlinesAroundCodeBlocks: false
            )
            
            // Flatten to single line
            let finalMutable = NSMutableAttributedString(attributedString: finalParsed)
            let finalRange = NSRange(location: 0, length: finalMutable.length)
            finalMutable.mutableString.replaceOccurrences(of: "\n", with: " ", options: [], range: finalRange)

            // Apply mention styling from the processed text
            mentionProcessed.enumerateAttributes(in: NSRange(location: 0, length: mentionProcessed.length), options: []) { attrs, range, _ in
                if attrs[.link] != nil || (attrs[.foregroundColor] as? UIColor) == CometChatTheme.primaryColor {
                    if range.location + range.length <= finalMutable.length {
                        for (key, value) in attrs {
                            finalMutable.addAttribute(key, value: value, range: range)
                        }
                    }
                }
            }
            
            attributedText.append(finalMutable)

        } else {
            attributedText.append(mutableParsed)
        }

        if !searchKeyword.isEmpty {
            applySearchHighlight(
                to: attributedText,
                keyword: searchKeyword,
                normalFont: searchStyle.listItemSubTitleFont,
                highlightFont: UIFont.boldSystemFont(
                    ofSize: searchStyle.listItemSubTitleFont.pointSize
                )
            )
        }

        label.attributedText = attributedText
        return label
    }

    static func applySearchHighlight(
        to attributedText: NSMutableAttributedString,
        keyword: String,
        normalFont: UIFont,
        highlightFont: UIFont
    ) {
        let text = attributedText.string.lowercased()
        let search = keyword.lowercased()

        var searchRange = NSRange(location: 0, length: attributedText.length)

        while let range = text.range(of: search, options: [], range: Range(searchRange, in: text)) {
            let nsRange = NSRange(range, in: text)

            // IMPORTANT: Preserve ALL existing attributes, only change the font
            attributedText.enumerateAttributes(in: nsRange, options: []) { attrs, _, _ in
                var newAttrs = attrs
                newAttrs[.font] = highlightFont
                newAttrs[.foregroundColor] = CometChatTheme.primaryColor
                newAttrs[.backgroundColor] = UIColor.clear
                attributedText.setAttributes(newAttrs, range: nsRange)
            }

            let nextLocation = nsRange.location + nsRange.length
            searchRange = NSRange(location: nextLocation, length: attributedText.length - nextLocation)
        }
    }

    
    static func highlightKeyword(
        in text: String,
        keyword: String,
        font: UIFont,
        highlightFont: UIFont,
        highlightColor: UIColor? = CometChatTheme.primaryColor
    ) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: CometChatTheme.textColorPrimary
        ])
        
        let lowerText = text.lowercased()
        let lowerKeyword = keyword.lowercased()
        
        var searchRange = lowerText.startIndex..<lowerText.endIndex
        
        while let range = lowerText.range(of: lowerKeyword, options: [], range: searchRange) {
            let nsRange = NSRange(range, in: text)
            attributed.addAttributes([
                .font: highlightFont,
                .foregroundColor: highlightColor ?? CometChatTheme.primaryColor
            ], range: nsRange)
            searchRange = range.upperBound..<lowerText.endIndex
        }
        
        return attributed
    }
    
    static func filterItem(for filter: SearchFilter) -> FilterItem {
        switch filter {
        case .conversations:
            return FilterItem(iconName: "bubble.left.and.bubble.right", title: "Conversations")
        case .messages:
            return FilterItem(iconName: "text.bubble", title: "Messages")
        case .unread:
            return FilterItem(iconName: "envelope.badge", title: "Unread")
        case .groups:
            return FilterItem(iconName: "person.3", title: "Groups")
        case .photos:
            return FilterItem(iconName: "photo", title: "Photos")
        case .videos:
            return FilterItem(iconName: "video", title: "Videos")
        case .links:
            return FilterItem(iconName: "link", title: "Links")
        case .documents:
            return FilterItem(iconName: "doc.text", title: "Documents")
        case .audio:
            return FilterItem(iconName: "waveform", title: "Audio")
        }
    }
}
