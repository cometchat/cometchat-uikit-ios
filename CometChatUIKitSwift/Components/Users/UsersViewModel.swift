//
//  CometChatUsersViewModel.swift
//  
//
//  Created by Abdullah Ansari on 20/11/22.
//

import Foundation
import CometChatSDK

protocol UsersViewModelProtocol {
    
    var reload: (() -> Void)? { get set }
    var reloadAtIndex: ((IndexPath) -> Void)? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
    var searchedUsers: [User] { get set }
    var filteredUsers: [User] { get set }
    var isSearching: Bool { get set }
    func fetchUsers()
    func filterUsers(text: String)
    var userRequestBuilder: UsersRequest.UsersRequestBuilder { get set }
    
}

public class UsersViewModel: UsersViewModelProtocol {
    
    var users: [[User]] = [[User]]()
    var reload: (() -> Void)?
    var reloadAtIndex: ((IndexPath) -> Void)?
    var failure: ((CometChatSDK.CometChatException) -> Void)?
    var searchedUsers: [User] = []
    
    var filteredUsers: [User] = [] {
        didSet { reload?() }
    }
    var selectedUsers: [User] = []
    var isSearching: Bool = false
    var userRequestBuilder: UsersRequest.UsersRequestBuilder
    var userRequest: UsersRequest?
    private var filterUserRequest: UsersRequest?
    var isFetching = false
    var isFetchedAll = false
    var isRefresh: Bool = false {
        didSet {
            if isRefresh {
                self.fetchUsers()
            }
        }
    }
    
    init(userRequestBuilder: UsersRequest.UsersRequestBuilder) {
        self.userRequestBuilder = userRequestBuilder
        self.userRequest = userRequestBuilder.build()
    }
    
    func fetchUsers() {
        if isRefresh {
            isFetchedAll = false
            userRequestBuilder = UsersBuilder.getDefaultRequestBuilder()
            userRequest = userRequestBuilder.build()
        }

        guard let userRequest = userRequest else { return }
        if isFetchedAll { return }
        
        isFetching =  true

        UsersBuilder.fetchUsers(userRequest: userRequest) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let fetchedUsers):
                if fetchedUsers.isEmpty {
                    this.isFetchedAll = true
                } else {
                    if this.isRefresh {
                        this.users.removeAll()
                        this.isRefresh = false
                    }
                    this.isFetchedAll = fetchedUsers.count < userRequest.limit
                }
                this.isFetching = false
                this.groupUsers(users: fetchedUsers)
            case .failure(let error):
                this.failure?(error)
                this.isFetching = false
            }
        }
    }

    
   
    private func groupUsers(users: [User]){
        
        var staticUsers: [[User]] = self.users
        for index in 0..<users.count {
            let lastCharter = staticUsers.last?.first?.name?.first
            let user = users[index]
            
            if let lastCharter = lastCharter {
                if user.name?.first?.lowercased() == lastCharter.lowercased() {
                    staticUsers[staticUsers.count - 1].append(user)
                } else {
                    staticUsers.append([user])
                }
            } else {
                staticUsers.append([user])
            }
        }

        DispatchQueue.main.async {
            self.users.removeAll()
            self.users = staticUsers
            self.reload?()
        }
    }
    
    func filterUsers(text: String) {
        self.filterUserRequest = self.userRequestBuilder.set(searchKeyword: text).build()
        guard let filterUserRequest = filterUserRequest else { return }
        UsersBuilder.getfilteredUsers(filterUserRequest: filterUserRequest) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let filteredUser):
                this.filteredUsers = filteredUser
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    func connect() {
        CometChat.addUserListener(UsersListenerConstants.userListener, self)
        CometChatUserEvents.addListener("user-listener", self)
    }
    
    func disconnect() {
        CometChat.removeUserListener(UsersListenerConstants.userListener)
        CometChatUserEvents.removeListener("user-listerner")
    }
    
    func getIndexPath(for user: User) -> IndexPath? {
        for (section, users) in users.enumerated() {
            for (row, currentUser) in users.enumerated() {
                if currentUser.uid == user.uid {
                    return IndexPath(row: row, section: section)
                }
            }
        }
        return nil
    }
    
}

extension UsersViewModel {
    
    @discardableResult
    func add(user: User) -> Self {
        if !self.users.contains(obj: user) {
            self.users[0].insert(user, at: 0)
            self.reload?()
        }
        return self
    }
    
    @discardableResult
    func update(user: User) -> Self {
        
        if let indexPath = getIndexPath(for: user) {
            self.users[indexPath.section][indexPath.row] = user
            self.reloadAtIndex?(indexPath)
        }
        
        return self
    }
    
    @discardableResult
    public func remove(user: User) -> Self {
        if let indexPath = getIndexPath(for: user) {
            self.users[indexPath.section].remove(at: indexPath.row)
            self.reload?()
        }
        return self
    }
    
    @discardableResult
    public func clearList() -> Self {
        self.users.removeAll()
        self.reload?()
        return self
    }
    
    public func size() -> Int {
        return self.users.count
    }
    
}
