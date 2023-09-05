//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 16/02/23.
//

import Foundation
import CometChatSDK

class SmartReplyExtensionDecorator: DataSourceDecorator {
    
    var dataStamp:Double?
    var _messageListenerId: String?
    var loggedInUser: User?
    
    override init(dataSource: DataSource) {
        super.init(dataSource: dataSource)
        self.dataStamp = Date().timeIntervalSince1970
        self._messageListenerId = "ExtensionMessageListener"
        self.loggedInUser = CometChat.getLoggedInUser()
        disconnect()
        connect()
    }
    
    override func getId() -> String {
        return "smart-reply"
    }
    
    public func connect() {
        if let _messageListenerId = _messageListenerId {
            CometChat.addMessageListener(_messageListenerId, self)
            CometChatUIEvents.addListener(_messageListenerId, self)
        }
    }
    
    public func disconnect() {
        if let _messageListenerId = _messageListenerId {
            CometChat.removeMessageListener(_messageListenerId)
            CometChatUIEvents.removeListener(_messageListenerId)
        }
    }
    
    public func getReplies(message: BaseMessage) -> [String]? {
        var replies = [String]()
        if let map = ExtensionModerator.extensionCheck(baseMessage: message), !map.isEmpty && map.containsKey(ExtensionConstants.smartReply), let smartReplies = map[ExtensionConstants.smartReply] {
            
            if smartReplies.containsKey("reply_neutral") {
                if let reply_neutral = smartReplies["reply_neutral"] as? String {
                    replies.append(reply_neutral)
                }
            }
            if smartReplies.containsKey("reply_negative") {
                if let reply_negative = smartReplies["reply_negative"] as? String {
                    replies.append(reply_negative)
                }
            }
            if smartReplies.containsKey("reply_positive") {
                if let reply_positive = smartReplies["reply_positive"] as? String {
                    replies.append(reply_positive)
                }
            }
            if !replies.isEmpty {
                replies.append("")
            }
        }
        return replies
    }
    
    public func presentSmartReplies(for textMessage: BaseMessage) {
        var id = [String:Any]()
        if let receiver = textMessage.receiver {
            if receiver is User {
                id["uid"] = textMessage.sender?.uid
            } else if receiver is Group {
                id["guid"] = textMessage.receiverUid
            }
        }
        if textMessage.parentMessageId != 0 {
            id["parentMessageId"] = textMessage.parentMessageId
        }
        if let replies = getReplies(message: textMessage) , !replies.isEmpty {
            let smartRepliesView = CometChatSmartReplies()
            smartRepliesView.translatesAutoresizingMaskIntoConstraints = false
            smartRepliesView.heightAnchor.constraint(equalToConstant: 60).isActive = true
            smartRepliesView.set(titles: replies)
            smartRepliesView.setOnClick { title in
                if title == "" {
                    CometChatUIEvents.emitShowPanel(id: id, alignment: .messageListBottom, view: nil)
                } else {
                    let newMessage: TextMessage?
                    if textMessage.receiverType == .user {
                        let receiverUid = textMessage.sender?.uid ?? ""
                        newMessage = TextMessage(receiverUid: receiverUid, text: title, receiverType: .user)
                    } else {
                        let receiverUid = textMessage.receiverUid
                        newMessage = TextMessage(receiverUid: receiverUid, text: title, receiverType: .group)
                    }
                    if let newMessage = newMessage {
                        newMessage.muid = "\(Int(Date().timeIntervalSince1970))"
                        newMessage.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
                        newMessage.sender = CometChat.getLoggedInUser()
                        newMessage.parentMessageId = textMessage.parentMessageId
                        CometChatUIKit.sendTextMessage(message: newMessage)
                        CometChatUIEvents.emitShowPanel(id: id, alignment: .messageListBottom, view: nil)
                    }
                }
            }
            CometChatUIEvents.emitShowPanel(id: id, alignment: .messageListBottom, view: smartRepliesView)
        }else{
            CometChatUIEvents.emitShowPanel(id: id, alignment: .messageListBottom, view: nil)
        }
    }
}

extension SmartReplyExtensionDecorator: CometChatMessageDelegate {
    
    func onTextMessageReceived(textMessage: TextMessage) {
       presentSmartReplies(for: textMessage)
    }
}

extension SmartReplyExtensionDecorator: CometChatUIEventListener {
    
    func showPanel(id: [String : Any]?, alignment: UIAlignment, view: UIView?) {
        
    }
    
    func hidePanel(id: [String : Any]?, alignment: UIAlignment) {
        
    }
    
    func onActiveChatChanged(id: [String : Any]?, lastMessage: CometChatSDK.BaseMessage?, user: CometChatSDK.User?, group: CometChatSDK.Group?) {
        if let lastMessage = lastMessage {
            presentSmartReplies(for: lastMessage)
        }
    }
    
    
    public func openChat(user: CometChatSDK.User?, group: CometChatSDK.Group?) {}
}
