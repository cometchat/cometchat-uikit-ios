//
//  CometChatConversationsViewModel.swift
//  
//
//  Created by Abdullah Ansari on 24/11/22.
//

import Foundation
import CometChatSDK

protocol ConversationsViewModelProtocol {
    
    var reload: (() -> Void)? { get set }
    var reloadAtIndex: ((Int) -> Void)? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
    var newMessageReceived: ((_ message: BaseMessage) -> Void)? { get set }
    var row: Int { get set }
    var conversations: [Conversation] { get set }
    var filteredConversations: [Conversation] { get set }
    var selectedConversations: [Conversation] { get set }
    func fetchConversations()
    var conversationRequestBuilder: ConversationRequest.ConversationRequestBuilder { get set }
}

class ConversationsViewModel: ConversationsViewModelProtocol {
    
    public enum CometChatUserStatus {
      case online
      case offline
      case available
    }
    
    var reload: (() -> Void)?
    var reloadAtIndex: ((Int) -> Void)?
    var failure: ((CometChatException) -> Void)?
    var onDelete: ((Int, Int) -> Void)?
    var row: Int = -1 { didSet { reloadAtIndex?(row) } }
    var conversations: [Conversation] = [] { didSet { reload?() }}
    var filteredConversations: [Conversation] = [] { didSet { reload?() }}
    var selectedConversations: [Conversation] = []
    var originalConversations: [Conversation] = []
    private var conversationRequest: ConversationRequest?
    private var refereshConversationRequest: ConversationRequest?
    var updateStatus: ((Int, CometChatUserStatus) -> Void)?
    var newMessageReceived: ((_ message: BaseMessage) -> Void)?
    private var disableReceipt: Bool = false
    var conversationRequestBuilder: ConversationRequest.ConversationRequestBuilder
    var isRefresh: Bool = false {
        didSet {
            if isRefresh {
                self.conversations.removeAll()
                self.fetchConversations()
            }
        }
    }
    var isTyping = false
    var enableSoundForConversation: Bool = true
    var customSoundForConversations: URL?
    var unreadCount: [Int] = []
    var updateTypingIndicator: ((_ row: Int, _ TypingIndicator: TypingIndicator, _ typingStatus: Bool) -> ())?
    
    // MARK:- initializer
    init(conversationRequestBuilder: ConversationRequest.ConversationRequestBuilder) {
        self.conversationRequestBuilder = conversationRequestBuilder
        self.conversationRequest = conversationRequestBuilder.build()
    }
    
    // AMRK:- fetchConversation
    func fetchConversations() {
        if isRefresh {
            refereshConversationRequest = conversationRequestBuilder.build()
            self.conversationRequest = refereshConversationRequest
        }
        ConversationsBuilder.fetchConversation(conversationRequest: conversationRequest!) { [weak self] result in
            guard let this = self else { return }
            this.refereshConversationRequest = CometChatSDK.ConversationRequest.ConversationRequestBuilder(limit: 30).build()
            switch result {
            case .success(let conversations):
                if this.isRefresh {
                    this.conversations = conversations
                } else {
//                    if !this.conversations.contains(obj: {conversations}) {
//                        this.conversations += conversations
//                    }
                    for conversation in conversations {
                        if this.conversations.contains(where: { $0.conversationId == conversation.conversationId
                        }) {
                            this.update(conversation: conversation)
                        } else {
                            this.conversations.append(conversation)
                        }
                    }
                }
                
                for conversation in this.conversations {
                    this.markAsDelivered(conversation: conversation)
                }
                    
                this.reload?()
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    // MARK:- connect conversation listener
    public func connect() {
        CometChat.addUserListener("conversations-list-users-sdk-listner", self)
        CometChatUserEvents.addListener("conversations-list-user-event-listener", self)
        CometChat.addGroupListener("conversations-list-groups-sdk-listner", self)
        CometChatGroupEvents.addListener("conversations-list-groups-event-listner", self)
        CometChatMessageEvents.addListener("conversations-list-messages-event-listener", self)
        CometChat.addMessageListener("conversations-list-messages-sdk-listener", self)
    }
    
    // MARK:- disconnect conversation listener
    public func disconnect() {
        CometChat.removeUserListener("conversation-list-users-listener")
        CometChatUserEvents.removeListener("user-listerner")
        CometChat.removeGroupListener("conversation-list-groups-sdk-listner")
        CometChatGroupEvents.removeListener("conversation-list-groups-event-listner")
        CometChat.removeMessageListener("conversations-list-messages-event-listener")
        CometChatMessageEvents.removeListener("conversations-list-messages-event-listener")
    }
    
    func markAsDelivered(conversation: Conversation) {
        if let message = conversation.lastMessage , !disableReceipt {
            CometChat.markAsDelivered(baseMessage: message)
        }
    }
    
    // get the row when typingDetails.
    func getConversationRow(with typingDetails: TypingIndicator) -> Int? {
        guard let row = self.conversations.firstIndex(where: {($0.conversationWith as? User)?.uid == typingDetails.sender?.uid || ($0.conversationWith as? Group)?.guid == typingDetails.receiverID }) else { return nil }
        return row
    }
    
    func getConversationRow(with message: BaseMessage) -> Int? {
        guard let conversation = CometChat.getConversationFromMessage(message) else { return nil }
        markAsDelivered(conversation: conversation)
        guard let row = conversations.firstIndex(where: {$0.conversationId == conversation.conversationId}) else { return nil }
        moveToTop(row: row, conversation: conversation)
        return row
    }
   
}


extension ConversationsViewModel  {
    
    /// add conversation.
    func add(conversation: Conversation) -> Self {
        if !self.conversations.contains(obj: conversation) {
            self.conversations.append(conversation)
        }
        return self
    }
        
    /// insert conversation.
    func insert(conversation: Conversation, at: Int = 0) {
        conversations.insert(conversation, at: at)
    }
    
    /// update conversation.
    func update(conversation: Conversation) {
        if let currentRow = conversations.firstIndex(where: { conversation in
            return conversation.conversationId == conversation.conversationId
        }) {
            conversations[currentRow] = conversation
        }
    }
    
    /// update last message.
    func update(lastMessage: BaseMessage) {
        if let conversation = CometChat.getConversationFromMessage(lastMessage) {
            if conversations.contains(where: { conversation in
                return lastMessage.conversationId == conversation.conversationId
            }) {
                if !LoggedInUserInformation.isLoggedInUser(uid: lastMessage.sender?.uid) {
                    
                    if let existingConversation = conversations.filter({  conversation in
                        return lastMessage.conversationId == conversation.conversationId
                    }).first {
                        conversation.unreadMessageCount = existingConversation.unreadMessageCount + 1
                    }
                }
                getConversationRow(with: lastMessage)
                update(conversation: conversation)
            } else {
                // when new message receive.
                self.insert(conversation: conversation)
            }
        }
    }
    
    /// remove conversation.
    @discardableResult
    func remove(conversation: Conversation) -> Self {
        if let index = conversations.firstIndex(of: conversation) {
            self.conversations.remove(at: index)
        }
        return self
    }
    
    /// delete conversation.
    func delete(conversation: Conversation) -> Self {
        guard let id = conversation.conversationType == .user ? (conversation.conversationWith as? User)?.uid! : (conversation.conversationWith as? Group)?.guid else { return self }
        
        let type: CometChat.ConversationType = conversation.conversationType == .user ? .user : .group
        
        CometChat.deleteConversation(conversationWith: id, conversationType: type) { [weak self] success in
            guard let this = self else { return }
            this.remove(conversation: conversation)
        } onError: { [weak self] error in
            guard let error = error, let this = self else { return }
            this.failure?(error)
        }
        return self
    }
    
    /// move to top
    func moveToTop(row: Int, conversation: Conversation) {
        markAsDelivered(conversation: conversation)
        removeAt(at: row)
        insert(conversation: conversation)
    }
    
    /// remove conversation at particular index.
    func removeAt(at index: Int) {
        conversations.remove(at: index)
    }
    
    /// clear conversation list.
    func clearList() {
        self.conversations.removeAll()
    }
    
    /// get the size of conversations.
    func size() -> Int {
        return self.conversations.count
    }
    
    func disable(receipt: Bool) {
        self.disableReceipt = receipt
    }
}
