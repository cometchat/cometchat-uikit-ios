//
//  MessageComposerViewModel.swift
//  Created by Ajay Verma on 16/12/22.
//

import Foundation
import CometChatSDK

protocol MessageComposerViewModelProtocol {
    var user: CometChatSDK.User? { get set }
    var group: CometChatSDK.Group? { get set }
    var message: BaseMessage? { get set }
    var parentMessageId: Int? { get set }
    var reset: ((Bool) -> ())? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
    var isSoundForMessageEnabled: (() -> ())? { get set }
    var typingIndicator: TypingIndicator? { get set }
}

open class MessageComposerViewModel: NSObject, MessageComposerViewModelProtocol {
    var isSoundForMessageEnabled: (() -> ())?
    var parentMessageId: Int?
    var reset: ((Bool) -> ())?
    var failure: ((CometChatException) -> Void)?
    var user: User?
    var group: Group?
    var message: BaseMessage?
    var typingIndicator: TypingIndicator?
    var onMessageEdit: ((_ message: BaseMessage) -> ())?
    var textFormatterMap: [Character: CometChatTextFormatter] = {
        var textFormatterMap = [Character: CometChatTextFormatter]()
        for textFormatter in ChatConfigurator.getDataSource().getTextFormatters() {
            textFormatterMap[textFormatter.getTrackingCharacter()] = textFormatter
        }
        return textFormatterMap
    }()
    var eventID = "MessageComposerViewModel-\(Date().timeIntervalSince1970)"
    
    var textFormatter: [CometChatTextFormatter] {
        get {
            var textFormatter = [CometChatTextFormatter]()
            textFormatterMap.forEach({ textFormatter.append($1) })
            return textFormatter
        }
        set {
            var textFormatters = [Character: CometChatTextFormatter]()
            for textFormatter in newValue {
                if let user = user { textFormatter.set(user: user) }
                if let group = group { textFormatter.set(group: group) }
                textFormatters[textFormatter.getTrackingCharacter()] = textFormatter
            }
            textFormatterMap = textFormatters
        }
    }
    
    func connect() {
        CometChatMessageEvents.addListener(eventID, self)
        CometChatUserEvents.addListener(eventID, self)
    }
    
    func disconnect() {
        CometChatMessageEvents.removeListener(eventID)
        CometChatUserEvents.removeListener(eventID)
    }
    
    func set(user: User) {
        self.user = user
        textFormatterMap.forEach({ $1.set(user: user) })
        setTypingIndicator()
    }
    
    func set(group: Group) {
        self.group = group
        textFormatterMap.forEach({ $1.set(group: group) })
        setTypingIndicator()
    }
}

extension MessageComposerViewModel: CometChatMessageEventListener {
    
    public func ccMessageEdited(message: BaseMessage, status: MessageStatus) {
        if status == .inProgress {
            onMessageEdit?(message)
        }
    }
}

extension MessageComposerViewModel {
    
    public func setupBaseMessage(message: String, textFormatter: [Character: [(item: SuggestionItem, range: NSRange)]]) -> BaseMessage {
        let message: String = message.trimmingCharacters(in: .whitespacesAndNewlines)
        var textMessage: TextMessage?
        if !message.isEmpty {
            if let uid = self.user?.uid {
                textMessage = TextMessage(receiverUid: uid, text: message, receiverType: .user)
            } else if let guid = self.group?.guid {
                textMessage = TextMessage(receiverUid: guid, text: message, receiverType: .group)
            }
            if !textFormatter.isEmpty {
                update(message: textMessage!, withSelected: textFormatter)
            }
            textMessage?.muid = "\(NSDate().timeIntervalSince1970)"
            textMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
            textMessage?.sender = CometChat.getLoggedInUser()
            if let parentMessageId = parentMessageId {
                textMessage?.parentMessageId = parentMessageId
            }
        }
        
        isSoundForMessageEnabled?()
        reset?(true)
        return textMessage!
    }
    
    public func setupBaseMessage(url: String) -> BaseMessage {
        var mediaMessage: MediaMessage?
        if !url.isEmpty {
            if let uid = self.user?.uid {
                mediaMessage = MediaMessage(receiverUid: uid, fileurl: url, messageType: .audio, receiverType: .user)
            } else if let guid = self.group?.guid {
                mediaMessage = MediaMessage(receiverUid: guid, fileurl: url, messageType: .audio, receiverType: .group)
            }
            mediaMessage?.muid = "\(NSDate().timeIntervalSince1970)"
            mediaMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
            mediaMessage?.sender = CometChat.getLoggedInUser()
            if let parentMessageId = parentMessageId {
                mediaMessage?.parentMessageId = parentMessageId
            }
        }
        
        isSoundForMessageEnabled?()
        reset?(true)
        return mediaMessage!
    }
    
    public func sendTextMessageToUser(message: String, textFormatter: [Character: [(item: SuggestionItem, range: NSRange)]]) {
        self.reset?(true)
        let message: String = message.trimmingCharacters(in: .whitespacesAndNewlines)
        if !message.isEmpty {
            guard let uid = self.user?.uid else { return }
            let textMessage = TextMessage(receiverUid: uid, text: message, receiverType: .user)
            if !textFormatter.isEmpty {
                update(message: textMessage, withSelected: textFormatter)
            }
            textMessage.muid =  "\(NSDate().timeIntervalSince1970)"
            textMessage.sentAt = Int(Date().timeIntervalSince1970)
            textMessage.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
            textMessage.sender = CometChat.getLoggedInUser()
            if let parentMessageId = self.parentMessageId {
                textMessage.parentMessageId = parentMessageId
            }
            self.isSoundForMessageEnabled?()
            CometChatMessageEvents.ccMessageSent(message: textMessage, status: .inProgress)
            MessageComposerBuilder.textMessage(message: textMessage) { result in
                switch result {
                case .success(let updatedTextMessage):
                    CometChatMessageEvents.ccMessageSent(message: updatedTextMessage, status: .success)
                case .failure(let error):
                    textMessage.metaData = ["error": true]
                    CometChatMessageEvents.ccMessageSent(message: textMessage, status: .error)
                }
            }
        }
    }
    
    public func update(message: TextMessage, withSelected textFormatter: [Character: [(item: SuggestionItem, range: NSRange)]]) {
        
        var textFormatterArray = [(range: NSRange, item: SuggestionItem, formatter: CometChatTextFormatter)]()
        var suggestionItemCollection = [Character: (formatter: CometChatTextFormatter, items: [SuggestionItem])]()
        textFormatter.forEach { (textFormatterCharater, values) in
            values.forEach { (item, range) in
                textFormatterArray.append((range: range, item: item, formatter: textFormatterMap[textFormatterCharater]!))
                if suggestionItemCollection[textFormatterCharater] == nil {
                    suggestionItemCollection[textFormatterCharater] = (formatter: textFormatterMap[textFormatterCharater]!, items: [item])
                } else {
                    suggestionItemCollection[textFormatterCharater]?.items.append(item)
                }
            }
        }
        textFormatterArray.sort(by: { $0.0.location < $1.0.location })
        var locationDifference = 0
        var messageText = message.text
        
        for (range, item, _) in textFormatterArray {
            let updatedRange = NSRange(location: range.location + locationDifference, length: range.length)
            if updatedRange.lowerBound >= 0 && updatedRange.upperBound <= messageText.utf16.count && updatedRange.length <= messageText.utf16.count { //We are going this to insure crash
                messageText = (messageText as NSString).replacingCharacters(in: updatedRange, with: item.underlyingText ?? "")
                locationDifference = locationDifference + ((item.underlyingText?.count ?? 0) - range.length)
            }
        }
        
        suggestionItemCollection.forEach { (key, arg1) in
            let (formatter, items) = arg1
            formatter.handlePreMessageSend(baseMessage: message, suggestionItemList: items)
        }
        
        message.text = messageText
        
    }
    
    public func sendTextMessageToGroup(message: String, textFormatter: [Character: [(item: SuggestionItem, range: NSRange)]]) {
        reset?(true)
        var message: String = message.trimmingCharacters(in: .whitespacesAndNewlines)
        if !message.isEmpty {
            guard let guid = self.group?.guid else { return }
            let textMessage = TextMessage(receiverUid: guid, text: message, receiverType: .group)
            if !textFormatter.isEmpty {
                update(message: textMessage, withSelected: textFormatter)
            }
            textMessage.muid = "\(NSDate().timeIntervalSince1970)"
            textMessage.sentAt = Int(Date().timeIntervalSince1970)
            textMessage.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
            textMessage.sender = CometChat.getLoggedInUser()
            if let parentMessageId = parentMessageId {
                textMessage.parentMessageId = parentMessageId
            }
            isSoundForMessageEnabled?()
            // Broadcasting the message sent's event with inProgress status.
            CometChatMessageEvents.ccMessageSent(message: textMessage, status: .inProgress)
            MessageComposerBuilder.textMessage(message: textMessage) { result in
                switch result {
                case .success(let updatedTextMessage):
                    // Broadcasting the message sent's event with sucess status.
                    CometChatMessageEvents.ccMessageSent(message: updatedTextMessage, status: .success)
                case .failure(let error):
                    textMessage.metaData = ["error": true]
                    // Broadcasting the message error's event.
                    CometChatMessageEvents.ccMessageSent(message: textMessage, status: .error)
                }
                
            }
        }
    }
    
    public func sendMediaMessageToUser(url: String, type: CometChat.MessageType) {
        guard let uid =  self.user?.uid else { return }
        let mediaMessage = MediaMessage(receiverUid: uid, fileurl: url, messageType: type, receiverType: .user)
        mediaMessage.muid = "\(NSDate().timeIntervalSince1970)"
        mediaMessage.sentAt = Int(Date().timeIntervalSince1970)
        mediaMessage.sender = CometChat.getLoggedInUser()
        mediaMessage.metaData = ["fileURL": url]
        mediaMessage.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
        if let parentMessageId = parentMessageId {
            mediaMessage.parentMessageId = parentMessageId
        }
        isSoundForMessageEnabled?()
        CometChatMessageEvents.ccMessageSent(message: mediaMessage, status: .inProgress)
        MessageComposerBuilder.mediaMessage(message: mediaMessage) {(result) in
            switch result {
            case .success(let updatedMediaMessage):
                CometChatMessageEvents.ccMessageSent(message: updatedMediaMessage, status: .success)
            case .failure(let error):
                mediaMessage.metaData = ["error": true]
                CometChatMessageEvents.ccMessageSent(message: mediaMessage, status: .error)
            }
        }
    }
    
    public func sendMediaMessageToGroup(url: String, type: CometChat.MessageType) {
        guard let uid =  self.group?.guid else { return }
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
        CometChatMessageEvents.ccMessageSent(message: mediaMessage, status: .inProgress)
        MessageComposerBuilder.mediaMessage(message: mediaMessage) { (result) in
            switch result {
            case .success(let updatedMediaMessage):
                CometChatMessageEvents.ccMessageSent(message: updatedMediaMessage, status: .success)
            case .failure(let error):
                mediaMessage.metaData = ["error": true]
                CometChatMessageEvents.ccMessageSent(message: mediaMessage, status: .error)
            }
        }
    }
    
    public func editTextMessage(textMessage: TextMessage, message: String?, textFormatter: [Character: [(item: SuggestionItem, range: NSRange)]]) {
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
                        // updated_text_message get as Action_message.
                        CometChatMessageEvents.ccMessageEdited(message: textMessage, status: .success)
                    }
                case .failure(let error):
                    DispatchQueue.main.async { [weak self] in
                        guard let this = self else { return }
                        this.reset?(true)
                        textMessage.metaData = ["error": true]
                        CometChatMessageEvents.ccMessageEdited(message: textMessage, status: .error)
                    }
                }
                
            }
        }
    }
    
    public func onLiveReactionClick() {
        if let user = self.user {
            let liveReaction = TransientMessage(receiverID: user.uid ?? "", receiverType: .user, data: ["type":MetadataConstants.liveReaction, "reaction": "heart"])
            CometChat.sendTransientMessage(message: liveReaction)
            // Broadcasting live reaction's event
            CometChatMessageEvents.ccLiveReaction(reaction: liveReaction)
            
        } else if let group = self.group {
            // TODO:- Needs to ask receiverType is correct ?
            let liveReaction = TransientMessage(receiverID: group.guid , receiverType: .group, data: ["type":MetadataConstants.liveReaction, "reaction": "heart"])
            CometChat.sendTransientMessage(message: liveReaction)
            // Broadcasting live reaction's event
            CometChatMessageEvents.ccLiveReaction(reaction: liveReaction)
        }
    }
    
    private func setTypingIndicator() {
        if let user = user {
            typingIndicator = TypingIndicator(receiverID: user.uid ?? "", receiverType: .user)
        }
        
        if let group = group {
            typingIndicator = TypingIndicator(receiverID: group.guid , receiverType: .group)
        }
    }
    
    public func startTyping() {
        if let typingIndicator = self.typingIndicator {
            CometChat.startTyping(indicator: typingIndicator)
        }
    }
    
    public func endTyping() {
        if let typingIndicator = self.typingIndicator {
            CometChat.endTyping(indicator: typingIndicator)
        }
    }
    
    public func checkBlockedStatus() -> Bool {
        var status = false
        if let _user = user {
            status = _user.hasBlockedMe || _user.blockedByMe
        }
        
        return status
    }
    
}

