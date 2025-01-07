//
//  CollaborativeDocumentViewModel.swift
//
//
//  Created by Pushpsen Airekar on 18/02/23.
//

import Foundation
import CometChatSDK

public class LinkPreviewViewModel : DataSourceDecorator {
    
    var messageTypeConstant = ExtensionConstants.linkPreview
    var loggedInUser = CometChat.getLoggedInUser()
    
    public override init(dataSource: DataSource) {
        super.init(dataSource: dataSource)
    }
    
    public override func getId() -> String {
        return "link-preview"
    }
    
    public override func getTextMessageContentView(message: TextMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        
        if getMessageLinks(message: message) != nil {
            
            let linkPreviewBubble = CometChatLinkPreviewBubble(
                frame: .null,
                message: message
            ).set(controller: controller)
            linkPreviewBubble.withoutAutoresizingMaskConstraints()
            
            let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message.senderUid)
            let messageBubbleStyle = isLoggedInUser ? additionalConfiguration?.messageBubbleStyle.outgoing : additionalConfiguration?.messageBubbleStyle.incoming
            if let style = messageBubbleStyle?.linkPreviewBubbleStyle { linkPreviewBubble.style = style }
            
            if let textFormatter = additionalConfiguration?.textFormatter, !textFormatter.isEmpty {
                if let attributedText = MessageUtils.processTextFormatter(for: message, in: linkPreviewBubble.messageLabel, textFormatter: textFormatter, controller: controller, alignment: alignment) {
                    linkPreviewBubble.set(attributedText: attributedText)
                }
            }
                        
            return linkPreviewBubble
            
        } else {
            return super.getTextMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
        }
    }
    
    
    private func getMessageLinks(message: TextMessage) -> [Any]? {
        if let map = ExtensionModerator.extensionCheck(baseMessage: message), !map.isEmpty,
           let linkPreview = map[ExtensionConstants.linkPreview], let links = linkPreview["links"] as? [Any], !links.isEmpty {
            return links
        } else {
            return nil
        }
    }

}
