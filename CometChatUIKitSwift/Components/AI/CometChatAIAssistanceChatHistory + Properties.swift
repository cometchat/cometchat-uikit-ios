//
//  CometChatAIAssistanceChatHistory + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 28/10/25.
//

import Foundation
import CometChatSDK

extension CometChatAIAssistanceChatHistory {
    
    @discardableResult
    public func set(user: User, parentMessage: BaseMessage? = nil, withParent: Bool = false) -> Self {
        self.viewModel.set(user: user, messagesRequestBuilder: self.viewModel.messagesRequestBuilder, parentMessage: parentMessage)
        return self
    }
    
    @discardableResult
    public func set(group: Group, parentMessage: BaseMessage? = nil) -> Self {
        self.viewModel.set(group: group, messagesRequestBuilder: self.viewModel.messagesRequestBuilder, parentMessage: parentMessage)
        return self
    }
    
    @discardableResult
    public func set(messagesRequestBuilder: MessagesRequest.MessageRequestBuilder) -> Self {
        self.viewModel.set(messagesRequestBuilder: messagesRequestBuilder)
        return self
    }
    
    @discardableResult
    public func set(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
    @discardableResult
    public func set(onLoad: @escaping (([BaseMessage]) -> Void)) -> Self {
        self.onLoad = onLoad
        return self
    }
    
    @discardableResult
    public func set(onEmpty: @escaping (() -> Void)) -> Self {
        self.onEmpty = onEmpty
        return self
    }
    
    @discardableResult
    public func set(errorView: UIView) ->  Self {
        self.errorStateView = errorView
        return self
    }
    
    @discardableResult
    public func set(emptyView: UIView) ->  Self {
        self.emptyStateView = emptyView
        return self
    }
    
    @discardableResult
    public func set(loadingView: UIView) ->  Self {
        self.loadingShimmerView = loadingView
        return self
    }
}
