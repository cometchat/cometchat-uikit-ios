//
//  AIAssistanceChatHistoryViewModel.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 18/09/25.
//

import Foundation
import CometChatSDK

protocol AIAssistanceChatHistoryViewModelProtocol {
    var user: CometChatSDK.User? { get set }
    var group: CometChatSDK.Group? { get set }
    var parentMessage: CometChatSDK.BaseMessage? { get set }
    var messagesRequestBuilder: CometChatSDK.MessagesRequest.MessageRequestBuilder { get set }
    var messages: [(date: Date, messages: [BaseMessage])] { get set }
    var reload: (() -> Void)? { get set }
    var newMessageReceived: ((_ message: BaseMessage) -> Void)? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }

    func fetchPreviousMessages()
}

open class AIAssistanceChatHistoryViewModel: NSObject, AIAssistanceChatHistoryViewModelProtocol {
    
    var group: CometChatSDK.Group?
    var user: CometChatSDK.User?
    var parentMessage: CometChatSDK.BaseMessage?
    var messages: [(date: Date, messages: [CometChatSDK.BaseMessage])] = []
    var messagesRequestBuilder: CometChatSDK.MessagesRequest.MessageRequestBuilder
    var messagesRequest: MessagesRequest?

    var isFetching: Bool = false                 // Prevent duplicate parallel fetches
    var isAllMessagesFetchedInPrevious: Bool = false  // Stops fetching once API says no more
    
    var reload: (() -> Void)?
    var newMessageReceived: ((_ message: BaseMessage) -> Void)?
    var appendAtIndex: ((_ section: Int, _ row: Int, _ baseMessage: BaseMessage, _ isNewSectionAdded: Bool) -> Void)?
    var updateAtIndex: ((Int, Int, BaseMessage) -> Void)?
    var deleteAtIndex: ((Int, Int, BaseMessage) -> Void)?
    var failure: ((CometChatSDK.CometChatException) -> Void)?
    
    // MARK: - Init
    public override init() {
        messagesRequestBuilder = MessagesRequest.MessageRequestBuilder()
        super.init()
    }
    
    // MARK: - Setup
    func set(user: User, messagesRequestBuilder: CometChatSDK.MessagesRequest.MessageRequestBuilder?, parentMessage: BaseMessage? = nil) {
        self.user = user
        self.parentMessage = parentMessage
        self.messagesRequestBuilder = messagesRequestBuilder?
            .set(uid: user.uid ?? "")
            .setParentMessageId(parentMessageId: parentMessage?.id ?? 0)
        ?? MessagesRequest.MessageRequestBuilder()
            .set(uid: user.uid ?? "")
            .hideReplies(hide: true)
            .setParentMessageId(parentMessageId: parentMessage?.id ?? 0)
            .set(types: ChatConfigurator.getDataSource().getAllMessageTypes() ?? [])
        
        self.messagesRequest = self.messagesRequestBuilder.build()
        fetchUnreadMessageCount()
    }
    
    func set(group: Group, messagesRequestBuilder: CometChatSDK.MessagesRequest.MessageRequestBuilder?, parentMessage: BaseMessage? = nil) {
        self.group = group
        self.parentMessage = parentMessage
        self.messagesRequestBuilder = messagesRequestBuilder?.set(guid: group.guid).setParentMessageId(parentMessageId: parentMessage?.id ?? 0) ?? MessagesRequest.MessageRequestBuilder()
            .set(guid: group.guid)
            .hideReplies(hide: true)
            .setParentMessageId(parentMessageId: parentMessage?.id ?? 0)
            .set(types: ChatConfigurator.getDataSource().getAllMessageTypes() ?? [])
        self.messagesRequest = self.messagesRequestBuilder.build()
        self.fetchUnreadMessageCount()
    }
    
    func set(messagesRequestBuilder: CometChatSDK.MessagesRequest.MessageRequestBuilder) {
        if let user = user {
            self.messagesRequestBuilder = messagesRequestBuilder
                .set(uid: user.uid ?? "")
                .setParentMessageId(parentMessageId: parentMessage?.id ?? 0)
            self.messagesRequest = self.messagesRequestBuilder.build()
        }
    }
    
    // MARK: - Pagination
    func fetchPreviousMessages() {
        guard let messagesRequest = messagesRequest else { return }
        guard !isFetching else { return }
        guard !isAllMessagesFetchedInPrevious else { return }
        
        isFetching = true
        
        
        MessagesListBuilder.fetchPreviousMessages(messageRequest: messagesRequest) { [weak self] result in
            guard let self = self else { return }
            self.isFetching = false
            
            switch result {
            case .success(let fetchedMessages):
                if fetchedMessages.isEmpty {
                    self.isAllMessagesFetchedInPrevious = true
                } else {
                    self.processMessageList(fetchedMessages) { processed in
                        // Check if we actually got new messages
                        if processed.count > 0 {
                            self.groupMessages(messages: processed, atBottom: true)
                        } else {
                            self.isAllMessagesFetchedInPrevious = true
                        }
                    }
                }
                reload?()
            case .failure(let error):
                self.failure?(error)
                self.isFetching = false
            }
        }
    }
    
    // MARK: - Group Messages
    private func groupMessages(messages: [BaseMessage], atBottom: Bool = false) {
        guard !messages.isEmpty else { return }
        
        // Sort messages by sentAt in descending order (newest first)
        let sortedMessages = messages.sorted { $0.sentAt > $1.sentAt }
        
        let groupedMessages = Dictionary(grouping: sortedMessages) { (element) -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(element.sentAt))
            return date.reduceToMonthDayYear()
        }
        
        // Create temporary array
        var tempMessages = self.messages
        
        for (date, messagesForDate) in groupedMessages {
            if let existingIndex = tempMessages.firstIndex(where: { $0.date == date }) {
                if atBottom {
                    // For pagination, append to the beginning of the section
                    tempMessages[existingIndex].messages = messagesForDate + tempMessages[existingIndex].messages
                } else {
                    // For new messages, append to the end
                    tempMessages[existingIndex].messages.append(contentsOf: messagesForDate)
                }
            } else {
                // New date section
                tempMessages.append((date: date, messages: messagesForDate))
            }
        }
        
        // Sort sections by date (newest first)
        tempMessages.sort(by: { $0.date.compare($1.date) == .orderedDescending })
        
        // Sort messages within each section by sentAt (newest first)
        for i in 0..<tempMessages.count {
            tempMessages[i].messages.sort { $0.sentAt > $1.sentAt }
        }
        
        self.messages = tempMessages
        self.reload?()
    }
    
    // MARK: - Process Messages
    private func processMessageList(_ messageList: [BaseMessage], _ completion: @escaping ([BaseMessage]) -> Void) {
        var messagesList = [BaseMessage]()

        for message in messageList {

            if let textMessage = message as? TextMessage {
                // Only add TextMessages with non-empty text and muid
                if !textMessage.text.isEmpty, !textMessage.muid.isEmpty {
                    messagesList.append(textMessage)
                }
            }
            else if let interactiveMessage = message as? InteractiveMessage,
                    interactiveMessage.messageCategory == .interactive {

                let processedMessage: BaseMessage
                switch interactiveMessage.type {
                case MessageTypeConstants.form:
                    processedMessage = FormMessage.toFormMessage(interactiveMessage)
                case MessageTypeConstants.card:
                    processedMessage = CardMessage.toCardMessage(interactiveMessage)
                case MessageTypeConstants.scheduler:
                    processedMessage = SchedulerMessage.toSchedulerMessage(interactiveMessage)
                default:
                    processedMessage = CustomInteractiveMessage.toCustomInteractiveMessage(interactiveMessage)
                }
                messagesList.append(processedMessage)
            }
            else {
                // For any other BaseMessage type: only append if not TextMessage with empty text/muid
                if let textMessage = message as? TextMessage {
                    if !textMessage.text.isEmpty, !textMessage.muid.isEmpty {
                        messagesList.append(textMessage)
                    }
                } else {
                    messagesList.append(message)
                }
            }
        }

        completion(messagesList)
    }
    
    // MARK: - Unread Count
    func fetchUnreadMessageCount() {
        // implement like in Flutter side, if needed
    }
    
    @discardableResult
    public func delete(message: BaseMessage) -> Self {
        guard message.id > 0 else { return self }

        CometChat.deleteMessage(message.id) { [weak self] deletedMessage in
            guard let self = self else { return }

            CometChatMessageEvents.onMessageDeleted(message: deletedMessage)

            // Find the section and row
            guard let section = self.messages.firstIndex(where: { (date, msgs) in
                String().compareDates(newTimeInterval: date.timeIntervalSince1970,
                                      currentTimeInterval: Double(deletedMessage.sentAt))
            }),
            let row = self.messages[section].messages.firstIndex(where: { $0.id == deletedMessage.id || $0.muid == deletedMessage.muid }) else {
                return
            }

            // Call deleteAtIndex - it will handle both data and UI updates
            self.deleteAtIndex?(section, row, deletedMessage)

        } onError: { [weak self] error in
            self?.failure?(error)
        }

        return self
    }

}

