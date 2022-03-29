//
//  CometChatSettings.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 28/12/21.
//

import Foundation
import UIKit

public enum GroupDisplayMode {
   case publicGroups
   case passwordProtectedGroups
   case publicAndPasswordProtectedGroups
   case none
}


public class GroupListConfiguration: CometChatConfiguration {

    var background: [CGColor]?
    var showCreateGroup : Bool = true
    var showDeleteGroup : Bool = true
    var showLeaveGroup : Bool = true
    var groupListMode: GroupDisplayMode  = .none
    var groupListItemConfiguration : GroupListItemConfiguration?
    
    public func set(background: [CGColor]) -> GroupListConfiguration {
        self.background = background
        return self
    }
    
    public func set(groupListMode: GroupDisplayMode) -> GroupListConfiguration {
        self.groupListMode = groupListMode
        return self
    }
    
    
    public func show(createGroup: Bool) -> GroupListConfiguration {
        self.showCreateGroup = createGroup
        return self
    }
    
    public func show(deleteGroup: Bool) -> GroupListConfiguration {
        self.showDeleteGroup = deleteGroup
        return self
    }
    
    public func show(leaveGroup: Bool) -> GroupListConfiguration {
        self.showLeaveGroup = leaveGroup
        return self
    }
    
    public func set(groupListItemConfiguration: GroupListItemConfiguration) -> GroupListConfiguration {
        self.groupListItemConfiguration = groupListItemConfiguration
        return self
    }
    
    public func set(configuration: GroupListConfiguration) {
        self.background = configuration.background
        self.showDeleteGroup = configuration.showDeleteGroup
        self.showCreateGroup = configuration.showCreateGroup
        self.showLeaveGroup = configuration.showLeaveGroup
        self.groupListMode = configuration.groupListMode
        self.groupListItemConfiguration = configuration.groupListItemConfiguration
    }
}

