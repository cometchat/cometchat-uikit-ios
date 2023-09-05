//
//  MessageComposerConfiguration.swift
 
//
//  Created by Pushpsen Airekar on 07/02/22.
//

import Foundation
import UIKit
import CometChatSDK

public class MessageComposerConfiguration {
    
    private(set) var placeholderText: String?
    private(set) var headerView: UIView?
    private(set) var footerView: UIView?
    private(set) var onChange: (() -> Void)?
    private(set) var maxLine: Int?
    private(set) var attachmentIcon: UIImage?
    private(set) var attachmentOptions: ((_ user: User?, _ group: Group?, _ controller: UIViewController?) -> [CometChatMessageComposerAction])?
    private(set) var secondaryButtonView: ((_ user: User?, _ group: Group?) -> UIView)?
    private(set) var auxilaryButtonView: ((_ user: User?, _ group: Group?) -> UIView)?
    private(set) var auxiliaryButtonsAlignment: AuxilaryButtonAlignment?
    private(set) var sendButtonView: ((_ user: User?, _ group: Group?) -> UIView)?
    private(set) var hideLiveReaction: Bool?
    private(set) var liveReactionIcon: UIImage?
    private(set) var mediaRecordIcon: UIImage?
    private(set) var messageComposerStyle: MessageComposerStyle?
    private(set) var onSendButtonClick: ((BaseMessage) -> Void)?
    private(set) var hideFooterView: Bool?
    private(set) var hideHeaderView: Bool?
    private(set) var pauseIconTint: UIColor?
    private(set) var playIconTint: UIColor?
    private(set) var deleteIconTint: UIColor?
    private(set) var timerTextFont: UIFont?
    private(set) var timerTextColor: UIColor?
    private(set) var startIconTint: UIColor?
    private(set) var stopIconTint: UIColor?
    private(set) var submitIconTint: UIColor?
    var background: UIColor?
    
    public init() {}
    
    public func set(background: UIColor) -> Self {
        self.background = background
        return self
    }
    
    @discardableResult
    public func set(pauseIconTint: UIColor) -> Self {
        self.pauseIconTint = pauseIconTint
        return self
    }
    
    @discardableResult
    public func set(playIconTint: UIColor) -> Self {
        self.playIconTint = playIconTint
        return self
    }
    
    @discardableResult
    public func set(deleteIconTint: UIColor) -> Self {
        self.deleteIconTint = deleteIconTint
        return self
    }
    
    @discardableResult
    public func set(timerTextFont: UIFont) -> Self {
        self.timerTextFont = timerTextFont
        return self
    }
    
    @discardableResult
    public func set(timerTextColor: UIColor) -> Self {
        self.timerTextColor = timerTextColor
        return self
    }
    
    @discardableResult
    public func set(submitIconTint: UIColor) -> Self {
        self.submitIconTint = submitIconTint
        return self
    }
    
    @discardableResult
    public func set(startIconTint: UIColor) -> Self {
        self.startIconTint = startIconTint
        return self
    }
    
    @discardableResult
    public func set(stopIconTint: UIColor) -> Self {
        self.stopIconTint = stopIconTint
        return self
    }
    
    @discardableResult
    public func set(placeholderText: String) -> Self {
        self.placeholderText = placeholderText
        return self
    }
    
    @discardableResult
    public func set(headerView: UIView) ->  Self {
        self.headerView = headerView
        return self
    }
    
    @discardableResult
    public func set(footerView: UIView) ->  Self {
        self.footerView = footerView
        return self
    }
    
    @discardableResult
    public func setOnChange(onChange: @escaping (() -> Void)) -> Self {
        self.onChange = onChange
        return self
    }
    
    @discardableResult
    public func set(maxLine: Int) ->  Self {
        self.maxLine = maxLine
        return self
    }
    
    @discardableResult
    public func set(attachmentIcon: UIImage) ->  Self {
        self.attachmentIcon = attachmentIcon
        return self
    }
    
    @discardableResult
    public func setAttachmentOptions(attachmentOptions:  @escaping ((_ user: User?, _ group: Group?, _ controller: UIViewController?) -> [CometChatMessageComposerAction])) -> Self {
        self.attachmentOptions = attachmentOptions
        return self
    }
    
    @discardableResult
    public func setSecondaryButtonView(secondaryButtonView: @escaping ((_ user: User?, _ group: Group?) -> UIView)) -> Self {
        self.secondaryButtonView = secondaryButtonView
        return self
    }
    
    @discardableResult
    public func setAuxilaryButtonView(auxilaryButtonView: @escaping ((_ user: User?, _ group: Group?) -> UIView)) -> Self {
        self.auxilaryButtonView = auxilaryButtonView
        return self
    }
    
    @discardableResult
    public func set(auxilaryButtonAignment: AuxilaryButtonAlignment) -> Self {
        self.auxiliaryButtonsAlignment = auxilaryButtonAignment
        return self
    }
    
    @discardableResult
    public func setSendButtonView(sendButtonView: @escaping ((_ user: User?, _ group: Group?) -> UIView)) -> Self {
        self.sendButtonView = sendButtonView
        return self
    }
    
    @discardableResult
    public func hide(liveReaction: Bool) ->  Self {
        self.hideLiveReaction = liveReaction
        return self
    }
    
    @discardableResult
    public func set(liveReactionIcon: UIImage) -> Self {
        self.liveReactionIcon = liveReactionIcon
        return self
    }
    
    @discardableResult
    public func set(messageComposerStyle: MessageComposerStyle?) -> Self {
        self.messageComposerStyle = messageComposerStyle
        return self
    }
    
    @discardableResult
    public func setOnSendButtonClick(onSendButtonClick: @escaping ((BaseMessage) -> Void)) -> Self {
        self.onSendButtonClick = onSendButtonClick
        return self
    }
    
    @discardableResult
    public func hide(footerView: Bool) ->  Self {
        self.hideFooterView = footerView
        return self
    }
    
    @discardableResult
    public func hide(headerView: Bool) ->  Self {
        self.hideHeaderView = headerView
        return self
    }

}
