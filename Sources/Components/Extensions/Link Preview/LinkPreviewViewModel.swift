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
    
    public override func getTextMessageContentView(message: TextMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?) -> UIView? {
        if getMessageLinks(message: message) != nil {
            return CometChatLinkPreviewBubble(frame: CGRect(x: 0, y: 0, width: 228, height: 300), message: message)
        } else {
            return super.getTextMessageContentView(message: message, controller: controller, alignment: alignment, style: style)
        }
    }
    
    
    private func getMessageLinks(message: TextMessage) -> [Any]? {
        if let map = ExtensionModerator.extensionCheck(baseMessage: message), !map.isEmpty && map.containsKey(ExtensionConstants.smartReply),
           let linkPreview = map[ExtensionConstants.linkPreview], let links = linkPreview["links"] as? [Any], !links.isEmpty {
            return links
        } else {
            return nil
        }
    }

}
