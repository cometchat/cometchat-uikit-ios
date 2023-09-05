//
//  CometChatSettings.swift
 
//
//  Created by Pushpsen Airekar on 28/12/21.
//

import Foundation
import UIKit
import CometChatSDK

public final class MessageHeaderConfiguration {

    private(set) var subtitleView: ((_ user: User?, _ group: Group?) -> UIView)?
    private(set) var disableUsersPresence: Bool = false
    private(set) var disableTyping: Bool = false
    private(set) var privateGroupIcon: UIImage?
    private(set) var protectedGroupIcon: UIImage?
    private(set) var menus: ((_ user: User?, _ group: Group?) -> UIView)?
    private(set) var messageHeaderStyle: MessageHeaderStyle?
    private(set) var backButtonIcon: UIImage?
    private(set) var hideBackIcon: Bool = false

    public init() {}
    
    @discardableResult
    public func set(subtitle: ((_ user: User?, _ group: Group?) -> UIView)?) -> Self {
        self.subtitleView = subtitle
        return self
    }
    
    @discardableResult
    public func setMenus(menus: ((_ user: User?, _ group: Group?) -> UIView)?) -> Self {
        self.menus = menus
        return self
    }
    
    @discardableResult
    public func set(privateGroupIcon: UIImage) -> Self {
        self.privateGroupIcon = privateGroupIcon
        return self
    }
    
    @discardableResult
    public func set(protectedGroupIcon: UIImage) -> Self {
        self.protectedGroupIcon = protectedGroupIcon
        return self
    }
    
    @discardableResult
    public func disable(userPresence: Bool) -> Self {
        self.disableUsersPresence = userPresence
        return self
    }
    
    @discardableResult
    public func disable(typing: Bool) -> Self {
        self.disableTyping = typing
        return self
    }
    
    @discardableResult
    public func set(backIcon: UIImage) -> Self {
        self.backButtonIcon = backIcon.withRenderingMode(.alwaysTemplate)
        return self
    }
    
    @discardableResult
    @objc public func hide(backButton: Bool) -> Self {
        self.hideBackIcon = backButton
        return self
    }
    
    @discardableResult
    public func set(messageHeaderStyle: MessageHeaderStyle) -> Self {
        self.messageHeaderStyle = messageHeaderStyle
        return self
    }
    
}
