//
//  ConversationsUtils.swift
//
//
//  Created by Pushpsen Airekar on 20/12/22.
//

import Foundation
import UIKit
import CometChatSDK

public class ConversationsUtils {
    
    public init() {}
    
    public func configureTailView(
        conversation: Conversation,
        badgeStyle: BadgeStyle,
        dateStyle: DateStyle,
        datePattern: String?
    ) -> UIView {
        let tailView = UIView().withoutAutoresizingMaskConstraints()
        
        let dateLabel = CometChatDate().withoutAutoresizingMaskConstraints()
        dateLabel.textAlignment = .right
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

    
    static public func configureSubtitleView(
        conversation: Conversation,
        isTypingEnabled: Bool,
        isHideDeletedMessages: Bool,
        receiptStyle: ReceiptStyle,
        disableReceipt: Bool,
        textFormatter: [CometChatTextFormatter],
        typingIndicator: TypingIndicator? = nil,
        typingIndicatorStyle: TypingIndicatorStyle,
        conversationStyle: ConversationsStyle
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
        typing.heightAnchor.constraint(equalToConstant: conversationStyle.listItemSubTitleFont.lineHeight).isActive = true
                
        let lastStackView = UIStackView()
        lastStackView.alignment = .center
        lastStackView.distribution = .fill
        lastStackView.axis = .horizontal
        lastStackView.spacing = CometChatSpacing.Spacing.s1
        
        let reciept = CometChatReceipt()
        reciept.style = receiptStyle
        
        let lastMessage = UILabel().withoutAutoresizingMaskConstraints()
        lastMessage.font = conversationStyle.listItemSubTitleFont
        lastMessage.textColor = conversationStyle.listItemSubTitleTextColor
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
        additionalConfiguration.conversationsStyle = conversationStyle
        additionalConfiguration.textFormatter = textFormatter
        lastMessage.attributedText = ChatConfigurator.getDataSource().getLastConversationMessage(conversation: conversation, isDeletedMessagesHidden: isHideDeletedMessages, additionalConfiguration: additionalConfiguration)
        
        if let lastMessage = conversation.lastMessage, lastMessage.parentMessageId != 0 {
            subTitleImage.image = UIImage(
                named: "messages-thread",
                in: CometChatUIKit.bundle,
                compatibleWith: nil
            )?.withRenderingMode(
                .alwaysTemplate
            )
            subTitleImage.tintColor = conversationStyle.messageTypeImageTint
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
    
}
