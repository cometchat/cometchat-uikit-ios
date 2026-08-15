//
//  CometChatConversationsViewModel.swift
//  
//
//  Created by Abdullah Ansari on 24/11/22.
//

import Foundation
import CometChatSDK

protocol ConversationsViewModelProtocol: AnyObject {

    var reload: (() -> Void)? { get set }
    var reloadAtIndex: ((IndexPath) -> Void)? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
    var newMessageReceived: ((_ message: BaseMessage) -> Void)? { get set }
    var conversations: [Conversation] { get set }
    var filteredConversations: [Conversation] { get set }
    var selectedConversations: [Conversation] { get set }
    var conversationRequestBuilder: ConversationRequest.ConversationRequestBuilder { get set }

    var deleteAtIndex: ((IndexPath) -> Void)? { get set }
    var insertAtIndex: ((IndexPath) -> Void)? { get set }
    var moveRow: ((_ initialIndex: IndexPath, _ finalIndex: IndexPath) -> Void)? { get set }
    var updateStatus: ((Int, ConversationsViewModel.CometChatUserStatus) -> Void)? { get set }
    var updateTypingIndicator: ((_ row: Int, _ TypingIndicator: TypingIndicator, _ typingStatus: Bool) -> ())? { get set }
    var onDelete: ((Int, Int) -> Void)? { get set }
    var isFetchedAll: Bool { get set }
    var isFetching: Bool { get set }
    var isRefresh: Bool { get set }
    var listenerRandomID: TimeInterval { get set }

    func connect()
    func disconnect()
    func fetchConversations()
    @discardableResult func delete(conversation: Conversation) -> Self
    func size() -> Int
    func setRequestBuilder(conversationRequestBuilder: ConversationRequest.ConversationRequestBuilder)
    func insert(conversation: Conversation, at: Int)
    func update(conversation: Conversation)
    @discardableResult func remove(conversation: Conversation) -> Self
    func clearList()
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

    /// Identifies the newest dispatched fetch. A response whose token no longer matches
    /// has been superseded by a refresh and is discarded.
    private var fetchToken: Int = 0

    var isTyping = false
    var enableSoundForConversation: Bool = true
    var customSoundForConversations: URL?
    var unreadCount: [Int] = []
    var updateTypingIndicator: ((_ row: Int, _ TypingIndicator: TypingIndicator, _ typingStatus: Bool) -> ())?
    
    var isFetching = false

    var latestMessageId: Int = -1

    /// Seam over the non-hermetic SDK request/response calls. Defaults to the live
    /// SDK-backed implementation so existing callers are unaffected; tests inject a fake.
    internal var service: ConversationsServicing

    /// Seam over the listener registries, so `connect()`/`disconnect()` symmetry is
    /// assertable without a live SDK. Defaults to the real registrar.
    internal var listeners: ListenerRegistering

    /// Existing public entry point — preserved verbatim for backward compatibility.
    public init() {
        self.service = LiveConversationsService()
        self.listeners = SDKListenerRegistrar.shared
    }

    /// Test/internal seam: inject a custom service.
    internal init(service: ConversationsServicing,
                  listeners: ListenerRegistering = SDKListenerRegistrar.shared) {
        self.service = service
        self.listeners = listeners
    }

    public func setRequestBuilder(conversationRequestBuilder: ConversationRequest.ConversationRequestBuilder) {
        self.conversationRequestBuilder = conversationRequestBuilder.with(blockedInfo: true)
        self.conversationRequest = conversationRequestBuilder.build()
    }
    
    deinit {
        disconnect()
    }
    
    // AMRK:- fetchConversation
    func fetchConversations() {

        // Whether this request replaces the list or appends to it is decided here, at
        // dispatch. The completion must not re-read `isRefresh`: pagination can flip it
        // mid-flight, which would send a page-1 response down the append path.
        let wasRefresh = isRefresh

        if wasRefresh {
            isFetchedAll = false
            refereshConversationRequest = conversationRequestBuilder.build()
            self.conversationRequest = refereshConversationRequest
        }

        // Pagination must not overlap: a second page request would advance the same
        // cursor twice. A refresh is exempt — it is an explicit "reload from scratch",
        // and it must still go out when an earlier request never came back. `isFetching`
        // is cleared only inside the completion, so a request that never calls back —
        // dropped mid-flight, or completing after this view model is gone, where the
        // `guard let this` below returns early — latches it on for good. Without the
        // exemption a guarded refresh would then never reach the server.
        if isFetchedAll || (isFetching && !wasRefresh) { return }

        // Responses are matched against this token; anything older is stale and ignored,
        // so a superseded request cannot write the list after a refresh replaced it.
        fetchToken += 1
        let token = fetchToken

        isFetching =  true
        service.fetchConversations(request: conversationRequest!) { [weak self] result in
            guard let this = self else { return }
            guard token == this.fetchToken else { return }

            switch result {
            case .success(let conversations):

                if conversations.isEmpty {
                    this.isFetchedAll = true
                }

                if wasRefresh {
                    this.conversations = conversations
                } else {
                    this.conversations.append(contentsOf: conversations)
                }


                for conversation in this.conversations {
                    this.markAsDelivered(conversation: conversation)
                }
                this.isFetching = false
                this.isRefresh = false
                this.reload?()
            case .failure(let error):
                this.isFetching = false
                this.isRefresh = false
                this.failure?(error)
            }
        }
    }
    
    // MARK:- connect conversation listener
    public func connect() {
        listeners.add(.userSDK, id: "conversations-list-users-sdk-listner-\(listenerRandomID)", listener: self)
        listeners.add(.userEvents, id: "conversations-list-user-event-listener-\(listenerRandomID)", listener: self)
        listeners.add(.groupSDK, id: "conversations-list-groups-sdk-listner-\(listenerRandomID)", listener: self)
        listeners.add(.groupEvents, id: "conversations-list-groups-event-listner-\(listenerRandomID)", listener: self)
        listeners.add(.messageEvents, id: "conversations-list-messages-event-listener-\(listenerRandomID)", listener: self)
        listeners.add(.callEvents, id: "conversations-list-call-event-listener-\(listenerRandomID)", listener: self)
        listeners.add(.callSDK, id: "conversations-list-call-sdk-listener-\(listenerRandomID)", listener: self)
        listeners.add(.conversationEvents, id: "user-details-conversations-event-listener-\(listenerRandomID)", listener: self)
    }

    // MARK:- disconnect conversation listener
    public func disconnect() {
        listeners.remove(.userSDK, id: "conversations-list-users-sdk-listner-\(listenerRandomID)")
        listeners.remove(.userEvents, id: "conversations-list-user-event-listener-\(listenerRandomID)")
        listeners.remove(.groupSDK, id: "conversations-list-groups-sdk-listner-\(listenerRandomID)")
        listeners.remove(.groupEvents, id: "conversations-list-groups-event-listner-\(listenerRandomID)")
        listeners.remove(.messageEvents, id: "conversations-list-messages-event-listener-\(listenerRandomID)")
        listeners.remove(.callEvents, id: "conversations-list-call-event-listener-\(listenerRandomID)")
        listeners.remove(.callSDK, id: "conversations-list-call-sdk-listener-\(listenerRandomID)")
        listeners.remove(.conversationEvents, id: "user-details-conversations-event-listener-\(listenerRandomID)")
    }
    
    func markAsDelivered(conversation: Conversation) {
        if !disableReceipt {
            if let message = conversation.lastMessage, message.deliveredAt == 0.0, message.senderUid != service.loggedInUserUid() {
                service.markAsDelivered(message: message)
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
        if let conversationIndex = conversations.firstIndex(where: { conversation in
            if let user = conversation.conversationWith as? User, let entityUser = entity as? User {
                return user.uid == entityUser.uid
            } else if let group = conversation.conversationWith as? Group, let entityGroup = entity as? Group {
                return group.guid == entityGroup.guid
            }
            return false
        }) {
            removeAt(at: conversationIndex)
        } else {
            print("wrong index")
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
            conversations[currentRow].unreadMessageCount = conversation.unreadMessageCount
            conversations[currentRow].lastMessage = conversation.lastMessage
            conversations[currentRow].lastReadMessageId = conversation.lastReadMessageId

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
        if let index = conversations.firstIndex(where: { $0.conversationId == conversation.conversationId }) {
            self.conversations.remove(at: index)
            DispatchQueue.main.async {
                self.deleteAtIndex?(IndexPath(row: index, section: 0))
            }
        }
        return self
    }
    
    /// delete conversation.
    @discardableResult
    public func delete(conversation: Conversation) -> Self {
        guard let id = conversation.conversationType == .user ? (conversation.conversationWith as? User)?.uid! : (conversation.conversationWith as? Group)?.guid else { return self }
        
        let type: CometChat.ConversationType = conversation.conversationType == .user ? .user : .group

        service.deleteConversation(with: id, type: type) { [weak self] _ in
            guard let this = self else { return }
            this.remove(conversation: conversation)
            CometChatConversationEvents.ccConversationDeleted(conversation: conversation)
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
