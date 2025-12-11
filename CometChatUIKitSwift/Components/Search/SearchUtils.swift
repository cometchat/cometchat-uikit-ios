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
        let content = ChatConfigurator.getDataSource()
            .getLastConversationMessage(conversation: conversation, additionalConfiguration: additionalConfiguration)?
            .string ?? ""

        if let keyword = CometChatSearch.sharedSearchKeyword, !keyword.isEmpty {
            let highlighted = highlightKeyword(
                in: content,
                keyword: keyword,
                font: searchStyle.listItemSubTitleFont,
                highlightFont: UIFont.boldSystemFont(ofSize: searchStyle.listItemSubTitleFont.pointSize)
            )
            lastMessage.attributedText = highlighted
        } else {
            lastMessage.attributedText = NSAttributedString(string: content)
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
        searchKeyword: String
    ) -> UIView {
        let label = UILabel()
        label.font = searchStyle.listItemSubTitleFont
        label.textColor = searchStyle.listItemSubTitleTextColor
        label.numberOfLines = 1

        let content = (message as? TextMessage)?.text ?? ""
        
        if searchKeyword.isEmpty {
            label.text = content
        } else {
            let highlighted = highlightKeyword(
                in: content,
                keyword: searchKeyword,
                font: searchStyle.listItemSubTitleFont,
                highlightFont: UIFont.boldSystemFont(ofSize: searchStyle.listItemSubTitleFont.pointSize)
            )
            label.attributedText = highlighted
        }

        return label
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
