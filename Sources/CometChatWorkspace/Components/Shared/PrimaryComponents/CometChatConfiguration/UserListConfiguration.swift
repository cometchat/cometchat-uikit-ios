//
//  CometChatSettings.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 28/12/21.
//

import Foundation
import UIKit

public enum UserDisplayMode {
   case friends
   case all
   case none
}


public class UserListConfiguration: CometChatConfiguration {

    var background: [CGColor]?
    var userListMode: UserDisplayMode  = .all
    var userListItemConfiguration : UserListItemConfiguration?
    
    public func set(background: [CGColor]) -> UserListConfiguration {
        self.background = background
        return self
    }
    
    public func set(userListMode: UserDisplayMode) -> UserListConfiguration {
        self.userListMode = userListMode
        return self
    }
    
  
    public func set(userListItemConfiguration: UserListItemConfiguration) -> UserListConfiguration {
        self.userListItemConfiguration = userListItemConfiguration
        return self
    }
    
    public func set(configuration: UserListConfiguration) {
        self.background = configuration.background
        self.userListMode = configuration.userListMode
        self.userListItemConfiguration = configuration.userListItemConfiguration
    }
}

