//
//  UsersBuilder.swift
//  
//
//  Created by Abdullah Ansari on 21/11/22.
//

import UIKit
import CometChatPro

enum UsersBuilderResult {
    case success([User])
    case failure(CometChatException)
}

public class UsersBuilder {
    
    // This is for fetching the users.
    public static let shared: CometChatPro.UsersRequest.UsersRequestBuilder = CometChatPro.UsersRequest.UsersRequestBuilder().set(limit: 30)
    
    
    static func getSearchBuilder(searchText: String, userRequestBuilder: CometChatPro.UsersRequest.UsersRequestBuilder = shared) -> CometChatPro.UsersRequest.UsersRequestBuilder {
        return userRequestBuilder.set(searchKeyword: searchText)
    }
    
    static func getfilteredUsers(filterUserRequest: UsersRequest, completion: @escaping (UsersBuilderResult) -> Void) {
        filterUserRequest.fetchNext { users in
            completion(.success(users))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
    
    static func fetchUsers(userRequest: UsersRequest,  completion: @escaping (UsersBuilderResult) -> Void) {
        userRequest.fetchNext { fetchedUser in
            completion(.success(fetchedUser))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
    
}
