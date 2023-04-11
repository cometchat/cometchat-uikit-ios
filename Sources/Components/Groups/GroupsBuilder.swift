//
//  GroupsBuilder.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 18/11/22.
//

import Foundation
import CometChatPro


enum GroupsBuilderResult {
    case success([Group])
    case failure(CometChatException)
}


public class GroupsBuilder {
    
    public static let shared: CometChatPro.GroupsRequest.GroupsRequestBuilder = CometChatPro.GroupsRequest.GroupsRequestBuilder(limit: 30)
    
    static func getSearchBuilder(searchText: String, groupRequestBuilder: CometChatPro.GroupsRequest.GroupsRequestBuilder = shared) -> CometChatPro.GroupsRequest.GroupsRequestBuilder {
        return groupRequestBuilder.set(searchKeyword: searchText)
    }
    
    static func getfilteredGroups(filterGroupRequest: GroupsRequest, completion: @escaping (GroupsBuilderResult) -> Void) {
        filterGroupRequest.fetchNext { groups in
            completion(.success(groups))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
    
    static func fetchGroups(groupRequest: GroupsRequest,  completion: @escaping (GroupsBuilderResult) -> Void) {
        groupRequest.fetchNext { fetchedGroups in
            completion(.success(fetchedGroups))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
}

