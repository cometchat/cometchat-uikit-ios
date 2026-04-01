//
//  CompactMessageComposerViewModel.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 29/01/26.
//

import Foundation
import CometChatSDK

/// Protocol defining the ViewModel interface
protocol CompactMessageComposerViewModelProtocol {
    var user: User? { get set }
    var group: Group? { get set }
    var message: BaseMessage? { get set }
    var composerState: ComposerState { get set }
    var parentMessageId: Int? { get set }
    var reset: ((Bool) -> ())? { get set }
    var failure: ((CometChatException) -> Void)? { get set }
}

/// ViewModel for managing single line composer state and business logic
open class CompactMessageComposerViewModel: NSObject, CompactMessageComposerViewModelProtocol {
    
    // MARK: - Properties
    
    var user: User?
    var group: Group?
    var message: BaseMessage?
    var composerState: ComposerState = .draft
    var parentMessageId: Int?
    var typingIndicator: TypingIndicator?
    var quotedMessageId: Int?
    var quotedMessage: BaseMessage?
    
    // MARK: - Callbacks
    
    var reset: ((Bool) -> ())?
    var failure: ((CometChatException) -> Void)?
    var isSoundForMessageEnabled: (() -> ())?
    var onMessageEdit: ((_ message: BaseMessage) -> ())?
    var showReplyView: ((_ message: BaseMessage) -> ())?
    var hideReplyView: (() -> ())?
    
    // MARK: - Text Formatters
    
    var textFormatterMap: [Character: CometChatTextFormatter] = {
        var map = [Character: CometChatTextFormatter]()
        for formatter in ChatConfigurator.getDataSource().getTextFormatters() {
            map[formatter.getTrackingCharacter()] = formatter
        }
        return map
    }()
    
    var textFormatter: [CometChatTextFormatter] {
        get {
            var formatters = [CometChatTextFormatter]()
            textFormatterMap.forEach { formatters.append($1) }
            return formatters
        }
        set {
            var map = [Character: CometChatTextFormatter]()
            for formatter in newValue {
                if let user = user { formatter.set(user: user) }
                if let group = group { formatter.set(group: group) }
                map[formatter.getTrackingCharacter()] = formatter
            }
            textFormatterMap = map
        }
    }
    
    // MARK: - Event Listener
    
    var eventID = "CompactMessageComposerViewModel-\(Date().timeIntervalSince1970)"
    
    func connect() {
        CometChatMessageEvents.addListener(eventID, self)
        CometChatUserEvents.addListener(eventID, self)
    }
    
    func disconnect() {
        CometChatMessageEvents.removeListener(eventID)
        CometChatUserEvents.removeListener(eventID)
    }
    
    // MARK: - Configuration
    
    func set(user: User) {
        self.user = user
        self.group = nil
        textFormatterMap.forEach { $1.set(user: user) }
        setTypingIndicator()
    }
    
    func set(group: Group) {
        self.group = group
        self.user = nil
        textFormatterMap.forEach { $1.set(group: group) }
        setTypingIndicator()
    }
    
    private func setTypingIndicator() {
        if let user = user {
            typingIndicator = TypingIndicator(receiverID: user.uid ?? "", receiverType: .user)
        } else if let group = group {
            typingIndicator = TypingIndicator(receiverID: group.guid, receiverType: .group)
        }
    }
    
    // MARK: - Typing Indicators
    
    func startTyping() {
        guard let indicator = typingIndicator else { return }
        CometChat.startTyping(indicator: indicator)
    }
    
    func endTyping() {
        guard let indicator = typingIndicator else { return }
        CometChat.endTyping(indicator: indicator)
    }
    
    // MARK: - Blocked Status
    
    func checkBlockedStatus() -> Bool {
        guard let user = user else { return false }
        return user.hasBlockedMe || user.blockedByMe
    }
}

// MARK: - Message Event Listener
extension CompactMessageComposerViewModel: CometChatMessageEventListener {
    
    public func ccMessageEdited(message: BaseMessage, status: MessageStatus) {
        if status == .inProgress {
            onMessageEdit?(message)
        }
    }
    
    public func ccReplyToMessage(message: BaseMessage, status: MessageStatus) {
        guard message.deletedAt <= 0 else { return }
        
        switch status {
        case .inProgress:
            showReplyView?(message)
        case .success, .error:
            quotedMessage = nil
            quotedMessageId = nil
            hideReplyView?()
        }
    }
}

// MARK: - User Event Listener
extension CompactMessageComposerViewModel: CometChatUserEventListener {
    // Implement user event methods as needed
}

// MARK: - Send Message Methods
extension CompactMessageComposerViewModel {
    
    func sendTextMessageToUser(
        message: String,
        textFormatter: [Character: [(item: SuggestionItem, range: NSRange)]]
    ) {
        reset?(true)
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty, let uid = user?.uid else { return }
        
        let textMessage = TextMessage(receiverUid: uid, text: trimmedMessage, receiverType: .user)
        configureMessage(textMessage, textFormatter: textFormatter)
        
        isSoundForMessageEnabled?()
        CometChatMessageEvents.ccMessageSent(message: textMessage, status: .inProgress)
        
        clearQuotedMessage()
        
        MessageComposerBuilder.textMessage(message: textMessage) { [weak self] result in
            self?.handleSendResult(result, originalMessage: textMessage)
        }
    }
    
    func sendTextMessageToGroup(
        message: String,
        textFormatter: [Character: [(item: SuggestionItem, range: NSRange)]]
    ) {
        reset?(true)
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty, let guid = group?.guid else { return }
        
        let textMessage = TextMessage(receiverUid: guid, text: trimmedMessage, receiverType: .group)
        configureMessage(textMessage, textFormatter: textFormatter)
        
        isSoundForMessageEnabled?()
        CometChatMessageEvents.ccMessageSent(message: textMessage, status: .inProgress)
        
        clearQuotedMessage()
        
        MessageComposerBuilder.textMessage(message: textMessage) { [weak self] result in
            self?.handleSendResult(result, originalMessage: textMessage)
        }
    }
    
    private func configureMessage(
        _ textMessage: TextMessage,
        textFormatter: [Character: [(item: SuggestionItem, range: NSRange)]]
    ) {
        textMessage.muid = "\(NSDate().timeIntervalSince1970)"
        textMessage.sentAt = Int(Date().timeIntervalSince1970)
        textMessage.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
        textMessage.sender = CometChat.getLoggedInUser()
        
        if let parentId = parentMessageId {
            textMessage.parentMessageId = parentId
        }
        if let quotedId = quotedMessageId {
            textMessage.quotedMessageId = quotedId
        }
        if let quoted = quotedMessage {
            textMessage.quotedMessage = quoted
        }
        
        // Apply text formatters
        if !textFormatter.isEmpty {
            update(message: textMessage, withSelected: textFormatter)
        }
    }
    
    private func update(message: TextMessage, withSelected textFormatter: [Character: [(item: SuggestionItem, range: NSRange)]]) {
        var textFormatterArray = [(range: NSRange, item: SuggestionItem, formatter: CometChatTextFormatter)]()
        var suggestionItemCollection = [Character: (formatter: CometChatTextFormatter, items: [SuggestionItem])]()
        
        textFormatter.forEach { (textFormatterCharacter, values) in
            values.forEach { (item, range) in
                textFormatterArray.append((range: range, item: item, formatter: textFormatterMap[textFormatterCharacter]!))
                if suggestionItemCollection[textFormatterCharacter] == nil {
                    suggestionItemCollection[textFormatterCharacter] = (formatter: textFormatterMap[textFormatterCharacter]!, items: [item])
                } else {
                    suggestionItemCollection[textFormatterCharacter]?.items.append(item)
                }
            }
        }
        
        textFormatterArray.sort(by: { $0.0.location < $1.0.location })
        var locationDifference = 0
        var messageText = message.text
        
        // Check if mention tags are already present in the text (from convertToMarkdown)
        // If so, skip the text replacement as it's already been done
        let mentionTagsAlreadyPresent = messageText.contains("<@uid:") || messageText.contains("<@all:")
        
        if !mentionTagsAlreadyPresent {
            for (range, item, _) in textFormatterArray {
                let updatedRange = NSRange(location: range.location + locationDifference, length: range.length)
                if updatedRange.lowerBound >= 0 && updatedRange.upperBound <= messageText.utf16.count && updatedRange.length <= messageText.utf16.count {
                    messageText = (messageText as NSString).replacingCharacters(in: updatedRange, with: item.underlyingText ?? "")
                    locationDifference = locationDifference + ((item.underlyingText?.count ?? 0) - range.length)
                }
            }
            message.text = messageText
        }
        
        // Always call handlePreMessageSend to add mentioned users to the message
        suggestionItemCollection.forEach { (key, arg1) in
            let (formatter, items) = arg1
            formatter.handlePreMessageSend(baseMessage: message, suggestionItemList: items)
        }
    }
    
    private func clearQuotedMessage() {
        quotedMessage = nil
        quotedMessageId = nil
    }
    
    private func handleSendResult(_ result: MessageComposerBuilderResult, originalMessage: TextMessage) {
        switch result {
        case .success(let updatedMessage):
            CometChatMessageEvents.ccMessageSent(message: updatedMessage, status: .success)
            if let textMessage = updatedMessage as? TextMessage, textMessage.quotedMessage != nil {
                CometChatMessageEvents.ccReplyToMessage(message: updatedMessage, status: .success)
            }
        case .failure(let error):
            failure?(error)
            originalMessage.metaData = ["error": true]
            CometChatMessageEvents.ccMessageSent(message: originalMessage, status: .error)
        }
    }
    
    func editTextMessage(textMessage: TextMessage, message: String?, textFormatter: [Character: [(item: SuggestionItem, range: NSRange)]]) {
        let message: String = message?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !message.isEmpty {
            textMessage.text = message
            textMessage.metaData?.removeValue(forKey: "translated-message")
            if !textFormatter.isEmpty {
                update(message: textMessage, withSelected: textFormatter)
            }
            isSoundForMessageEnabled?()
            MessageComposerBuilder.editMessage(message: textMessage) { [weak self] result in
                switch result {
                case .success(let updatedTextMessage):
                    DispatchQueue.main.async { [weak self] in
                        guard let this = self else { return }
                        this.reset?(true)
                        if let actionMessage = updatedTextMessage as? ActionMessage {
                            textMessage.editedAt = Date().timeIntervalSince1970
                            textMessage.editedBy = actionMessage.editedBy
                            CometChatMessageEvents.ccMessageEdited(message: textMessage, status: .success)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async { [weak self] in
                        guard let this = self else { return }
                        this.failure?(error)
                        this.reset?(true)
                        textMessage.metaData = ["error": true]
                        CometChatMessageEvents.ccMessageEdited(message: textMessage, status: .error)
                    }
                }
            }
        }
    }
    
    public func sendMediaMessageToUser(url: String, type: CometChat.MessageType) {
        guard let uid = self.user?.uid else { return }
        let mediaMessage = MediaMessage(receiverUid: uid, fileurl: url, messageType: type, receiverType: .user)
        mediaMessage.muid = "\(NSDate().timeIntervalSince1970)"
        mediaMessage.sentAt = Int(Date().timeIntervalSince1970)
        mediaMessage.sender = CometChat.getLoggedInUser()
        mediaMessage.metaData = ["fileURL": url]
        mediaMessage.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
        if let parentMessageId = parentMessageId {
            mediaMessage.parentMessageId = parentMessageId
        }
        
        if let quotedMessageId = quotedMessageId {
            mediaMessage.quotedMessageId = quotedMessageId
        }
        
        if let fullQuoted = quotedMessage {
            mediaMessage.quotedMessage = fullQuoted
        }
        isSoundForMessageEnabled?()
        CometChatMessageEvents.ccMessageSent(message: mediaMessage, status: .inProgress)
        hideReplyView?()
        quotedMessage = nil
        quotedMessageId = nil
        MessageComposerBuilder.mediaMessage(message: mediaMessage) { [weak self] result in
            switch result {
            case .success(let updatedMediaMessage):
                CometChatMessageEvents.ccMessageSent(message: updatedMediaMessage, status: .success)
                if updatedMediaMessage.quotedMessage != nil {
                    CometChatMessageEvents.ccReplyToMessage(message: updatedMediaMessage, status: .success)
                }
            case .failure(let error):
                self?.failure?(error)
                mediaMessage.metaData = ["error": true]
                CometChatMessageEvents.ccMessageSent(message: mediaMessage, status: .error)
            }
        }
    }
    
    public func sendMediaMessageToGroup(url: String, type: CometChat.MessageType) {
        guard let uid = self.group?.guid else { return }
        let mediaMessage = MediaMessage(receiverUid: uid, fileurl: url, messageType: type, receiverType: .group)
        if let parentMessageId = parentMessageId {
            mediaMessage.parentMessageId = parentMessageId
        }
        mediaMessage.muid = "\(NSDate().timeIntervalSince1970)"
        mediaMessage.sentAt = Int(Date().timeIntervalSince1970)
        mediaMessage.sender = CometChat.getLoggedInUser()
        mediaMessage.metaData = ["fileURL": url]
        mediaMessage.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
        isSoundForMessageEnabled?()
        if let quotedMessageId = quotedMessageId {
            mediaMessage.quotedMessageId = quotedMessageId
        }
        if let fullQuoted = quotedMessage {
            mediaMessage.quotedMessage = fullQuoted
        }
        hideReplyView?()
        CometChatMessageEvents.ccMessageSent(message: mediaMessage, status: .inProgress)
        quotedMessage = nil
        quotedMessageId = nil
        MessageComposerBuilder.mediaMessage(message: mediaMessage) { [weak self] result in
            switch result {
            case .success(let updatedMediaMessage):
                CometChatMessageEvents.ccMessageSent(message: updatedMediaMessage, status: .success)
                if updatedMediaMessage.quotedMessage != nil {
                    CometChatMessageEvents.ccReplyToMessage(message: updatedMediaMessage, status: .success)
                }
            case .failure(let error):
                self?.failure?(error)
                mediaMessage.metaData = ["error": true]
                CometChatMessageEvents.ccMessageSent(message: mediaMessage, status: .error)
            }
        }
    }
}
