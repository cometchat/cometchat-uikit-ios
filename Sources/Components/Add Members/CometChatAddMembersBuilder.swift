//
//  CometChatAddMembersBuilder.swift
//  
//
//  Created by admin on 02/12/22.
//

import Foundation
import CometChatSDK

enum AddMembersResult {
    case success([String: Any])
    case failure(CometChatException)
}

enum GetGroupResult {
    case success(Group)
    case failure(CometChatException)
}

class AddMembersBuilder {
    
    static func addMembers(group: Group, groupMembers: [GroupMember], completion: @escaping (AddMembersResult) -> Void) {
        CometChat.addMembersToGroup(guid:  group.guid, groupMembers: groupMembers) { fetchedMembers in
            completion(.success(fetchedMembers))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
    
    static func getGroup(group: Group, completion: @escaping (GetGroupResult) -> Void) {
        CometChat.getGroup(GUID:  group.guid) { group in
            completion(.success(group))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
}
