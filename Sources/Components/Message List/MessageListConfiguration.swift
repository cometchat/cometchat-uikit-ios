//
//  CometChatSettings.swift
 
//
//  Created by Pushpsen Airekar on 28/12/21.
//

import Foundation
import UIKit
import CometChatSDK

public class  MessageListConfiguration {
    
    private (set) var emptyStateView: UIView?
    private (set) var errorStateView: UIView?
    private (set) var disableReceipt: Bool = false
    private (set) var readIcon: UIImage?
    private (set) var deliveredIcon: UIImage?
    private (set) var sentIcon: UIImage?
    private (set) var waitIcon: UIImage?
    private (set) var alignment: MessageListAlignment = .standard
    private (set) var timeAlignment: MessageBubbleTimeAlignment = .bottom
    private (set) var showAvatar: Bool = true
    private (set) var headerView: UIView?
    private (set) var footerView: UIView?
    private (set) var datePattern: ((_ timestamp: Int?) -> String)?
    private (set) var dateSeparatorPattern: ((_ timestamp: Int?) -> String)?
    private (set) var scrollToBottomOnNewMessages: Bool = true
    private (set) var onThreadRepliesClick: ((_ message: BaseMessage?, _ messageBubbleView: UIView?) -> ())?
    private (set) var messageListStyle: MessageListStyle?
    private (set) var templates: [CometChatMessageTemplate]?
    private (set) var messageInformationConfiguration: MessageInformationConfiguration?
    private (set) var messagesRequestBuilder: MessagesRequest.MessageRequestBuilder?
   
    //TODO:- Needs to be asked weather it will a part or not.
    //    private (set) var messageBubbleStyle: MessageBubbleStyle?
    //    private (set) var avatarStyle: AvatarStyle?
    //    private (set) var dateSeperatorStyle: DateStyle?
    //    private (set) var newMessageIndicatorStyle: NewMessageIndicatorStyle()
    
    public init() {}
    
    @discardableResult
    public func set(emptyStateView: UIView) -> Self {
        self.emptyStateView = emptyStateView
        return self
    }
    
    @discardableResult
    public func set(errorStateView: UIView) -> Self {
        self.errorStateView = errorStateView
        return self
    }
    
    @discardableResult
    public func disable(receipt: Bool) -> Self {
        self.disableReceipt = receipt
        return self
    }
    
    @discardableResult
    public func set(readIcon: UIImage) -> Self {
        self.readIcon = readIcon
        return self
    }
    
    @discardableResult
    public func set(deliveredIcon: UIImage) -> Self {
        self.deliveredIcon = deliveredIcon
        return self
    }
    
    @discardableResult
    public func set(sentIcon: UIImage) -> Self {
        self.sentIcon = sentIcon
        return self
    }
    
    @discardableResult
    public func set(waitIcon: UIImage) -> Self {
        self.waitIcon = waitIcon
        return self
    }
    
    @discardableResult
    public func set(alignment: MessageListAlignment) -> Self {
        self.alignment = alignment
        return self
    }
    
    
    @discardableResult
    public func set(timeAlignment: MessageBubbleTimeAlignment) -> Self {
        self.timeAlignment = timeAlignment
        return self
    }
    
    @discardableResult
    public func set(messageInformationConfiguration: MessageInformationConfiguration) -> Self {
        self.messageInformationConfiguration = messageInformationConfiguration
        return self
    }
    
    @discardableResult
    public func show(avatar: Bool) -> Self {
        self.showAvatar = avatar
        return self
    }
    
    @discardableResult
    public func setDatePattern(datePattern: ((_ timestamp: Int?) -> String)?) -> Self {
        self.datePattern = datePattern
        return self
    }
    
    @discardableResult
    public func setDateSeparatorPattern(dateSeparatorPattern: ((_ timestamp: Int?) -> String)?) -> Self {
        self.dateSeparatorPattern = dateSeparatorPattern
        return self
    }
        
    @discardableResult
    public func set(templates: [CometChatMessageTemplate]) -> Self {
        self.templates = templates
        return self
    }
    
    @discardableResult
    public func scrollToBottomOnNewMessages(_ bool: Bool) -> Self {
        self.scrollToBottomOnNewMessages = scrollToBottomOnNewMessages
        return self
    }
    
    public func setOnThreadRepliesClick(onThreadRepliesClick: ((_ message: BaseMessage?, _ messageBubbleView: UIView?) -> ())?) -> Self {
        self.onThreadRepliesClick = onThreadRepliesClick
        return self
    }
    
    @discardableResult
    public func set(messageListStyle: MessageListStyle) -> Self {
        self.messageListStyle = messageListStyle
        return self
    }
    
    @discardableResult
    public func set(headerView: UIView) -> Self {
        self.headerView = headerView
        return self
    }
    
    @discardableResult
    public func set(footerView: UIView) -> Self {
        self.footerView = footerView
        return self
    }
    
    @discardableResult
    public func set(messagesRequestBuilder: MessagesRequest.MessageRequestBuilder) -> Self {
        self.messagesRequestBuilder = messagesRequestBuilder
        return self
    }
    
}
