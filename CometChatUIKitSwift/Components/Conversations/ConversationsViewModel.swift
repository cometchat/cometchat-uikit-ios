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
    var reloadAtIndex: ((IndexPath) -> Void)? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
    var newMessageReceived: ((_ message: BaseMessage) -> Void)? { get set }
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
    var reloadAtIndex: ((IndexPath) -> Void)?
    var deleteAtIndex: ((IndexPath) -> Void)?
    var moveRow: ((_ initialIndex: IndexPath, _ finalIndex: IndexPath) -> Void)?
    var insertAtIndex: ((IndexPath) -> Void)?
    var failure: ((CometChatException) -> Void)?
    var onDelete: ((Int, Int) -> Void)?
    var conversations: [Conversation] = []
    var filteredConversations: [Conversation] = [] { didSet { reload?() }}
    var selectedConversations: [Conversation] = []
    var originalConversations: [Conversation] = []
    internal var conversationRequest: ConversationRequest?
    internal var refereshConversationRequest: ConversationRequest?
    var updateStatus: ((Int, CometChatUserStatus) -> Void)?
    var newMessageReceived: ((_ message: BaseMessage) -> Void)?
    private var disableReceipt: Bool = false
    var conversationRequestBuilder: ConversationRequest.ConversationRequestBuilder = ConversationsBuilder.getDefaultRequestBuilder()
    var isFetchedAll = false
    var listenerRandomID = Date().timeIntervalSince1970
    var isRefresh: Bool = false {
        didSet {
            if isRefresh {
                self.fetchConversations()
            }
        }
    }
    var isTyping = false
    var enableSoundForConversation: Bool = true
    var customSoundForConversations: URL?
    var unreadCount: [Int] = []
    var updateTypingIndicator: ((_ row: Int, _ TypingIndicator: TypingIndicator, _ typingStatus: Bool) -> ())?
    
    var isFetching = false
    
    
    public func setRequestBuilder(conversationRequestBuilder: ConversationRequest.ConversationRequestBuilder) {
        self.conversationRequestBuilder = conversationRequestBuilder.with(blockedInfo: true)
        self.conversationRequest = conversationRequestBuilder.build()
    }
    
    deinit {
        disconnect()
    }
    
    // AMRK:- fetchConversation
    func fetchConversations() {
        
        if isRefresh {
            isFetchedAll = false
            refereshConversationRequest = conversationRequestBuilder.build()
            self.conversationRequest = refereshConversationRequest
        }
        
        if isFetchedAll { return }
        
        isFetching =  true
        ConversationsBuilder.fetchConversation(conversationRequest: conversationRequest!) { [weak self] result in
            
            guard let this = self else { return }
            
            switch result {
            case .success(let conversations):
                
                if conversations.isEmpty {
                    this.isFetchedAll = true
                }
                
                if this.isRefresh {
                    this.conversations = conversations
                } else {
                    this.conversations.append(contentsOf: conversations)
                }
                
                
                for conversation in this.conversations {
                    this.markAsDelivered(conversation: conversation)
                }
                this.isFetching = false
                this.reload?()
            case .failure(let error):
                this.isFetching = false
                this.failure?(error)
            }
        }
    }
    
    // MARK:- connect conversation listener
    public func connect() {
        CometChat.addUserListener("conversations-list-users-sdk-listner-\(listenerRandomID)", self)
        CometChatUserEvents.addListener("conversations-list-user-event-listener-\(listenerRandomID)", self)
        CometChat.addGroupListener("conversations-list-groups-sdk-listner-\(listenerRandomID)", self)
        CometChatGroupEvents.addListener("conversations-list-groups-event-listner-\(listenerRandomID)", self)
        CometChatMessageEvents.addListener("conversations-list-messages-event-listener-\(listenerRandomID)", self)
        CometChatCallEvents.addListener("conversations-list-call-event-listener-\(listenerRandomID)", self)
        CometChat.addCallListener("conversations-list-call-sdk-listener-\(listenerRandomID)", self)
        
    }
    
    // MARK:- disconnect conversation listener
    public func disconnect() {
        CometChat.removeUserListener("conversations-list-users-sdk-listner-\(listenerRandomID)")
        CometChatUserEvents.removeListener("conversations-list-user-event-listener-\(listenerRandomID)")
        CometChat.removeGroupListener("conversations-list-groups-sdk-listner-\(listenerRandomID)")
        CometChatGroupEvents.removeListener("conversations-list-groups-event-listner-\(listenerRandomID)")
        CometChatMessageEvents.removeListener("conversations-list-messages-event-listener-\(listenerRandomID)")
        CometChatCallEvents.removeListener("conversations-list-call-event-listener-\(listenerRandomID)")
        CometChat.removeCallListener("conversations-list-call-sdk-listener-\(listenerRandomID)")
    }
    
    func markAsDelivered(conversation: Conversation) {
        if !disableReceipt {
            if let message = conversation.lastMessage, message.deliveredAt == 0.0, message.senderUid != CometChat.getLoggedInUser()?.uid {
                CometChat.markAsDelivered(baseMessage: message)
            }
        }
    }
    
    // get the row when typingDetails.
    func getConversationRow(with typingDetails: TypingIndicator) -> Int? {
        guard let row = self.conversations.firstIndex(where: {
            (
                ($0.conversationWith as? User)?.uid == typingDetails.sender?.uid &&
                typingDetails.receiverType == .user
            ) ||
            (
                ($0.conversationWith as? Group)?.guid == typingDetails.receiverID &&
                typingDetails.receiverType == .group
            )
        }) else { return nil }
        return row
    }
    
    func checkForConversationUpdate(action: ActionMessage? = nil) -> Bool {
        return CometChat.getConversationUpdateSettings().groupActions
    }
    
    func checkForConversationUpdate(message: BaseMessage) -> Bool {
        
        let settings = CometChat.getConversationUpdateSettings()
        if message.parentMessageId == 0 || settings.messageReplies == true {
            if let customMessage = message as? CustomMessage {
                if customMessage.updateConversation || settings.customMessages || ((customMessage.metaData?["incrementUnreadCount"] as? Bool) == true) {
                    return true
                } else {
                    return false
                }
            } else if let call = (message as? Call) {
                return settings.callActivities
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    
    func update(group: Group) {
        if let conversationOfGroup = self.conversations.first(where: { ($0.conversationWith as? Group)?.guid == group.guid }) {
            conversationOfGroup.conversationWith = group
        }
    }
    
    func removerConversation(for entity: AppEntity) {
        
        if let conversationIndex = conversations.firstIndex(where: {
            ($0.conversationWith as? User)?.uid == (entity as? User)?.uid ||
            ($0.conversationWith as? Group)?.guid == (entity as? Group)?.guid
        }) {
            removeAt(at: conversationIndex)
        }
        
    }
   
}


extension ConversationsViewModel  {
    
    /// add conversation.
    func add(conversation: Conversation) -> Self {
        if !self.conversations.contains(obj: conversation) {
            self.conversations.append(conversation)
            self.insertAtIndex?(IndexPath(row: self.conversations.count, section: 0))
        }
        return self
    }
        
    /// insert conversation.
    func insert(conversation: Conversation, at: Int = 0) {
        conversations.insert(conversation, at: at)
        self.insertAtIndex?(IndexPath(row: at, section: 0))
    }
    
    /// update conversation.
    func update(conversation: Conversation) {
        markAsDelivered(conversation: conversation)
        if let currentRow = conversations.firstIndex(where: {
            return $0.conversationId == conversation.conversationId
        }) {
            conversations[currentRow] = conversation
            self.reloadAtIndex?(IndexPath(row: currentRow, section: 0))
        }
    }
    
    /// update last message.
    func update(lastMessage: BaseMessage, updateCount: Bool = true) {
        if let conversation = CometChat.getConversationFromMessage(lastMessage) {
            
            //Updating Last Message and Unread Count
            if let existingConversation = conversations.first(where: {
                lastMessage.conversationId == $0.conversationId
            }) {
                if !LoggedInUserInformation.isLoggedInUser(uid: lastMessage.sender?.uid) {
                    if updateCount && lastMessage.readAt == 0 {
                        conversation.unreadMessageCount = existingConversation.unreadMessageCount + 1
                    } else {
                        conversation.unreadMessageCount = existingConversation.unreadMessageCount
                    }
                }
                moveToTop(conversation: conversation)
                update(conversation: conversation)
            } else {
                // when new message receive.
                if !LoggedInUserInformation.isLoggedInUser(uid: lastMessage.sender?.uid) {
                    conversation.unreadMessageCount = 1
                }
                self.insert(conversation: conversation)
            }
            
        }
    }
    
    open func updateAlreadyPresent(lastMessage: BaseMessage) {
        if let existingConversation = conversations.first(where: {
            lastMessage.conversationId == $0.conversationId
        }) {
            if existingConversation.lastMessage?.id == lastMessage.id {
                if let updatedConversation = CometChat.getConversationFromMessage(lastMessage) {
                    updatedConversation.unreadMessageCount = existingConversation.unreadMessageCount
                    moveToTop(conversation: updatedConversation)
                    update(conversation: updatedConversation)
                }
            }
        }
    }
    
    /// remove conversation.
    @discardableResult
    public func remove(conversation: Conversation) -> Self {
        if let index = conversations.firstIndex(of: conversation) {
            self.conversations.remove(at: index)
            self.deleteAtIndex?(IndexPath(row: index, section: 0))
        }
        return self
    }
    
    /// delete conversation.
    @discardableResult
    public func delete(conversation: Conversation) -> Self {
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
    public func moveToTop(conversation: Conversation) {
        guard let row = conversations.firstIndex(where: {$0.conversationId == conversation.conversationId}) else { return }
        
        //Updating conversation data source
        conversations.remove(at: row)
        conversations.insert(conversation, at: 0)
        
        //Updating UI
        moveRow?(IndexPath(row: row, section: 0), IndexPath(row: 0, section: 0))
    }
    
    /// remove conversation at particular index.
    public func removeAt(at index: Int) {
        conversations.remove(at: index)
        deleteAtIndex?(IndexPath(row: index, section: 0))
    }
    
    /// clear conversation list.
    public func clearList() {
        self.conversations.removeAll()
        self.reload?()
    }
    
    /// get the size of conversations.
    public func size() -> Int {
        return self.conversations.count
    }
    
    func disable(receipt: Bool) {
        self.disableReceipt = receipt
    }
}
