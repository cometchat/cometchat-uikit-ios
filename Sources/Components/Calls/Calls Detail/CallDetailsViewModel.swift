//
//  File.swift
//  
//
//  Created by Ajay Verma on 07/03/23.
//

import Foundation
import CometChatSDK

protocol CallDetailsViewModelProtocol {
    
    var user: User? { get set }
    var group: Group? { get set }
    var updateUserStatus: ((Bool) -> Void)? { get set }
    var updateGroupCount: ((Bool) -> Void)? { get set }
}

public class CallDetailsViewModel: NSObject, CallDetailsViewModelProtocol {
    
    var user: User?
    var group: Group?
    var updateUserStatus: ((Bool) -> Void)?
    var updateGroupCount: ((Bool) -> Void)?
    
    init(user: User) {
        super.init()
        self.user = user
    }
    
    init(group: Group) {
        super.init()
        self.group = group
    }


    public func connect() {
        CometChat.addUserListener("call-details-user-listener", self)
        CometChat.addGroupListener("call-details-groups-sdk-listener", self)
        CometChatGroupEvents.addListener("call-details-group-event-listener", self)
        CometChatUserEvents.addListener("call-details-users-event-listener", self)
    }
    
    public func disconnect() {
        CometChat.removeUserListener("call-details-user-listener")
        CometChat.removeGroupListener("call-details-groups-sdk-listener")
        CometChatGroupEvents.removeListener("call-details-group-event-listener")
        CometChatUserEvents.removeListener("call-details-users-event-listener")
    }
    
}
