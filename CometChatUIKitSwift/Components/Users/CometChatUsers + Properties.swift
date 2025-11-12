//
//  CometChatUsers + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 19/06/24.
//

import Foundation
import CometChatSDK

extension CometChatUsers {
    
    public func set(userRequestBuilder: UsersRequest.UsersRequestBuilder) -> Self {
        viewModel.userRequestBuilder = userRequestBuilder
        viewModel.setRequestBuilder(userRequestBuilder: userRequestBuilder)
        return self
    }
    
    public func set(searchRequestBuilder: UsersRequest.UsersRequestBuilder) -> Self {
        viewModel.userRequestBuilder = searchRequestBuilder
        return self
    }
    
    public func set(searchKeyword: String) -> Self {
        self.searchKeyWord = searchKeyword
        return self
    }
    
    @discardableResult
    public func set(onSelection: @escaping ((_ user: [User]) -> Void)) -> Self {
        self.onSelection = onSelection
        return self
    }
    
    @discardableResult
    public func set(subtitle: ((_ user: User?) -> UIView)?) -> Self {
        self.subtitle = subtitle
        return self
    }
    
    @discardableResult
    public func set(listItemView: ((_ user: User?) -> UIView)?) -> Self {
        self.listItemView = listItemView
        return self
    }
    
    @discardableResult
    public func set(titleView: ((_ user: User?) -> UIView)?) -> Self {
        self.titleView = titleView
        return self
    }
    
    @discardableResult
    public func set(leadingView: ((_ user: User?) -> UIView)?) -> Self {
        self.leadingView = leadingView
        return self
    }
    
    @discardableResult
    public func set(trailingView: ((_ user: User?) -> UIView)?) -> Self {
        self.trailingView = trailingView
        return self
    }
    
    @discardableResult
    public func set(options: ((_ user: User?) -> [CometChatUserOption])?) -> Self {
        self.options = options
        return self
    }
    
    @discardableResult
    public func add(options: ((_ user: User?) -> [CometChatUserOption])?) -> Self {
        self.addOptions = options
        return self
    }
    
    @discardableResult
    public func set(onItemClick: @escaping ((_ user: User, _ indexPath: IndexPath?) -> Void)) -> Self {
        self.onItemClick = onItemClick
        return self
    }
    
    @discardableResult
    public func set(onItemLongClick: @escaping ((_ user: User, _ indexPath: IndexPath) -> Void)) -> Self {
        self.onItemLongClick = onItemLongClick
        return self
    }
    
    @discardableResult
    public func set(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
    @discardableResult
    public func set(onLoad: @escaping (([[User]]) -> Void)) -> Self {
        self.onLoad = onLoad
        return self
    }
    
    @discardableResult
    public func set(onEmpty: @escaping (() -> Void)) -> Self {
        self.onEmpty = onEmpty
        return self
    }
    
    @discardableResult
    public func set(selectionLimit : Int) -> Self {
        self.selectionLimit = selectionLimit
        return self
    }

}
