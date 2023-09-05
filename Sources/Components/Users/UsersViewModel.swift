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
    var reloadAtIndex: ((Int) -> Void)? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
    var row: Int { get set }
    var users: [User] { get set }
    var filteredUsers: [User] { get set }
    var selectedUsers: [User] { get set }
    var isSearching: Bool { get set }
    func fetchUsers()
    func filterUsers(text: String)
    var userRequestBuilder: UsersRequest.UsersRequestBuilder { get set }
    
}

public class UsersViewModel: UsersViewModelProtocol {
    
    var sectionUsers: [[User]] = [[User]]()
    var sortedKeys = [String]()
    var globalGroupedUsers: [String : [User]] = [:]
    var reload: (() -> Void)?
    var reloadAtIndex: ((Int) -> Void)?
    var failure: ((CometChatSDK.CometChatException) -> Void)?
    var row: Int = -1 {
        didSet { reloadAtIndex?(row) }
    }
    var users: [User] = [] {
        didSet { reload?() }
    }
    var filteredUsers: [User] = [] {
        didSet { reload?() }
    }
    var selectedUsers: [User] = []
    var isSearching: Bool = false
    var userRequestBuilder: UsersRequest.UsersRequestBuilder
    private var userRequest: UsersRequest?
    private var filterUserRequest: UsersRequest?
    
    init(userRequestBuilder: UsersRequest.UsersRequestBuilder) {
        self.userRequestBuilder = userRequestBuilder
        self.userRequest = userRequestBuilder.build()
    }
    
    func fetchUsers() {
        self.globalGroupedUsers.removeAll()
        guard let userRequest = userRequest else { return }
        UsersBuilder.fetchUsers(userRequest: userRequest) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let fetchedUsers):
                this.users += fetchedUsers
                this.groupUsers(users: this.users)
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
   
    private func groupUsers(users: [User]){
        let groupedUsers = Dictionary(grouping: users) { (element) -> String in
            guard let name = element.name?.capitalized.trimmingCharacters(in: .whitespacesAndNewlines) else {return ""}
            if name.count > 0 {
                if let string = (name as? NSString)?.substring(to: 1) {
                    return  string
                }else{
                    return ""
                }
            }else {
                return ""
            }
        }
        globalGroupedUsers.merge(groupedUsers, uniquingKeysWith: +)
        for key in groupedUsers.keys {
            if !sortedKeys.contains(key) { sortedKeys.append(key) }
        }
        sortedKeys = sortedKeys.sorted{ $0.lowercased() < $1.lowercased()}
        var staticUsers: [[User]] = [[User]]()
        sortedKeys.forEach { (key) in
            if let value = globalGroupedUsers[key] {
                staticUsers.append(value)
            }
        }
        DispatchQueue.main.async {
            self.sectionUsers.removeAll()
            self.sectionUsers = staticUsers
            self.reload?()
        }
    }
    
    func filterUsers(text: String) {
        self.filteredUsers.removeAll()
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
    
}

extension UsersViewModel {
    
    @discardableResult
    func add(user: User) -> Self {
        if !self.users.contains(obj: user) {
            self.users.append(user)
        }
        return self
    }
    
    @discardableResult
    func insert(user: User, at: Int) -> Self {
        if !self.users.contains(obj: user) {
            self.users.insert(user, at: at)
        }
        return self
    }
    
    @discardableResult
    func update(user: User) -> Self {
        guard let row = users.firstIndex(where: {$0.uid == user.uid}) else { return self }
            self.users[row] = user
        return self
    }
    
    @discardableResult
    public func remove(user: User) -> Self {
        guard let row = users.firstIndex(where: {$0.uid == user.uid}) else { return self }
        self.users.remove(at: row)
        return self
    }
    
    @discardableResult
    public func clearList() -> Self {
        self.users.removeAll()
        return self
    }
    
    public func size() -> Int {
        return self.users.count
    }
    
}
