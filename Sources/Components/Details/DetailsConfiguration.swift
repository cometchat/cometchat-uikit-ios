//
//  Details2Configuration.swift
//  
//
//  Created by Abdullah Ansari on 01/02/23.
//

import Foundation
import UIKit
import CometChatSDK

public class DetailsConfiguration  {
    
    var showCloseButton: Bool?
    var closeButtonIcon: UIImage?
    var menus: [UIBarButtonItem]?
    var hideProfile: Bool?
    var subtitleView: ((_ user: User?, _ group: Group?) -> UIView)?
    var customProfileView : UIView?
    var data: ((_ user: User?, _ group: Group?) -> [CometChatDetailsTemplate])?
    var disableUsersPresence: Bool?
    var protectedGroupIcon: UIImage?
    var privateGroupIcon: UIImage?
    var detailsStyle: DetailsStyle?
    var listItemStyle: ListItemStyle?
    var statusIndicatorStyle: StatusIndicatorStyle?
    var avatarStyle: AvatarStyle?
    var onError: ((_ error: CometChatException) -> Void)?
    var onBack: (() -> Void)?
    
    var groupMembersConfiguration: GroupMembersConfiguration?
    var addMembersConfiguration: AddMembersConfiguration?
    var bannedMembersConfiguration: BannedMembersConfiguration?
    var transferOwnershipConfiguration: TransferOwnershipConfiguration?
    
    public init() {} 
    
    @discardableResult
    public func show(closeButton: Bool) -> Self {
        self.showCloseButton = closeButton
        return self
    }
    
    @discardableResult
    public func set(closeButtonIcon: UIImage) -> Self {
        self.closeButtonIcon = closeButtonIcon
        return self
    }
    
    @discardableResult
    public func hide(profile: Bool) -> Self {
        self.hideProfile = profile
        return self
    }
    
    @discardableResult
    public func setSubtitleView(subtitleView: @escaping ((_ user: User?, _ group: Group?) -> UIView)) -> Self {
        self.subtitleView = subtitleView
        return self
    }
    
    @discardableResult
    public func set(customProfileView: UIView) -> Self {
        self.customProfileView = customProfileView
        return self
    }
    
    @discardableResult
    public func set(menus: [UIBarButtonItem]) -> Self {
        self.menus = menus
        return self
    }
    
    @discardableResult
    public func setData(data: @escaping ((_ user: User?, _ group: Group?) -> [CometChatDetailsTemplate])) -> Self {
        self.data = data
        return self
    }
    
    @discardableResult
    public func disable(usersPresence: Bool) -> Self {
        self.disableUsersPresence = usersPresence
        return self
    }
    
    @discardableResult
    public func set(protectedGroupIcon: UIImage) -> Self {
        self.protectedGroupIcon = protectedGroupIcon
        return self
    }
    
    @discardableResult
    public func set(privateGroupIcon: UIImage) -> Self {
        self.privateGroupIcon = privateGroupIcon
        return self
    }
    
    
    @discardableResult
    public func set(detailsStyle: DetailsStyle) -> Self {
        self.detailsStyle = detailsStyle
        return self
    }

    @discardableResult
    public func set(listItemStyle: ListItemStyle) -> Self {
        self.listItemStyle = listItemStyle
        return self
    }
    
    @discardableResult
    public func set(statusIndicatorStyle: StatusIndicatorStyle) -> Self {
        self.statusIndicatorStyle = statusIndicatorStyle
        return self
    }

    @discardableResult
    public func set(avatarStyle: AvatarStyle) -> Self {
        self.avatarStyle = avatarStyle
        return self
    }

    @discardableResult
    public func setOnError(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
    @discardableResult
    public func setOnBack(onBack: @escaping (() -> Void)) -> Self {
        self.onBack = onBack
        return self
    }
    
    @discardableResult
    public func set(groupMembersConfiguration: GroupMembersConfiguration) -> Self {
        self.groupMembersConfiguration = groupMembersConfiguration
        return self
    }
    
    @discardableResult
    public func set(bannedMembersConfiguration: BannedMembersConfiguration) -> Self {
        self.bannedMembersConfiguration = bannedMembersConfiguration
        return self
    }
    
    @discardableResult
    public func set(addMembersConfiguration: AddMembersConfiguration) -> Self {
        self.addMembersConfiguration = addMembersConfiguration
        return self
    }

    @discardableResult
    public func set(transferOwnershipConfiguration: TransferOwnershipConfiguration) -> Self {
        self.transferOwnershipConfiguration = transferOwnershipConfiguration
        return self
    }

}
