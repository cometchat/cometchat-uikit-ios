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
    var newMessageReceived: ((_ message: BaseMessage) -> Void)? { get set }
    var appendAtIndex: ((_ section: Int, _ row: Int, _ baseMessage: BaseMessage, _ isNewSectionAdded: Bool) -> Void)? { get set }
    var updateAtIndex: ((Int, Int, BaseMessage) -> Void)? { get set }
    var deleteAtIndex: ((Int, Int, BaseMessage) -> Void)? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
    func fetchNextMessages()
    func fetchPreviousMessages()
    func fetchUnreadMessageCount()
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
    var newMessageReceived: ((_ message: BaseMessage) -> Void)?
    var appendAtIndex: ((_ section: Int, _ row: Int, _ baseMessage: BaseMessage, _ isNewSectionAdded: Bool) -> Void)?
    var updateAtIndex: ((Int, Int, BaseMessage) -> Void)?
    var deleteAtIndex: ((Int, Int, BaseMessage) -> Void)?
    var hideHeaderView: ((Bool) -> Void)?
    var hideFooterView: ((Bool) -> Void)?
    var setHeaderView: ((UIView) -> Void)?
    var setFooterView: ((UIView) -> Void)?
    var appendMessagesAtTop: ((Int, Int) -> Void)?
    var failure: ((CometChatSDK.CometChatException) -> Void)?
    var unReadMessageCount: Int?
    private var disableReceipt: Bool = false
    private var disableReaction: Bool = false
    var currentRandomDate = Date().timeIntervalSinceReferenceDate
    var isAllMessagesFetchedInPrevious = false
    var cellHeight = [IndexPath: CGFloat]()
    var isUIUpdating = false
    var templates = [String: CometChatMessageTemplate]()
    var hideDeletedMessages: Bool = false
    var messageBubbleStyle = CometChatMessageBubble.style
    var actionBubbleStyle = CometChatMessageBubble.actionBubbleStyle
    var callActionBubbleStyle = CometChatMessageBubble.callActionBubbleStyle
    var hasFetchedMessagesBefore = false
    
    var textFormatters = ChatConfigurator.getDataSource().getTextFormatters() {
        didSet {
            setUpDefaultTemplate()
        }
    }
    
    public override init() {
        messagesRequestBuilder = MessagesRequest.MessageRequestBuilder()
        super.init()
        setUpDefaultTemplate()
    }
    
    func set(group: Group, messagesRequestBuilder: CometChatSDK.MessagesRequest.MessageRequestBuilder?, parentMessage: BaseMessage? = nil) {
        self.group = group
        self.parentMessage = parentMessage
        self.messagesRequestBuilder = messagesRequestBuilder?.set(guid: group.guid) ?? MessagesRequest.MessageRequestBuilder()
            .set(guid: group.guid)
            .hideReplies(hide: true)
            .setParentMessageId(parentMessageId: parentMessage?.id ?? 0)
            .set(types: ChatConfigurator.getDataSource().getAllMessageTypes() ?? [])
        self.messagesRequest = self.messagesRequestBuilder.build()
        self.fetchUnreadMessageCount()
    }
    
    func set(user: User, messagesRequestBuilder: CometChatSDK.MessagesRequest.MessageRequestBuilder?, parentMessage: BaseMessage? = nil) {
        self.user = user
        self.parentMessage = parentMessage
        self.messagesRequestBuilder = messagesRequestBuilder?.set(uid: user.uid ?? "") ?? MessagesRequest
            .MessageRequestBuilder().set(uid: user.uid ?? "")
            .hideReplies(hide: true)
            .setParentMessageId(parentMessageId: parentMessage?.id ?? 0)
            .set(types: ChatConfigurator.getDataSource().getAllMessageTypes() ?? [])
        self.messagesRequest = self.messagesRequestBuilder.build()
        self.fetchUnreadMessageCount()
    }
    
    func sendActiveChatChangeEvent() {
        var id = [String:Any]()
        if let user = user {
            id["uid"] = user.uid
        }
        if let group = group {
            id["guid"] = group.guid
        }
        if parentMessage?.id != 0 {
            id["parentMessageId"] = parentMessage?.id
        }
        if let unReadMessageCount = unReadMessageCount{
            id["unReadMessageCount"] = unReadMessageCount
        }
        
        CometChatUIEvents.ccActiveChatChanged(id: id, lastMessage: messages.last?.messages.last, user: user, group: group)
    }

    func fetchNextMessages() {
        guard let messagesRequest = messagesRequest else { return }
        MessagesListBuilder.fetchNextMessages(messageRequest: messagesRequest) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let fetchedMessages):
                if fetchedMessages.count > 0 {
                    this.processMessageList(fetchedMessages, {fetchedMessages_ in
                        this.groupMessages(messages: fetchedMessages_)
                    })
                }
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    func setUpDefaultTemplate() {
        let additionalConfiguration = AdditionalConfiguration()
        additionalConfiguration.textFormatter = self.textFormatters
        additionalConfiguration.messageBubbleStyle = messageBubbleStyle
        additionalConfiguration.actionBubbleStyle = actionBubbleStyle
        additionalConfiguration.callActionBubbleStyle = callActionBubbleStyle
        
        let messageTypes =  ChatConfigurator.getDataSource().getAllMessageTemplates(additionalConfiguration: additionalConfiguration)
        messageTypes.forEach { template in
            templates["\(template.category)_\(template.type)"] = template
        }
    }
    
    func fetchPreviousMessages() {
        guard let messagesRequest = messagesRequest else { return }
        if isAllMessagesFetchedInPrevious == true { return }
        isUIUpdating = true
        hasFetchedMessagesBefore = true
        MessagesListBuilder.fetchPreviousMessages(messageRequest: messagesRequest) { [weak self] result in
            guard let this = self else { return }
            this.isUIUpdating = false
            switch result {
            case .success(let fetchedMessages):
                if fetchedMessages.isEmpty {
                    this.isAllMessagesFetchedInPrevious = true
                    this.appendMessagesAtTop?(0, 0)
                }
                this.processMessageList(fetchedMessages, {fetchedMessages_ in
                    this.groupMessages(messages: fetchedMessages_)
                })
                self?.sendActiveChatChangeEvent()
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    func fetchMissedMessages() {
        if let id = messages.first?.messages.first?.id {
            if let user = self.user, let _ = user.uid {
                messageNextRequestBuilder = messagesRequestBuilder.set(messageID: id).build()
            } else if let _ = self.group {
                messageNextRequestBuilder = messagesRequestBuilder.set(messageID: id).build()
            }
            fetchNextMessagesFromLastMessage()
        }
    }
    
    func fetchUnreadMessageCount() {
        if let uid = user?.uid {
            CometChat.getUnreadMessageCountForUser(uid) { [weak self] countDic in
                guard let this = self else { return }
                this.unReadMessageCount = countDic[uid] as? Int
            } onError: { [weak self] error in
                guard let this = self, let error = error else { return }
                this.failure?(error)
            }
            return
        }
        
        if let guid = group?.guid {
            CometChat.getUnreadMessageCountForGroup(guid) { [weak self] countDic in
                guard let this = self else { return }
                this.unReadMessageCount = countDic[guid] as? Int
            } onError: { [weak self] error in
                guard let this = self, let error = error else { return }
                this.failure?(error)
            }
            return
        }
    }
    
    func fetchNextMessagesFromLastMessage() {
            MessagesListBuilder.fetchNextMessages(messageRequest: messageNextRequestBuilder) { [weak self] result in
                guard let this = self else { return }
                switch result {
                case .success(let fetchedMessages):
                    if fetchedMessages.count > 0 {
                        this.processMessageList(fetchedMessages, { fetchedMessages_ in
                            
                            var missedMessagesWithoutActions = [BaseMessage]()
                            for message in fetchedMessages_ {
                                if message as? ActionMessage == nil {
                                    missedMessagesWithoutActions.append(message)
                                }
                            }
                            
                            this.groupMessages(messages: missedMessagesWithoutActions, atBottom: true)
                            if this.messages.first?.messages.first?.id != fetchedMessages.last?.id {
                                this.fetchNextMessagesFromLastMessage()
                            }
                        })
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
                                id["parentMessageId"] = this.parentMessage?.id
                            }
                            if let unReadMessageCount = this.unReadMessageCount {
                                id["unReadMessageCount"] = unReadMessageCount
                            }
                            CometChatUIEvents.ccActiveChatChanged(id: id, lastMessage: this.messages.last?.messages.last, user: this.user, group: this.group)
                        }
                    }
                case .failure(let error):
                    this.failure?(error)
                }
            }
    }
    
    func updateUserAndGroup() {
        if let user = user {
            CometChat.getUser(UID: user.uid ?? "") { [weak self] user in
                guard let this = self else { return }
                this.user = user
            } onError: { _ in   }
        } else if let group = group {
            CometChat.getGroup(GUID: group.guid) { [weak self] group in
                guard let this = self else { return }
                this.group = group
            } onError: { _ in   }
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
    
    private func groupMessages(messages: [BaseMessage], atBottom: Bool = false) {
        
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
            var messages = messages
            messages.reverse()
            if let index = self.messages.firstIndex(where: {$0.date == date}) {
                if atBottom == false {
                    self.messages[index].messages.append(contentsOf: messages)
                } else {
                    self.messages[index].messages.insert(contentsOf: messages, at: 0)
                }
            } else {
                self.messages.append((date: date, messages: messages))
            }
        }
        self.messages = self.messages.sorted(by: { $0.date.compare($1.date) == .orderedDescending})
        
        self.reload?()

    }
        
    private func groupActionMessages(messages: [BaseMessage], withRefresh: Bool) {
        let groupedMessages = Dictionary(grouping: messages) { (element) -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(element.sentAt))
            return date.reduceToMonthDayYear()
        }
        for baseMessage in messages {
            if let actionMessage = baseMessage as? ActionMessage,
               let actionOnMessage = actionMessage.actionOn as? BaseMessage {
                let _ = groupedMessages.map { (date: Date, messages: [BaseMessage]) in
                    if let index = self.messages.firstIndex(where: {$0.date == date}) {
                        if let index_ = self.messages[index].messages.firstIndex(where: {$0.id == actionOnMessage.id}) {
                            self.messages[index].messages[index_] = actionOnMessage
                        }
                    }
                }
            }
        }
        self.reload?()
    }
    
    private func processMessageList(_ messageList:[BaseMessage], _ messages: @escaping ([BaseMessage]) -> ()) {
        var messagesList = [BaseMessage]()
        for message in messageList {
            if let message_ = message as? InteractiveMessage, message_.messageCategory == .interactive {
                if message_.type == MessageTypeConstants.form {
                    let formMessage = FormMessage.toFormMessage(message_)
                    messagesList.append(formMessage)
                } else if message_.type == MessageTypeConstants.card {
                    let cardMessage = CardMessage.toCardMessage(message_)
                    messagesList.append(cardMessage)
                } else if message_.type == MessageTypeConstants.scheduler {
                    let schedulerMessage = SchedulerMessage.toSchedulerMessage(message_)
                    messagesList.append(schedulerMessage)
                } else {
                    let customMessage = CustomInteractiveMessage.toCustomInteractiveMessage(message_)
                    messagesList.append(customMessage)
                }
                
            } else {
                messagesList.append(message)
            }
        }
        messages(messagesList)
    }
    
    // MARK:- connect message listener
    public func connect() {
        CometChatUIEvents.addListener("message-list-event-listener\(currentRandomDate)", self as CometChatUIEventListener)
        CometChat.addConnectionListener("messages-connection-sdk-listener\(currentRandomDate)", self)
        CometChat.addCallListener("message-list-call-sdk-listner-\(currentRandomDate)", self)
        CometChatCallEvents.addListener("message-list-call-event-listner-\(currentRandomDate)", self)
        CometChatMessageEvents.addListener("event-listener-\(currentRandomDate)", self)
        CometChat.addGroupListener("message-list-groups-sdk-listner-\(currentRandomDate)", self)
        CometChatGroupEvents.addListener("message-list-groups-events-listener-\(currentRandomDate)", self)
    }
    
    // MARK:- disconnect message listener
    public func disconnect() {
        CometChatUIEvents.removeListener("message-list-event-listener\(currentRandomDate)")
        CometChat.removeConnectionListener("messages-connection-sdk-listener\(currentRandomDate)")
        CometChat.removeCallListener("message-list-call-sdk-listner-\(currentRandomDate)")
        CometChatMessageEvents.removeListener("event-listener-\(currentRandomDate)")
        CometChatCallEvents.removeListener("message-list-call-event-listner-\(currentRandomDate)")
        CometChat.removeGroupListener("message-list-groups-sdk-listner-\(currentRandomDate)")
        CometChatGroupEvents.removeListener("message-list-groups-events-listener-\(currentRandomDate)")
    }
    
    func checkThreadedMessageBelongsToThisConversation(message: BaseMessage) -> Bool {
        if (parentMessage == nil && message.parentMessageId == 0) || parentMessage?.id == message.parentMessageId {
            return true
        } else {
            return false
        }
    }
    
    func ifThreadedMessageUpdateCount(message: BaseMessage) {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            if message.parentMessageId > 0 && this.parentMessage == nil {
                for (sectionIndex, messageData) in this.messages.enumerated() {
                    let (date, messages) = messageData
                    for (rowIndex, baseMessage) in messages.enumerated() {
                        if baseMessage.id == message.parentMessageId {
                            baseMessage.replyCount = (baseMessage.replyCount + 1)
                            this.updateAtIndex?(sectionIndex, rowIndex, baseMessage)
                            return
                        }
                    }
                }
            }
        }
    }
    
    func isReactionOfThisList(receipt: ReactionEvent) -> Bool {
        if let parentMessage = parentMessage, receipt.parentMessageId != 0 {
            if (receipt.parentMessageId == parentMessage.id) {
                return true
            } else {
                return false
            }
        } else {
            if let user = user {
                if (receipt.receiverType == CometChat.ReceiverType.user && (receipt.receiverId == user.uid || receipt.reaction?.reactedBy?.uid == user.uid)) {
                    return true
                }
            } else if let group = group {
                if (receipt.receiverType == CometChat.ReceiverType.group && (receipt.receiverId == group.guid)) {
                    return true
                }
            }
        }
        return false
    }
    
    func updateReaction(reactionEvent: ReactionEvent, updateType: CometChat.ReactionAction) {
        guard let reaction = reactionEvent.reaction else { return }
        if isReactionOfThisList(receipt: reactionEvent) {
            for (index, (_, message)) in messages.enumerated() {
                if let messageIndex = message.firstIndex(where: { $0.id == reaction.messageId }) {
                    let reactedMessage = message[messageIndex]
                    let updatedMessage = CometChat.updateMessageWithReactionInfo(baseMessage: reactedMessage, messageReaction: reaction, action: updateType)
                    self.messages[index].messages[messageIndex] = updatedMessage
                    self.updateAtIndex?(index, messageIndex, updatedMessage)
                    return
                }
            }
        }
    }
    
    func getTemplate(for message: BaseMessage) -> CometChatMessageTemplate? {
        return templates["\(MessageUtils.getDefaultMessageCategories(message: message))_\(MessageUtils.getDefaultMessageTypes(message: message))"]
    }
    
    func isMessageForThisUser(message: BaseMessage) -> Bool {
        switch message.receiverType {
        case .user:
            if (CometChat.getLoggedInUser()?.uid == message.sender?.uid && message.receiverUid == self.user?.uid)  || (CometChat.getLoggedInUser()?.uid != message.sender?.uid && message.sender?.uid == self.user?.uid) {
                return true
            } else {
                return false
            }
        case .group:
            if message.receiverUid == self.group?.guid {
                return true
            } else {
                return false
            }
        @unknown default:
            return false
        }
    }
}

extension MessageListViewModel {
    
    @discardableResult
    public func add(message: BaseMessage) -> Self {
        
        guard let loggedInUser = CometChat.getLoggedInUser() else { return self }
        if getTemplate(for: message) == nil { return self } ///Checking if template exists
        
        markAsRead(message: message)
        markAsDelivered(message: message)
        
        
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            
            if (message.receiverType == .user) && ((CometChat.getLoggedInUser()?.uid == message.sender?.uid && message.receiverUid == this.user?.uid)  || (CometChat.getLoggedInUser()?.uid != message.sender?.uid && message.sender?.uid == this.user?.uid))
                ||
               (message.receiverType == .group) && message.receiverUid == this.group?.guid {
                
                if let lastMessage = this.messages.first?.messages.last, String().compareDates(newTimeInterval: Double(message.muid) ?? 0.0, currentTimeInterval: Double(lastMessage.muid) ?? 0.0)  || Calendar.current.isDateInToday(Date(timeIntervalSince1970: TimeInterval(lastMessage.sentAt))) {
                    this.messages[0].messages.insert(message, at: 0)
                    this.appendAtIndex?(0, 0, message, false)
                } else {
                    this.messages.insert((date: Date(timeIntervalSince1970: TimeInterval( Double(message.muid) ?? 0.0)), messages: [message]), at: 0)
                    this.appendAtIndex?(0, 0, message, true)
                }
                
            }
        }
        return self
    }
    
    @discardableResult
    public func update(message: BaseMessage) -> Self {
       processMessageList([message]) { [weak self] messages in
           guard let this = self else { return }
            guard let message = messages.first else { return }
            if let section = this.messages.firstIndex(where: { (date: Date, messages: [BaseMessage]) in
                if let muid = Double(message.muid), muid != 0.0 {
                    if date.timeIntervalSince1970 == 0.0 {
                        return true
                    } else {
                        return String().compareDates(newTimeInterval:  muid, currentTimeInterval:  date.timeIntervalSince1970) ? true : false
                    }
                   
                } else {
                    return String().compareDates(newTimeInterval: Double(message.sentAt), currentTimeInterval: date.timeIntervalSince1970) ? true : false
                }
            }), let row = this.messages[section].messages.firstIndex(where: {
                if message.muid != "" {
                    return $0.muid == message.muid
                    
                } else {
                    return $0.id == message.id
                }
            }) {
                this.messages[section].messages[row] = message
                this.updateAtIndex?(section, row, message)
            }
        }
        return self
    }
    
    @discardableResult
    public func update(receipt: MessageReceipt) -> Self {
        if !disableReceipt {
            let loggedInUid = CometChat.getLoggedInUser()?.uid
            
            //Checking For User
            if receipt.receiverType == .user && receipt.sender?.uid == self.user?.uid {
                for (section, currentMessages) in messages.enumerated() {
                    for (row, message) in currentMessages.messages.enumerated() {
                        if message.senderUid == loggedInUid {
                            if receipt.receiptType == .read && message.readAt == 0.0 {
                                message.readAt = Double(receipt.timeStamp)
                                DispatchQueue.main.async { [weak self] in
                                    guard let this = self else { return }
                                    this.messages[section].messages[row] = message
                                    this.updateAtIndex?(section, row, message)
                                }
                            } else if receipt.receiptType == .delivered && message.deliveredAt == 0.0 {
                                message.deliveredAt = Double(receipt.timeStamp)
                                DispatchQueue.main.async { [weak self] in
                                    guard let this = self else { return }
                                    this.messages[section].messages[row] = message
                                    this.updateAtIndex?(section, row, message)
                                }
                            } else if String(message.id) == receipt.messageId {
                                updateAtIndex?(section, row, message) ///updating last message because it was conflicting with conversation's update
                            }
                        }
                    }
                }
            } else if receipt.receiverType == .group && receipt.receiverId == group?.guid {
                
                //Checking For Group
                for (section, currentMessages) in messages.enumerated() {
                    for (row, message) in currentMessages.messages.enumerated() {
                        
                        if receipt.receiptType == .readByAll && message.readAt == 0.0 {
                            message.readAt = Double(receipt.timeStamp)
                            DispatchQueue.main.async { [weak self] in
                                guard let this = self else { return }
                                this.messages[section].messages[row] = message
                                this.updateAtIndex?(section, row, message)
                            }
                        } else if receipt.receiptType == .deliveredToAll && message.deliveredAt == 0.0 {
                            message.deliveredAt = Double(receipt.timeStamp)
                            DispatchQueue.main.async { [weak self] in
                                guard let this = self else { return }
                                this.messages[section].messages[row] = message
                                this.updateAtIndex?(section, row, message)
                            }
                        } else if String(message.id) == receipt.messageId {
                            updateAtIndex?(section, row, message) ///updating last message because it was conflicting with conversation's update
                        }
                        
                    }
                }
            }
        }
        return self
    }
    
    func getIndexPath(for message: BaseMessage) -> IndexPath? {
        if let section = messages.firstIndex(where: { (date: Date, messages: [BaseMessage]) in
            if let muid = Double(message.muid), muid != 0.0 {
                if date.timeIntervalSince1970 == 0.0 {
                    return true
                } else {
                    return String().compareDates(newTimeInterval:  muid, currentTimeInterval:  date.timeIntervalSince1970) ? true : false
                }
                
            } else {
                return String().compareDates(newTimeInterval: Double(message.sentAt), currentTimeInterval: date.timeIntervalSince1970) ? true : false
            }
        }), let row = messages[section].messages.firstIndex(where: {
            if message.muid != "" {
                return $0.muid == message.muid
                
            } else {
                return $0.id == message.id
            }
        }) {
            return IndexPath(row: row, section: section)
        }
        return nil
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
            CometChatMessageEvents.onMessageDeleted(message: message)
        } onError: { [weak self] error in
            guard let this = self else { return }
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
        if !disableReceipt && message.readAt == 0 {
            if (
                (message.receiverType == .group && message.receiverUid == group?.guid && (message.sender?.uid != CometChat.getLoggedInUser()?.uid)) ||
                (message.receiverType == .user && (message.sender?.uid != CometChat.getLoggedInUser()?.uid))
            ) {
                CometChat.markAsRead(baseMessage: message)
                message.readAt = Double(NSDate().timeIntervalSince1970)
                CometChatMessageEvents.ccMessageRead(message: message)
            }
        }
        return self
    }
    
    @discardableResult
    public func markAsDelivered(message: BaseMessage) -> Self {
        if !disableReceipt && message.deliveredAt == 0 {
            CometChat.markAsDelivered(baseMessage: message)
        }
        return self
    }
    
    @discardableResult
    public func disable(receipt: Bool) -> Self {
        self.disableReceipt = receipt
        return self
    }
    
    @discardableResult
    public func disable(reactions: Bool) -> Self {
        self.disableReaction = reactions
        return self
    }
}

extension MessageListViewModel: CometChatMessageEventListener {
    
    public func onFormMessageReceived(message: FormMessage) {
        
        if self.getTemplate(for: message) == nil { return }
        ifThreadedMessageUpdateCount(message: message)
        if checkThreadedMessageBelongsToThisConversation(message: message) {
            self.newMessageReceived?(message)
            self.add(message: message)
        }
    }
    
    public func onSchedulerMessageReceived(message: SchedulerMessage) {
        
        if self.getTemplate(for: message) == nil { return }
        ifThreadedMessageUpdateCount(message: message)
        if checkThreadedMessageBelongsToThisConversation(message: message) {
            self.newMessageReceived?(message)
            self.add(message: message)
        }
    }
    
    public func onCustomInteractiveMessageReceived(message: CustomInteractiveMessage) {
        
        if self.getTemplate(for: message) == nil { return }
        ifThreadedMessageUpdateCount(message: message)
        if checkThreadedMessageBelongsToThisConversation(message: message) {
            self.newMessageReceived?(message)
            self.add(message: message)
        }
    }
    
    public func onCardMessageReceived(message: CardMessage) {
        
        if self.getTemplate(for: message) == nil { return }
        ifThreadedMessageUpdateCount(message: message)
        if checkThreadedMessageBelongsToThisConversation(message: message) {
            self.newMessageReceived?(message)
            self.add(message: message)
        }
    }
    
    
    public func onTextMessageReceived(textMessage: TextMessage) {
        
        if self.getTemplate(for: textMessage) == nil { return }
        ifThreadedMessageUpdateCount(message: textMessage)
        if checkThreadedMessageBelongsToThisConversation(message: textMessage) {
            self.newMessageReceived?(textMessage)
            self.add(message: textMessage)
        }
    }
    
    public func onMediaMessageReceived(mediaMessage: MediaMessage) {
        
        if self.getTemplate(for: mediaMessage) == nil { return }
        ifThreadedMessageUpdateCount(message: mediaMessage)
        if checkThreadedMessageBelongsToThisConversation(message: mediaMessage) {
            self.newMessageReceived?(mediaMessage)
            self.add(message: mediaMessage)
        }
    }
    
    public func onCustomMessageReceived(customMessage: CustomMessage) {
                
        if self.getTemplate(for: customMessage) == nil { return }
        ifThreadedMessageUpdateCount(message: customMessage)
        if checkThreadedMessageBelongsToThisConversation(message: customMessage) {
            self.newMessageReceived?(customMessage)
            self.add(message: customMessage)
        }
    }
    
    public func onMessagesDelivered(receipt: MessageReceipt) {
        update(receipt: receipt)
    }
    
    public func onMessagesRead(receipt: MessageReceipt) {
        update(receipt: receipt)
    }
    
    public func onMessagesReadByAll(receipt: MessageReceipt) {
        update(receipt: receipt)
    }
    
    public func onMessagesDeliveredToAll(receipt: MessageReceipt) {
        update(receipt: receipt)
    }
    
    public func ccMessageRead(message: CometChatSDK.BaseMessage) {
        self.update(message: message)
    }
    
    public func ccMessageDeleted(message: BaseMessage) {
        if checkThreadedMessageBelongsToThisConversation(message: message) {
            if hideDeletedMessages {
                remove(message: message)
            } else {
                update(message: message)
            }
        }
    }
    
    public func onMessageDeleted(message: BaseMessage) {
        if checkThreadedMessageBelongsToThisConversation(message: message) {
            if hideDeletedMessages {
                remove(message: message)
            } else {
                update(message: message)
            }
        }
    }
            
    public func ccMessageSent(message: CometChatSDK.BaseMessage, status: MessageStatus) {
        
        if status == .success { ifThreadedMessageUpdateCount(message: message) }
        if checkThreadedMessageBelongsToThisConversation(message: message) {
            switch status {
            case .inProgress:
                self.add(message: message)
            case .success:
                self.update(message: message)
            case .error:
                self.update(message: message)
            }
        }
    }
    
    public func ccMessageEdited(message: BaseMessage, status: MessageStatus) {
        if checkThreadedMessageBelongsToThisConversation(message: message) {
            if status == .success {
                self.update(message: message)
            }
        }
    }
    
    public func onMessageEdited(message: BaseMessage) {
        if checkThreadedMessageBelongsToThisConversation(message: message) {
            self.update(message: message)
        }
    }

    public func onMessageReactionAdded(reactionEvent: ReactionEvent) {
        if !disableReaction {
            updateReaction(reactionEvent: reactionEvent, updateType: .REACTION_ADDED)
        }
    }
    
    public func onMessageReactionRemoved(reactionEvent: ReactionEvent) {
        if !disableReaction {
            updateReaction(reactionEvent: reactionEvent, updateType: .REACTION_REMOVED)
        }
    }
    
}

extension MessageListViewModel: CometChatGroupDelegate {
    
    public func onGroupMemberJoined(action: CometChatSDK.ActionMessage, joinedUser: CometChatSDK.User, joinedGroup: CometChatSDK.Group) {
        self.newMessageReceived?(action)
        self.add(message: action)
    }
    
    public func onGroupMemberLeft(action: CometChatSDK.ActionMessage, leftUser: CometChatSDK.User, leftGroup: CometChatSDK.Group) {
        /*
         close detail
         */
        self.newMessageReceived?(action)
        self.add(message: action)
    }
    
    public func onGroupMemberKicked(action: CometChatSDK.ActionMessage, kickedUser: CometChatSDK.User, kickedBy: CometChatSDK.User, kickedFrom: CometChatSDK.Group) {
        /*
         // append to list.
         */
        self.newMessageReceived?(action)
        self.add(message: action)
        
    }
    
    public func onGroupMemberBanned(action: CometChatSDK.ActionMessage, bannedUser: CometChatSDK.User, bannedBy: CometChatSDK.User, bannedFrom: CometChatSDK.Group) {
        /*
         Append to the list.
         */
        self.newMessageReceived?(action)
        self.add(message: action)
    }
    
    public func onGroupMemberUnbanned(action: CometChatSDK.ActionMessage, unbannedUser: CometChatSDK.User, unbannedBy: CometChatSDK.User, unbannedFrom: CometChatSDK.Group) {
        /*
         Do Nothing.
         */
        self.newMessageReceived?(action)
        self.add(message: action)
    }
    
    public func onGroupMemberScopeChanged(action: CometChatSDK.ActionMessage, scopeChangeduser: CometChatSDK.User, scopeChangedBy: CometChatSDK.User, scopeChangedTo: String, scopeChangedFrom: String, group: CometChatSDK.Group) {
        self.newMessageReceived?(action)
        self.add(message: action)
    }
    
    public func onMemberAddedToGroup(action: CometChatSDK.ActionMessage, addedBy: CometChatSDK.User, addedUser: CometChatSDK.User, addedTo: CometChatSDK.Group) {
        self.newMessageReceived?(action)
        self.add(message: action)
    }
}



extension MessageListViewModel: CometChatGroupEventListener { 
    
    public func ccGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        self.newMessageReceived?(action)
        self.add(message: action)
    }
    
    public func ccGroupMemberAdded(messages: [ActionMessage], usersAdded: [User], groupAddedIn: Group, addedBy: User) {
        if groupAddedIn.guid == group?.guid {
            messages.forEach { messages in
                self.newMessageReceived?(messages)
                self.add(message: messages)
            }
        }
    }
    
    public func ccGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        self.newMessageReceived?(action)
        self.add(message: action)
    }
    
    public func ccGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        self.newMessageReceived?(action)
        self.add(message: action)
    }
    
    public func ccGroupMemberScopeChanged(action: ActionMessage, updatedUser: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        if group.guid == self.group?.guid {
            if (CometChat.getLoggedInUser()?.uid == updatedUser.uid) {
                if let newScope = CometChat.GroupMemberScopeType.from(string: scopeChangedFrom) {
                    self.group?.scope = newScope
                }
            }
            self.newMessageReceived?(action)
            self.add(message: action)
        }
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
    
    public func onCallEndedMessageReceived(endedCall: Call?, error: CometChatException?) {
        if let endedCall = endedCall {
            self.add(message: endedCall)
        }
    }
    
}

extension MessageListViewModel:  CometChatCallEventListener {
    
    public func ccOutgoingCall(call: Call) {
        self.add(message: call)
    }

    public func ccCallAccepted(call: Call) {
        self.add(message: call)
    }

    public func ccCallRejected(call: Call) {
        self.add(message: call)
    }

    public func ccCallEnded(call: Call) {
        if let _ =   (call.callReceiver as? User) {
            self.add(message: call)
        }
    }
    
}


extension MessageListViewModel: CometChatUIEventListener {
    
    public func showPanel(id: [String : Any]?, alignment: UIAlignment, view: UIView?) {
        if !isForThisView(id: id) { return }
        if let view = view {
            switch alignment {
            case .messageListTop:
                setHeaderView?(view)
            case .messageListBottom:
                setFooterView?(view)
            case .composerTop, .composerBottom: break
            }
        }
    }
    
    public func hidePanel(id: [String : Any]?, alignment: UIAlignment) {
        if !isForThisView(id: id) { return }
        switch alignment {
        case .messageListTop:
            hideHeaderView?(true)
        case .messageListBottom:
            hideFooterView?(true)
        case .composerTop, .composerBottom: break
        }
    }
    
    fileprivate func isForThisView(id: [String:Any]?) -> Bool {
        guard let id = id , !id.isEmpty else { return false }
        if (id["uid"] != nil && id["uid"] as? String ==
            self.user?.uid) || (id["guid"] != nil && id["guid"] as? String ==
                                      self.group?.guid) {
            
            if (id["parentMessageId"] != nil &&
                id["parentMessageId"] as? Int == self.parentMessage?.id) {
                return true
            }else if(id["parentMessageId"] == nil && self.parentMessage == nil ){
                return true;
            }
        }
        return false
    }
}

//MARK: Connection Listener
extension MessageListViewModel: CometChatConnectionDelegate {
    public func connected() {
        updateUserAndGroup()
        fetchActionMessages({
            success in
            if success {
                self.fetchMissedMessages()
            }
        })
    }
    
    public func disconnected() {
        
    }
    
    public func connecting() {
        
    }
}
