//
//  File.swift
//  
//
//  Created by SuryanshBisen on 31/10/23.
//

import Foundation
import UIKit
import CometChatSDK

public class AIAssistBotConfiguration {
    private(set) var title: String?
    private(set) var subtitle: String?
    private(set) var closeIcon: UIImage?
    private(set) var sendIcon: UIImage?
    private(set) var botFirstMessageText: ((_ bot: User) -> String)?
    private(set) var apiConfiguration: ((_ bot: User, _ user: User?, _ group: Group?, _ configuration: ((_ configuration: [String: Any]) -> ())) -> Void)?
    private(set) var style: AIAssistBotStyle?
    private(set) var botMessageBubbleStyle: TextBubbleStyle?
    private(set) var senderMessageBubbleStyle: TextBubbleStyle?
    private(set) var messageInputStyle: MessageInputStyle?
    private(set) var avatarStyle: AvatarStyle?
    
    public init() { }
    
    @discardableResult
    public func set(title: String) -> Self {
        self.title = title
        return self
    }
    
    @discardableResult
    public func set(closeIcon: UIImage) -> Self {
        self.closeIcon = closeIcon
        return self
    }
    
    @discardableResult
    public func set(sendIcon: UIImage) -> Self {
        self.sendIcon = sendIcon
        return self
    }
    
    @discardableResult
    public func set(botFirstMessageText: ((_ bot: User) -> String)?) -> Self {
        self.botFirstMessageText = botFirstMessageText
        return self
    }
    
    @discardableResult
    public func set(apiConfiguration: ((_ bot: User, _ user: User?, _ group: Group?, _ configuration: ((_ configuration: [String: Any]) -> ())) -> Void)?) -> Self {
        self.apiConfiguration = apiConfiguration
        return self
    }
    
    @discardableResult
    public func set(style: AIAssistBotStyle) -> Self {
        self.style = style
        return self
    }
    
    @discardableResult
    public func set(botMessageBubbleStyle: TextBubbleStyle) -> Self {
        self.botMessageBubbleStyle = botMessageBubbleStyle
        return self
    }
    
    @discardableResult
    public func set(senderMessageBubbleStyle: TextBubbleStyle) -> Self {
        self.senderMessageBubbleStyle = senderMessageBubbleStyle
        return self
    }
    
    @discardableResult
    public func set(messageInputStyle: MessageInputStyle) -> Self {
        self.messageInputStyle = messageInputStyle
        return self
    }
    
    @discardableResult
    public func set(avatarStyle: AvatarStyle) -> Self {
        self.avatarStyle = avatarStyle
        return self
    }
    
    @discardableResult
    public func set(subtitle: String?) -> Self {
        self.subtitle = subtitle
        return self
    }

}
