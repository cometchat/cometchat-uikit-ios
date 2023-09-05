//
//  CreateGroupViewModel.swift
 
//
//  Created by Pushpsen Airekar on 12/01/23.
//

import Foundation
import CometChatSDK

protocol CreateGroupViewModelProtocol {
    var success: ((CometChatSDK.Group) -> Void)? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
}

class CreateGroupViewModel: CreateGroupViewModelProtocol {
   
    var success: ((CometChatSDK.Group) -> Void)?
    var failure: ((CometChatSDK.CometChatException) -> Void)?
    
    func createGroup(name: String, groupType: CometChat.groupType, password: String?) {
        let group = Group(guid: "group_\(Int(Date().timeIntervalSince1970 * 100))", name: name, groupType: groupType, password: password)
        CometChat.createGroup(group: group) { [weak self] group in
            guard let this = self else { return }
            this.success?(group)
            CometChatGroupEvents.emitOnGroupCreate(group: group)
        } onError: { [weak self] error in
            guard let this = self else { return }
            if let error = error {
                this.failure?(error)
            }
        }
    }
}
