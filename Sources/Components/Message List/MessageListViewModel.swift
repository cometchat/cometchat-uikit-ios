//
//  MessageListViewModel.swift
 
//
//  Created by Pushpsen Airekar on 01/12/22.
//

import Foundation
import CometChatSDK


protocol MessageListViewModelProtocol {
    var user: CometChatSDK.User? { get set }
    var group: CometChatSDK.Group? { get set }
    var parentMessage: CometChatSDK.BaseMessage? { get set }
    var selectedMessages: [CometChatSDK.BaseMessage] { get set }
    var messagesRequestBuilder: CometChatSDK.MessagesRequest.MessageRequestBuilder { get set }
    var messages: [(date: Date, messages: [BaseMessage])] { get set }
    var reload: (() -> Void)? { get set }
    var refresh: (() -> Void)? { get set }
    var newMessageReceived: ((_ message: BaseMessage) -> Void)? { get set }
    var appendAtIndex: ((Int, Int, BaseMessage) -> Void)? { get set }
    var updateAtIndex: ((Int, Int, BaseMessage) -> Void)? { get set }
    var deleteAtIndex: ((Int, Int, BaseMessage) -> Void)? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
    func fetchNextMessages()
    func fetchPreviousMessages()
}

open class MessageListViewModel: NSObject, MessageListViewModelProtocol {
    
    var group: CometChatSDK.Group?
    var user: CometChatSDK.User?
    var parentMessage: CometChatSDK.BaseMessage?
    var messages: [(date: Date, messages: [CometChatSDK.BaseMessage])] = []
    var selectedMessages: [CometChatSDK.BaseMessage] = []
    var messagesRequestBuilder: CometChatSDK.MessagesRequest.MessageRequestBuilder
    var messageActionRequestBuilder = MessagesRequest.MessageRequestBuilder().build()
    var messageNextRequestBuilder = MessagesRequest.MessageRequestBuilder().build()
    private var messagesRequest: MessagesRequest?
    private var filterMessagesRequest: MessagesRequest?
    var reload: (() -> Void)?
    var refresh: (() -> Void)?
    var newMessageReceived: ((_ message: BaseMessage) -> Void)?
    var appendAtIndex: ((Int, Int, BaseMessage) -> Void)?
    var updateAtIndex: ((Int, Int, BaseMessage) -> Void)?
    var deleteAtIndex: ((Int, Int, BaseMessage) -> Void)?
    var failure: ((CometChatSDK.CometChatException) -> Void)?
    private var disableReceipt: Bool = false
    
    public override init() {
        messagesRequestBuilder = MessagesRequest.MessageRequestBuilder()
    }
    
    init(group: Group, messagesRequestBuilder: CometChatSDK.MessagesRequest.MessageRequestBuilder?, parentMessage: BaseMessage? = nil) {
        self.group = group
        self.parentMessage = parentMessage
        self.messagesRequestBuilder = messagesRequestBuilder ?? MessagesRequest.MessageRequestBuilder().set(guid: group.guid)
        self.messagesRequest = self.messagesRequestBuilder.build()
    }
    
    init(user: User, messagesRequestBuilder: CometChatSDK.MessagesRequest.MessageRequestBuilder?, parentMessage: BaseMessage? = nil) {
        self.user = user
        self.parentMessage = parentMessage
        self.messagesRequestBuilder = messagesRequestBuilder ?? MessagesRequest.MessageRequestBuilder().set(uid: user.uid ?? "")
        self.messagesRequest = self.messagesRequestBuilder.build()
    }

    func fetchNextMessages() {
        guard let messagesRequest = messagesRequest else { return }
        MessagesListBuilder.fetchNextMessages(messageRequest: messagesRequest) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let fetchedMessages):
                this.groupMessages(messages: fetchedMessages, withRefresh: true)
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    func fetchPreviousMessages() {
        guard let messagesRequest = messagesRequest else { return }
        MessagesListBuilder.fetchPreviousMessages(messageRequest: messagesRequest) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let fetchedMessages):
                if this.messages.isEmpty {
                    this.groupMessages(messages: fetchedMessages, withRefresh: true)
                } else {
                    this.groupMessages(messages: fetchedMessages, withRefresh: false)
                }
                
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    func fetchMissedMessages() {
        if let id = messages.last?.messages.last?.id {
            if let user = self.user, let uid = user.uid {
                messageNextRequestBuilder = MessagesRequest.MessageRequestBuilder().set(messageID: id).set(uid: uid).build()
            } else if let group = self.group {
                messageNextRequestBuilder = MessagesRequest.MessageRequestBuilder().set(messageID: id).set(guid: group.guid).build()
            }
            fetchNextMessagesFromLastMessage()
        }
    }
    
    func fetchNextMessagesFromLastMessage() {
            MessagesListBuilder.fetchNextMessages(messageRequest: messageNextRequestBuilder) { [weak self] result in
                guard let this = self else { return }
                switch result {
                case .success(let fetchedMessages):
                    if fetchedMessages.count > 0 {
                        this.groupNextMessages(messages: fetchedMessages, withRefresh: true)
                        if this.messages.last?.messages.last?.id != fetchedMessages.last?.id { 
                            this.fetchNextMessagesFromLastMessage()
                        }
                    } else {
                        DispatchQueue.main.async {
                            var id = [String:Any]()
                            if let user = this.user {
                                id["uid"] = user.uid
                            }
                            if let group = this.group {
                                id["guid"] = group.guid
                            }
                            if this.parentMessage?.id != 0 {
                                id["parentMessageId"] = id
                            }
                            CometChatUIEvents.emitOnActiveChatChanged(id: id, lastMessage: this.messages.last?.messages.last, user: this.user, group: this.group)
                        }
                    }
                case .failure(let error):
                    this.failure?(error)
                }
            }
    }
    
    func fetchActionMessages(_ success: @escaping (Bool) -> ()) {
        if let id = messages.last?.messages.last?.id {
            let messageActionRequest = MessagesRequest.MessageRequestBuilder().set(messageID: id)
                .set(categories: ["action"]).set(types: ["message"])
            if let user = self.user, let uid = user.uid {
                messageActionRequestBuilder = messageActionRequest.set(uid: uid).build()
            } else if let group = self.group {
                messageActionRequestBuilder = messageActionRequest.set(guid: group.guid).build()
            }
            MessagesListBuilder.fetchNextMessages(messageRequest: messageActionRequestBuilder) { [weak self] result in
                guard let this = self else { return }
                switch result {
                case .success(let fetchedMessages):
                    this.groupActionMessages(messages: fetchedMessages, withRefresh: true)
                    success(true)
                case .failure(let error):
                    this.failure?(error)
                    success(true)
                }
            }
        }
    }
    
    private func groupMessages(messages: [BaseMessage], withRefresh: Bool){
        if let lastMessage = messages.last {
            if lastMessage.deliveredAt == 0.0 {
                self.markAsDelivered(message: lastMessage)
            }
            if lastMessage.readAt == 0.0 {
                self.markAsRead(message: lastMessage)
            }
        }
        let groupedMessages = Dictionary(grouping: messages) { (element) -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(element.sentAt))
            return date.reduceToMonthDayYear()
        }
        let _ = groupedMessages.map { (date: Date, messages: [BaseMessage]) in
            if let index = self.messages.firstIndex(where: {$0.date == date}) {
                self.messages[index].messages.append(contentsOf: messages)
            } else {
                self.messages.append((date: date, messages: messages))
            }
        }
        self.messages = self.messages.sorted(by: { $0.date.compare($1.date) == .orderedAscending})
        withRefresh ? self.refresh?() : self.reload?()
    }
    
    private func groupNextMessages(messages: [BaseMessage], withRefresh: Bool){
        var missedMessages = [BaseMessage]()
        for message in messages {
            if let _ = message as? ActionMessage {
            } else {
                missedMessages.append(message)
            }
        }
        if let lastMessage = messages.last {
            if lastMessage.deliveredAt == 0.0 {
                self.markAsDelivered(message: lastMessage)
            }
            if lastMessage.readAt == 0.0 {
                self.markAsRead(message: lastMessage)
            }
        }
        let groupedMessages = Dictionary(grouping: missedMessages) { (element) -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(element.sentAt))
            return date.reduceToMonthDayYear()
        }
        let _ = groupedMessages.map { (date: Date, messages: [BaseMessage]) in
            if let index = self.messages.firstIndex(where: {$0.date == date}) {
                self.messages[index].messages.append(contentsOf: messages)
            } else {
                self.messages.append((date: date, messages: messages))
            }
        }
        self.messages = self.messages.sorted(by: { $0.date.compare($1.date) == .orderedAscending})
        withRefresh ? self.refresh?() : self.reload?()
    }
    
    private func groupActionMessages(messages: [BaseMessage], withRefresh: Bool){
        let groupedMessages = Dictionary(grouping: messages) { (element) -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(element.sentAt))
            return date.reduceToMonthDayYear()
        }
        for baseMessage in messages {
            if baseMessage.messageCategory == .action, let actionMessage = baseMessage as? ActionMessage, let message = actionMessage.actionOn as? BaseMessage {
                let _ = groupedMessages.map { (date: Date, messages: [BaseMessage]) in
                    if let index = self.messages.firstIndex(where: {$0.date == date}) {
                        if let index_ = self.messages[index].messages.firstIndex(where: {$0.id == message.id}) {
                            self.messages[index].messages.remove(at: index_)
                            self.messages[index].messages.insert(message, at: index_)
                        } else {
//                            self.messages[index].messages.append(message)
                        }
                    } else {
//                        self.messages.append((date: date, messages: [message]))
                    }
                }
            }
        }
        self.messages = self.messages.sorted(by: { $0.date.compare($1.date) == .orderedAscending})
        withRefresh ? self.refresh?() : self.reload?()
    }
    
    // MARK:- connect message listener
    public func connect() {
        CometChat.addMessageListener("message-list-messages-listener", self)
        CometChat.addCallListener("message-list-call-sdk-listner", self)
        CometChatCallEvents.addListener("message-list-call-event-listner", self)
        CometChatMessageEvents.addListener("event-listener", self)
        CometChat.addGroupListener("message-list-groups-sdk-listner", self)
        CometChatGroupEvents.addListener("message-list-groups-events-listener", self)
    }
    
    // MARK:- disconnect message listener
    public func disconnect() {
        CometChat.removeCallListener("message-list-call-sdk-listner")
        CometChat.removeMessageListener("message-list-messages-listener")
        CometChat.removeUserListener("message-list-users-listener")
        CometChatMessageEvents.removeListener("event-listener")
        CometChatCallEvents.removeListener("message-list-call-event-listner")
        CometChat.removeGroupListener("message-list-groups-sdk-listner")
        CometChatGroupEvents.removeListener("message-list-groups-events-listener")
    }
}

extension MessageListViewModel {
    
    @discardableResult
    public func add(message: BaseMessage) -> Self {
        DispatchQueue.main.async {
            if message.deliveredAt == 0.0 {
                self.markAsDelivered(message: message)
            }
            switch message.receiverType {
            case .user:
                if (CometChat.getLoggedInUser()?.uid == message.sender?.uid && message.receiverUid == self.user?.uid)  || (CometChat.getLoggedInUser()?.uid != message.sender?.uid && message.sender?.uid == self.user?.uid) {
                    if message.readAt == 0.0 {
                        self.markAsRead(message: message)
                    }
                    if let lastMessage = self.messages.last?.messages.last {
                        if String().compareDates(newTimeInterval: Double(message.muid) ?? 0.0, currentTimeInterval: Double(lastMessage.muid) ?? 0.0)  || Calendar.current.isDateInToday(Date(timeIntervalSince1970: TimeInterval(lastMessage.sentAt))) {
                            
                            self.messages[self.messages.count - 1].messages.append(message)
                            self.appendAtIndex?(self.messages.count - 1, self.messages[self.messages.count - 1].messages.count, message)
                        } else {
                            self.messages.append((date: Date(timeIntervalSince1970: TimeInterval( Double(message.muid) ?? 0.0)), messages: [message]))
                            self.appendAtIndex?(self.messages.count, ((self.messages.last?.messages.count ?? 0)), message)
                        }
                    } else {
                        self.messages.append((date: Date(timeIntervalSince1970: TimeInterval((Double(message.muid) ?? 0.0))), messages: [message]))
                        self.appendAtIndex?(self.messages.count, ((self.messages.last?.messages.count ?? 0)), message)
                    }
                }
                
            case .group:
                if message.receiverUid == self.group?.guid {
                    if message.readAt == 0.0 {
                        self.markAsRead(message: message)
                    }
                    if let lastMessage = self.messages.last?.messages.last {
                        if String().compareDates(newTimeInterval: Double(message.muid) ?? 0.0 , currentTimeInterval: Double(lastMessage.muid) ?? 0.0) || Calendar.current.isDateInToday(Date(timeIntervalSince1970: TimeInterval(lastMessage.sentAt))) {
                            self.messages[self.messages.count - 1].messages.append(message)
                            self.appendAtIndex?(self.messages.count - 1, self.messages[self.messages.count - 1].messages.count, message)
                        } else {
                            self.messages.append((date: Date(timeIntervalSince1970: TimeInterval(Double(message.muid) ?? 0.0)), messages: [message]))
                            self.appendAtIndex?(self.messages.count, ((self.messages.last?.messages.count ?? 0)), message)
                        }
                    } else {
                        self.messages.append((date: Date(timeIntervalSince1970: TimeInterval(Double(message.muid) ?? 0.0)), messages: [message]))
                        self.appendAtIndex?(self.messages.count, ((self.messages.last?.messages.count ?? 0)), message)
                    }
                }
            @unknown default: break
            }
            
        }
        return self
    }
    
    @discardableResult
    public func update(message: BaseMessage) -> Self {
            if let section = self.messages.firstIndex(where: { (date: Date, messages: [BaseMessage]) in
                if let muid = Double(message.muid), muid != 0.0 {
                    if date.timeIntervalSince1970 == 0.0 {
                        return true
                    } else {
                        return String().compareDates(newTimeInterval:  muid, currentTimeInterval:  date.timeIntervalSince1970) ? true : false
                    }
                   
                } else {
                    return String().compareDates(newTimeInterval: Double(message.sentAt), currentTimeInterval: date.timeIntervalSince1970) ? true : false
                }
            }), let row = self.messages[section].messages.firstIndex(where: {
                if message.muid != "" {
                    return $0.muid == message.muid
                    
                } else {
                    return $0.id == message.id
                }
            }) {
                self.messages[section].messages[row] = message
                self.updateAtIndex?(section, row, message)
            }
        
        return self
    }
    
    @discardableResult
    public func update(receipt: MessageReceipt) -> Self {
        if !disableReceipt {
            for (section, currentMessages) in messages.enumerated() {
                for (row, message) in currentMessages.messages.enumerated() {
                    if receipt.readAt != 0.0 && message.readAt == 0.0 {
                        messages[section].messages[row].readAt = receipt.readAt
                        self.updateAtIndex?(section, row, messages[section].messages[row])
                        
                    } else if receipt.deliveredAt != 0.0 && message.deliveredAt == 0.0 {
                        messages[section].messages[row].deliveredAt = receipt.deliveredAt
                        self.updateAtIndex?(section, row, messages[section].messages[row])
                    }
                }
            }
        }
        return self
    }
    
    @discardableResult
    public func remove(message: BaseMessage) -> Self {
        if let section = messages.firstIndex(where: { (date: Date, messages: [BaseMessage]) in
            return String().compareDates(newTimeInterval: date.timeIntervalSince1970, currentTimeInterval: Double(message.sentAt)) ? true : false
        }), let row = messages[section].messages.firstIndex(where: { $0.id == message.id || $0.muid == message.muid}) {
            messages[section].messages.remove(at: row)
            self.deleteAtIndex?(section, row, message)
        }
        return self
    }
    
    @discardableResult
    public func delete(message: BaseMessage) -> Self {
        CometChat.deleteMessage(message.id) { message in
            CometChatMessageEvents.emitOnMessageDelete(message: message)
        } onError: { [weak self] error in
            guard let this = self else { return }
            CometChatMessageEvents.emitOnError(message: message, error: error)
            this.failure?(error)
        }
        return self
    }
    
    @discardableResult
    public func copy(message: BaseMessage) -> Self {
        if let message = message as? TextMessage {
            UIPasteboard.general.string = message.text
        }
        return self
    }
    
    @discardableResult
    public func clearList() -> Self {
        self.messages.removeAll()
        return self
    }
    
    @discardableResult
    public func markAsRead(message: BaseMessage) -> Self {
        if !disableReceipt {
            CometChat.markAsRead(baseMessage: message)
        }
        return self
    }
    
    @discardableResult
    public func markAsDelivered(message: BaseMessage) -> Self {
        if !disableReceipt {
            CometChat.markAsDelivered(baseMessage: message)
        }
        return self
    }
    
    @discardableResult
    public func disable(receipt: Bool) -> Self {
        self.disableReceipt = receipt
        return self
    }
}

extension MessageListViewModel: CometChatMessageDelegate {
    
    public func onTextMessageReceived(textMessage: TextMessage) {
        self.newMessageReceived?(textMessage)
        if textMessage.parentMessageId > 0 {
            if textMessage.parentMessageId == self.parentMessage?.id ?? 0  {
                self.add(message: textMessage)
                self.parentMessage?.replyCount += 1
                if let parentMessage = self.parentMessage {
                    CometChatMessageEvents.emitOnParentMessageUpdate(message: parentMessage)
                }
            } else {
    
                if let section = messages.firstIndex(where: { (date: Date, messages: [BaseMessage]) in
                    if textMessage.deletedAt != 0 {
                        return String().compareDates(newTimeInterval: date.timeIntervalSince1970, currentTimeInterval: Double(textMessage.sentAt)) ? true : false
                    } else {
                        return String().compareDates(newTimeInterval: date.timeIntervalSince1970, currentTimeInterval: Double(textMessage.muid) ?? 0.0) ? true : false
                    }
                    
                }), let row = messages[section].messages.firstIndex(where: {
                    return $0.id == textMessage.parentMessageId
                   
                }) {
                    let message = messages[section].messages[row]
                    message.replyCount += 1
                    update(message: message )
                }

            }
        } else {
            
            self.add(message: textMessage)
        }
        
        print("MessageListViewModel - sdk - onTextMessageReceived")
    }
    
    public  func onMediaMessageReceived(mediaMessage: MediaMessage) {
        self.newMessageReceived?(mediaMessage)
        self.add(message: mediaMessage)
        
        print("MessageListViewModel - sdk - onMediaMessageReceived")
    }
    
    public func onCustomMessageReceived(customMessage: CustomMessage) {
        self.newMessageReceived?(customMessage)
        self.add(message: customMessage)
        
        print("MessageListViewModel - sdk - onCustomMessageReceived")
    }
    
    public func onMessagesDelivered(receipt: MessageReceipt) {
      self.update(receipt: receipt)
    }
    
    public func onMessagesRead(receipt: MessageReceipt) {
        self.update(receipt: receipt)
    }
    
    public func onMessageEdited(message: BaseMessage) {
        /*
         - update(message)
         */
        self.update(message: message)
        
        print("MessageListViewModel - sdk - onMessageEdited")
    }
    
    public func onMessageDeleted(message: BaseMessage) {
        /*
         update(message)
         */
        self.remove(message: message)
        
        print("MessageListViewModel - sdk - onMessageDeleted")
    }
    
    public func onTransisentMessageReceived(_ message: TransientMessage) {
        if (message.receiverType == .user && message.sender?.uid == self.user?.uid) || (message.receiverType == .group && message.receiverID == self.group?.guid){
            CometChatMessageEvents.emitOnLiveReaction(reaction: message)
        }
    }
    
}

extension MessageListViewModel: CometChatGroupDelegate {
    
    public func onGroupMemberJoined(action: CometChatSDK.ActionMessage, joinedUser: CometChatSDK.User, joinedGroup: CometChatSDK.Group) {
        self.newMessageReceived?(action)
        self.add(message: action)
        print("MessageListViewModel - sdk - onGroupMemberJoined")
    }
    
    public func onGroupMemberLeft(action: CometChatSDK.ActionMessage, leftUser: CometChatSDK.User, leftGroup: CometChatSDK.Group) {
        /*
         close detail
         */
        self.newMessageReceived?(action)
        self.add(message: action)
        print("MessageListViewModel - sdk - onGroupMemberLeft")
    }
    
    public func onGroupMemberKicked(action: CometChatSDK.ActionMessage, kickedUser: CometChatSDK.User, kickedBy: CometChatSDK.User, kickedFrom: CometChatSDK.Group) {
        /*
         // append to list.
         */
        self.newMessageReceived?(action)
        self.add(message: action)
        print("MessageListViewModel - sdk - onGroupMemberKicked")
        
    }
    
    public func onGroupMemberBanned(action: CometChatSDK.ActionMessage, bannedUser: CometChatSDK.User, bannedBy: CometChatSDK.User, bannedFrom: CometChatSDK.Group) {
        /*
         Append to the list.
         */
        self.newMessageReceived?(action)
        self.add(message: action)
        print("MessageListViewModel - sdk - onGroupMemberBanned")
    }
    
    public func onGroupMemberUnbanned(action: CometChatSDK.ActionMessage, unbannedUser: CometChatSDK.User, unbannedBy: CometChatSDK.User, unbannedFrom: CometChatSDK.Group) {
        /*
         Do Nothing.
         */
        self.newMessageReceived?(action)
        self.add(message: action)
        print("MessageListViewModel - sdk - onGroupMemberUnbanned")
    }
    
    public func onGroupMemberScopeChanged(action: CometChatSDK.ActionMessage, scopeChangeduser: CometChatSDK.User, scopeChangedBy: CometChatSDK.User, scopeChangedTo: String, scopeChangedFrom: String, group: CometChatSDK.Group) {
        self.newMessageReceived?(action)
        self.add(message: action)
        print("MessageListViewModel - sdk - onGroupMemberScopeChanged")
    }
    
    public func onMemberAddedToGroup(action: CometChatSDK.ActionMessage, addedBy: CometChatSDK.User, addedUser: CometChatSDK.User, addedTo: CometChatSDK.Group) {
        self.newMessageReceived?(action)
        self.add(message: action)
    }
}

extension MessageListViewModel: CometChatMessageEventListener {
    
    public func onMessageSent(message: CometChatSDK.BaseMessage, status: MessageStatus) {
        
       /*
        // if the status is inProgress when
        
           isThreadedList = true/false
           if message.parentid != nil {
                    addMessage()
           }
           else {
                  if message.parentid != nil
                  {
         
                  }
                  else {
                        addMessage()
                   }
           }
        
        // if the status is success when
        
        if (threadedList) {
        
            if message.parentId != null {
        
                        updateMessageByMuid()
            } else {
        
                if message.parentId != null {
        
                        updateReplyCount()
                } else {
        
                        updateMessageByMuid()
                }
          }
        
        }
        
        */
        
        print("MessageListViewModel - events - onMessageSent")
        
    }
    
    public func onMessageEdit(message: CometChatSDK.BaseMessage, status: MessageStatus) {
        print("MessageListViewModel - events - onMessageEdit")
    }
    
    public func onMessageDelete(message: CometChatSDK.BaseMessage) {
        print("MessageListViewModel - events - onMessageDelete")
    }
    
    public func onMessageReply(message: CometChatSDK.BaseMessage, status: MessageStatus) {
        print("MessageListViewModel - events - onMessageReply")
            
    }
    
    public func onMessageRead(message: CometChatSDK.BaseMessage) {
        print("MessageListViewModel - events - onMessageRead")
    }
    
    public func onParentMessageUpdate(message: CometChatSDK.BaseMessage) {
        print("MessageListViewModel - events - onParentMessageUpdate")
    }
    
    public func onLiveReaction(reaction: CometChatSDK.TransientMessage) {
        print("MessageListViewModel - events - onLiveReaction")
    }
    
    public func onMessageError(error: CometChatSDK.CometChatException) {
        
        print("MessageListViewModel - events - onMessageError")
    }
    
    public func onVoiceCall(user: CometChatSDK.User) {
        
        print("MessageListViewModel - events - onVoiceCall - User")
    }
    
    public func onVoiceCall(group: CometChatSDK.Group) {
        
        print("MessageListViewModel - events - onVoiceCall - Group")
    }
    
    public func onVideoCall(user: CometChatSDK.User) {
        
        print("MessageListViewModel - events - onMessageSent - User")
    }
    
    public func onVideoCall(group: CometChatSDK.Group) {
        
        print("MessageListViewModel - events - onMessageSent - Group")
    }
    
    public func onViewInformation(user: CometChatSDK.User) {
        
        print("MessageListViewModel - events - onMessageSent - User")
    }
    
    public func onViewInformation(group: CometChatSDK.Group) {
        
        print("MessageListViewModel - events - onMessageSent - Group")
    }
    
    public func onError(message: CometChatSDK.BaseMessage?, error: CometChatSDK.CometChatException) {
        
        print("MessageListViewModel - events - onMessageSent ")
    }
    
    public func onMessageReact(message: CometChatSDK.BaseMessage, reaction: CometChatMessageReaction) {
        
        print("MessageListViewModel - events - onMessageSent")
    }
}


extension MessageListViewModel: CometChatGroupEventListener {
    
    
    public func onItemClick(group: Group, index: IndexPath?) {
        
        print("MessageListViewModel - Events - onItemClick")
    }
    
    public func onGroupMemberAdd(group: Group, members: [GroupMember], addedBy: User) {
        /*
         update group
         */
        print("MessageListViewModel - Events - onGroupMemberAdd")
    }
    
    public func onItemLongClick(group: Group, index: IndexPath?) {
        
        print("MessageListViewModel - Events - onItemLongClick")
    }
    
    public func onCreateGroupClick() {
        
        print("MessageListViewModel - Events - onCreateGroupClick")
    }
    
    public func onGroupCreate(group: Group) {
        
        print("MessageListViewModel - Events - onGroupCreate")
    }
    
    public func onGroupDelete(group: Group) {
        
        print("MessageListViewModel - Events - onGroupCreate")
    }
    
    public func onOwnershipChange(group: Group?, member: GroupMember?) {
        /*
         update group
         append message.
         */
        print("MessageListViewModel - Events - onOwnershipChange")
    }
    
    public func onGroupMemberLeave(leftUser: User, leftGroup:  Group) {
        
        /*
         close details
         */
        print("MessageListViewModel - Events - onGroupMemberLeave")
    }
    
    public func onGroupMemberJoin(joinedUser: User, joinedGroup:  Group) {
        
        /*
         
         updateGroup(group)
         
         */
        print("MessageListViewModel - Events - onGroupMemberJoin")
    }
    
    public func  onGroupMemberBan(bannedUser: User, bannedGroup: Group, bannedBy: User) {
        /*
         Append to list.
         */
        print("MessageListViewModel - Events - onGroupMemberBan")
    }
    
    public func onGroupMemberUnban(unbannedUserUser: User, unbannedUserGroup: Group, unbannedBy: User) {
        /*
         Do Nothing.
         */
        print("MessageListViewModel - Events - onGroupMemberUnban")
    }
    
    public func onGroupMemberKick(kickedUser: User, kickedGroup: Group, kickedBy: User) {
        /*
         append to list. the new message.
         */
        print("MessageListViewModel - Events - onGroupMemberKick")
    }
    
    public func onGroupMemberChangeScope(updatedBy: User , updatedUser: User , scopeChangedTo: CometChat.MemberScope , scopeChangedFrom: CometChat.MemberScope, group: Group) {
        /*
         Do Nothing as per figma
         */
        guard let group = self.group else { return }
        self.group = group

        print("MessageListViewModel - Events - onGroupMemberChangeScope")
    }
    
    public func onError(group: Group?, error: CometChatException) {
        
        print("MessageListViewModel - Events - onError")
    }
    
}

extension MessageListViewModel: CometChatCallDelegate {
    public func onIncomingCallReceived(incomingCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if let incomingCall = incomingCall {
            self.add(message: incomingCall)
        }
    }
    
    public func onOutgoingCallAccepted(acceptedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if let acceptedCall = acceptedCall {
            self.add(message: acceptedCall)
        }
    }
    
    public func onOutgoingCallRejected(rejectedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if let rejectedCall = rejectedCall {
            self.add(message: rejectedCall)
        }
    }
    
    public func onIncomingCallCancelled(canceledCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if let canceledCall = canceledCall {
            self.add(message: canceledCall)
        }
    }
    
}

extension MessageListViewModel:  CometChatCallEventListener {
    public func onIncomingCallAccepted(call: CometChatSDK.Call) {
        self.add(message: call)
    }
    
    public func onIncomingCallRejected(call: CometChatSDK.Call) {
        self.add(message: call)
    }
    
    public func onCallEnded(call: CometChatSDK.Call) {
        if let _ =   (call.callReceiver as? User) {
            self.add(message: call)
        }
    }
    
    public func onCallInitiated(call: CometChatSDK.Call) {
        self.add(message: call)
    }
    
    public func onOutgoingCallAccepted(call: CometChatSDK.Call) {
        self.add(message: call)
    }
    
    public func onOutgoingCallRejected(call: CometChatSDK.Call) {
        self.add(message: call)
    }
    
}



