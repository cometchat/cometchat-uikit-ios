//
//  CometChatMessageConfiguration.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 07/02/22.
//

import Foundation
import UIKit


public enum BubbleType {
    
    case standard
    case leftAligned
    
}

public class CometChatMessagesConfiguration:  CometChatConfiguration {
    
    private static var cometChatMessageTemplates: [CometChatMessageTemplate]?
    private var isDeleteMessageHidden,isUserChatEnabled,isGroupChatEnabled: Bool?
    private var isLiveReactionEnabled,isAttachmentVisible,isMicrophoneVisible: Bool?
    
    private var messageAlignment: BubbleType = .leftAligned
    private var avatarConfiguration: AvatarConfiguration?
    private var liveReactionIcon: UIImage?
    private var attachmentIcon: UIImage?
    private var microphoneIcon: UIImage?
    private var sendIcon: UIImage?
    private var placeholderStr: String? = ""
    public static func setMessageFilter(listOfMessageTemplate: [CometChatMessageTemplate] ) {
        self.cometChatMessageTemplates = listOfMessageTemplate
    }
    
    
    public static func getMessageFilterList() -> [CometChatMessageTemplate]? {
        return cometChatMessageTemplates
    }
    
    public func getTemplateById(id: String) -> [CometChatMessageTemplate]? {
        return CometChatMessagesConfiguration.cometChatMessageTemplates?.filter({$0.id == id})
    }
    
    public func hideDeletedMessage(bool: Bool) -> CometChatMessagesConfiguration {
        self.isDeleteMessageHidden = bool
        return self
    }
    
    public func isDeletedMessagesHidden() -> Bool {
        return isDeleteMessageHidden ?? false
    }
    
    public func setUserChatEnabled(bool: Bool) -> CometChatMessagesConfiguration {
        self.isUserChatEnabled  = bool
        return self
    }
    
    public func isUserChatsEnabled() -> Bool {
        return isUserChatEnabled ?? true
    }
    
    
    public func setGroupChatEnabled(bool: Bool) -> CometChatMessagesConfiguration {
        self.isGroupChatEnabled = bool
        return self
    }
    
    public func isGroupChatsEnabled() -> Bool {
        return isGroupChatEnabled ?? true
    }
    
    
    public func setLiveReactionEnabled(bool: Bool) -> CometChatMessagesConfiguration {
        self.isLiveReactionEnabled = bool
        return self
    }
    
    public func isLiveReactionsEnabled() -> Bool {
        return isLiveReactionEnabled ?? true
    }
    
    public func setMessageListAlignment(alignment: BubbleType) -> CometChatMessagesConfiguration {
        self.messageAlignment = alignment
        return self
    }
    
    public func getMessageListAlignment() -> BubbleType {
        return messageAlignment
    }
    
    public func setLiveReactionIcon(icon: UIImage) -> CometChatMessagesConfiguration {
        self.liveReactionIcon = icon
        return self
    }
    
    public func getLiveReactionIcon() -> UIImage? {
        return liveReactionIcon
    }
    
    public func  setAttachmentIcon(icon: UIImage) -> CometChatMessagesConfiguration {
        self.liveReactionIcon = icon
        return self
    }
    
    public func getAttachmentIcon() -> UIImage? {
        return attachmentIcon
    }
    
    public func  setMicrophone(icon: UIImage) -> CometChatMessagesConfiguration {
        self.microphoneIcon = icon
        return self
    }
    
    public func getMicrophoneIcon() -> UIImage? {
        return microphoneIcon
    }
    
    public func setPlaceholder(string: String) -> CometChatMessagesConfiguration {
        self.placeholderStr = string
        return self
    }
    
    public func getPlaceholder() -> String {
        return placeholderStr ?? ""
    }
    
    
    public func setAvatarConfiguration(avatarConfiguration: AvatarConfiguration) -> CometChatMessagesConfiguration {
        self.avatarConfiguration = avatarConfiguration
        return self
    }
    
    public func getAvatarConfiguration() -> AvatarConfiguration? {
        return avatarConfiguration
    }
    
    
}
