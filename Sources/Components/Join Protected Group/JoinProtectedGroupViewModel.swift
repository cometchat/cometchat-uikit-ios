//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 13/01/23.
//
import Foundation
import CometChatSDK

protocol JoinProtectedGroupViewModelProtocol {
    var success: ((CometChatSDK.Group) -> Void)? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
}

class JoinProtectedGroupViewModel: JoinProtectedGroupViewModelProtocol {
   
    var success: ((CometChatSDK.Group) -> Void)?
    var failure: ((CometChatSDK.CometChatException) -> Void)?
    
    func joinGroup(group: Group, password: String) {
        CometChat.joinGroup(GUID: group.guid, groupType: .password, password: password) { [weak self] group in
            guard let this = self else { return }
            this.success?(group)
        } onError: { [weak self] error in
            guard let this = self else { return }
            if let error = error {
                this.failure?(error)
            }
        }
    }
}

