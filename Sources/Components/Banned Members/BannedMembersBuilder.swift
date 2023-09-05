//
//  BannedGroupMembersBuilder.swift
//  Created by admin on 22/11/22.
//

import Foundation
import CometChatSDK

enum BannedGroupMembersBuilderResult {
    case success([GroupMember])
    case failure(CometChatException)
}

enum UnbannedGroupMembersBuilderResult {
    case success(String)
    case failure(CometChatException)
}

public class BannedMembersBuilder {
    
    static public func getSharedBuilder(for group: Group) -> BannedGroupMembersRequest.BannedGroupMembersRequestBuilder {
        return BannedGroupMembersRequest.BannedGroupMembersRequestBuilder(guid: group.guid).set(limit: 30)
    }
    
    static func filterBannedGroupMembers(filterBannedMembersRequest: BannedGroupMembersRequest, completion: @escaping (BannedGroupMembersBuilderResult) -> Void) {
        filterBannedMembersRequest.fetchNext { bannedMember in
            completion(.success(bannedMember))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
    
    static func fetchBannedGroupMembers(bannedGroupMembersRequest: BannedGroupMembersRequest,  completion: @escaping (BannedGroupMembersBuilderResult) -> Void) {
        bannedGroupMembersRequest.fetchNext { fetchedBannedMember in
            completion(.success(fetchedBannedMember))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
    
    static func unbanGroupMembers(uid: String, guid: String, completion: @escaping (UnbannedGroupMembersBuilderResult) -> Void) {
        CometChat.unbanGroupMember(UID: uid, GUID: guid) { unbanMember in
            completion(.success(unbanMember))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
}
