//
//  AddMembersViewModel.swift
 
//
//  Created by Pushpsen Airekar on 13/12/22.
//

import Foundation
import CometChatSDK

protocol AddMembersViewModelProtocol {
    var group: Group { get set }
    var isMembersAdded: ((Bool) -> Void)? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
    
}

class AddMembersViewModel : AddMembersViewModelProtocol {
    var group: Group
    var isMembersAdded: ((Bool) -> Void)?
    var failure: ((CometChatSDK.CometChatException) -> Void)?
   
    init(group: Group) {
        self.group = group
    }
    
    func addMembers(members: [GroupMember]) {
        AddMembersBuilder.addMembers(group: group, groupMembers: members) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(_ ):
                this.isMembersAdded?(true)
                if let loggedInUser = CometChat.getLoggedInUser() {
                CometChatGroupEvents.emitOnGroupMemberAdd(group: this.group, members: members, addedBy: loggedInUser)
                }
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
}
