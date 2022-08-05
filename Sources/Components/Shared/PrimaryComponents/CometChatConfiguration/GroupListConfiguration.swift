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
    
    var emptyView: UIView?
    var background: [CGColor]?
    var hideDeleteGroup : Bool = true
    var hideLeaveGroup : Bool = true
    var hideError : Bool = false
    var isJoinedOnly : Bool = false
    var searchKeyWord : String = ""
    var tags : [String] = [String]()
    var limit : Int = 30
    var groupListMode: GroupDisplayMode  = .none
    var groupListItemConfiguration : GroupListItemConfiguration?
    var emptyText: String = "NO_GROUPS_FOUND".localize()
    var errorText: String = "SOMETHING_WENT_WRONG_ERROR".localize()
    
    private func set(background: [CGColor]) -> GroupListConfiguration {
        self.background = background
        return self
    }

    private func hide(deleteGroup: Bool) -> GroupListConfiguration {
        self.hideDeleteGroup = deleteGroup
        return self
    }
    
    private func hide(leaveGroup: Bool) -> GroupListConfiguration {
        self.hideLeaveGroup = leaveGroup
        return self
    }
    
    public func set(emptyView: UIView?) -> GroupListConfiguration {
        self.emptyView = emptyView
        return self
    }
    
    public func hide(error: Bool) -> GroupListConfiguration {
        self.hideError = error
        return self
    }
    
    public func set(joinedOnly: Bool) -> GroupListConfiguration {
        self.isJoinedOnly = joinedOnly
        return self
    }
    
    public func set(searchKeyword: String) -> GroupListConfiguration {
        self.searchKeyWord = searchKeyword
        return self
    }
    
    public func set(tags: [String]) -> GroupListConfiguration {
        self.tags = tags
        return self
    }
    
    public func set(limit: Int) -> GroupListConfiguration {
        self.limit = limit
        return self
    }
    
    public func set(errorText: String?) -> GroupListConfiguration {
        self.errorText = errorText ?? ""
        return self
    }
    
    public func set(emptyText: String?) -> GroupListConfiguration {
        self.emptyText = emptyText ?? ""
        return self
    }
    
  
}

