//
//  AddMembersViewModel.swift
 
//
//  Created by Pushpsen Airekar on 13/12/22.
//

import Foundation
import CometChatSDK
import CometChatUIKitSwift

protocol AddMembersViewModelProtocol {
    var group: Group { get set }
    var isMembersAdded: ((_ messages: [ActionMessage], _ usersAdded: [User], _ groupAddedIn: Group, _ addedBy: User) -> Void)? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
    
}

class AddMembersViewModel : AddMembersViewModelProtocol {
    var group: Group
    var isMembersAdded: ((_ messages: [ActionMessage], _ usersAdded: [User], _ groupAddedIn: Group, _ addedBy: User) -> Void)?
    var failure: ((CometChatSDK.CometChatException) -> Void)?
    var unableToAddMember: ((String) -> Void)?
   
    init(group: Group) {
        self.group = group
    }
    
    func addMembers(members: [GroupMember]) {
        CometChat.addMembersToGroup(guid: group.guid, groupMembers: members) { [weak self] addedMember in
            guard let this = self else { return }
            if let loggedInUser = CometChat.getLoggedInUser() {
                var actionMessages: [ActionMessage] = [ActionMessage]()
                var containsSuccess = false
                
                members.forEach { member in
                    
                    if let uid = member.uid, (addedMember[uid] as? String) == "success" {
                        containsSuccess = true
                        
                        let actionMessage = ActionMessage()
                        actionMessage.action = .added
                        actionMessage.conversationId = "group_\(this.group.guid)"
                        actionMessage.message = "\(loggedInUser.name ?? "") added \(member.name ?? "")"
                        actionMessage.muid = "\(NSDate().timeIntervalSince1970)"
                        actionMessage.sender = loggedInUser
                        actionMessage.receiver = this.group
                        actionMessage.receiverUid = this.group.guid
                        actionMessage.messageType = .groupMember
                        actionMessage.actionBy = loggedInUser
                        actionMessage.actionOn = member
                        actionMessage.messageCategory = .action
                        actionMessage.receiverType = .group
                        actionMessage.sentAt = Int(Date().timeIntervalSince1970)
                        
                        actionMessages.append(actionMessage)
                        this.group.membersCount += 1 // Updating group count
                    }
                }
                
                if containsSuccess {
                    this.isMembersAdded?(actionMessages, members, this.group, loggedInUser)
                } else {
                    this.unableToAddMember?("Unable to add member")
                }
                
            }
            
        } onError: { [weak self] error in
            guard let this = self, let error = error else { return }
            this.failure?(error)
        }
    }
    
}
