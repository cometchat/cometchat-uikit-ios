//
//  CometChatSettings.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 28/12/21.
//

import Foundation
import UIKit
import CometChatPro

public enum UserDisplayMode {
   case friends
   case all
   case none
}


public class UserListConfiguration: CometChatConfiguration {

    var hideSectionHeader: Bool = false
    var isFriendOnly: Bool = false
    var hideBlockedUsers: Bool = false
    var hideError: Bool = false
    var searchKeyword: String = ""
    var status: CometChat.UserStatus = .offline
    var limit: Int = 30
    var tags: [String] = [String]()
    var roles: [String] = [String]()
    var uids: [String] = [String]()
    var emptyView: UIView?
    var background: [CGColor]?

    var userListItemConfiguration : UserListItemConfiguration?
    
    public func set(background: [CGColor]) -> UserListConfiguration {
        self.background = background
        return self
    }
    
    public func hide(sectionHeader: Bool) -> UserListConfiguration {
        self.hideSectionHeader = sectionHeader
        return self
    }
    
    public func set(friendsOnly: Bool) -> UserListConfiguration {
        self.isFriendOnly = friendsOnly
        return self
    }
    
    public func hide(blockedUsers: Bool) -> UserListConfiguration {
        self.hideBlockedUsers = blockedUsers
        return self
    }
    
    public func hide(error: Bool) -> UserListConfiguration {
        self.hideError = error
        return self
    }
    
    public func set(searchKeyword: String) -> UserListConfiguration {
        self.searchKeyword = searchKeyword
        return self
    }
    
    public func set(status: CometChat.UserStatus) -> UserListConfiguration {
        self.status = status
        return self
    }
    
    public func set(limit: Int) -> UserListConfiguration {
        self.limit = limit
        return self
    }
    
    public func set(tags: [String]) -> UserListConfiguration {
        self.tags = tags
        return self
    }
    
    public func set(roles: [String]) -> UserListConfiguration {
        self.roles = roles
        return self
    }
    
    public func set(uids: [String]) -> UserListConfiguration {
        self.uids = uids
        return self
    }

}

