//
//  CometChatConversations + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 09/02/25.
//

import Foundation
import CometChatSDK

extension CometChatConversations {
    
    //MARK: Events
    @discardableResult
    public func set(onItemClick: @escaping ((_ conversation: Conversation, _ indexPath: IndexPath) -> Void)) -> Self {
        self.onItemClick = onItemClick
        return self
    }
    
    @discardableResult
    public func set(onItemLongClick: @escaping ((_ conversation: Conversation, _ indexPath: IndexPath) -> Void)) -> Self {
        self.onItemLongClick = onItemLongClick
        return self
    }
    
    @discardableResult
    public func set(onSelection: @escaping ((_ conversation: [Conversation]) -> Void)) -> Self {
        self.onSelection = onSelection
        return self
    }
    
    @discardableResult
    public func set(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
    @discardableResult
    public func set(onLoad: @escaping ((_ conversation: [Conversation]) -> Void)) -> Self {
        self.onLoad = onLoad
        return self
    }
    
    @discardableResult
    public func set(onEmpty: @escaping (() -> Void)) -> Self {
        self.onEmpty = onEmpty
        return self
    }
    
    
    //MARK: Configurations
    @discardableResult
    public func set(textFormatters: [CometChatTextFormatter]) -> Self {
        self.textFormatters = textFormatters
        return self
    }
    
    @discardableResult
    public func set(datePattern: @escaping ((_ conversation: Conversation) -> String)) -> Self {
        self.datePattern = datePattern
        return self
    }
    
    @discardableResult
    public func set(options: ((_ conversation: Conversation?) -> [CometChatConversationOption])?) -> Self {
      self.options = options
      return self
    }
    
    @discardableResult
    public func add(options: ((_ conversation: Conversation?) -> [CometChatConversationOption])?) -> Self {
      self.addOptions = options
      return self
    }
    
    @discardableResult
    public func set(customSoundForMessages: URL) -> Self {
        self.customSoundForMessages = customSoundForMessages
      return self
    }
    
    
    //MARK: UI updates
    @discardableResult
    public func set(listItemView: @escaping ((_ conversation: Conversation) -> UIView)) -> Self {
        self.listItemView = listItemView
        return self
    }
    
    @discardableResult
    public func set(trailView: @escaping ((_ conversation: Conversation) -> UIView)) -> Self {
        self.tailView = tailView
        return self
    }
    
    @discardableResult
    public func set(subtitleView: @escaping ((_ conversation: Conversation) -> UIView)) -> Self {
        self.subtitleView = subtitleView
        return self
    }
    
    @discardableResult
    public func set(leadingView: @escaping ((_ conversation: Conversation) -> UIView)) -> Self {
        self.leadingView = leadingView
        return self
    }
    
    @discardableResult
    public func set(titleView: @escaping ((_ conversation: Conversation) -> UIView)) -> Self {
        self.titleView = titleView
        return self
    }
    
    
    //MARK: Data
    @discardableResult
    public func set(conversationRequestBuilder: ConversationRequest.ConversationRequestBuilder) -> Self {
        viewModel.setRequestBuilder(conversationRequestBuilder: conversationRequestBuilder)
        return self
    }
    
    @discardableResult
    public func insert(conversation: Conversation, at: Int) -> Self {
        viewModel.insert(conversation: conversation, at: at)
        return self
    }
    
    @discardableResult
    func update(conversation: Conversation) -> Self {
        viewModel.update(conversation: conversation)
        return self
    }
    
    @discardableResult
    func remove(conversation: Conversation) -> Self {
        viewModel.remove(conversation: conversation)
        return self
    }
    
    @discardableResult
    func clearList() -> Self {
        viewModel.clearList()
        return self
    }
    
    func size() -> Int {
        return viewModel.size()
    }
    
    @discardableResult
    public func getSelectedConversations() -> [Conversation] {
        return viewModel.selectedConversations
    }
    
    public func getConversationList() -> [Conversation] {
        return viewModel.conversations
    }

    @discardableResult
    public func setMentionAllLabel(_ id: String, _ label: String)  -> Self{
        if let mentionFormatter = textFormatters.first(where: { $0 is CometChatMentionsFormatter }) as? CometChatMentionsFormatter {
            mentionFormatter.setMentionAllLabel(id: id, label: label)
        }
        return self
    }
}
