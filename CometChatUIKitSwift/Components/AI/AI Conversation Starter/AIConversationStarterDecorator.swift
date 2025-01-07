//
//  AIConversationStarterDecorator.swift
//  
//
//  Created by SuryanshBisen on 13/09/23.
//

import Foundation
import UIKit
import CometChatSDK


class AIConversationStarterDecorator: DataSourceDecorator {
    
    var configuration: AIConversationStarterConfiguration = AIConversationStarterConfiguration()
    var uiEventID: [String: Any]?
    var eventID = "conversation-starters-helper"
    var conversationStarterViewForEmptyChat: UIView?
    var isKeyBoardOpen = false
    var isErrorViewPresented = false
    
    init(dataSource: DataSource, configuration: AIConversationStarterConfiguration? = nil) {
        
        if let configuration = configuration {
            self.configuration = configuration
        }
        
        super.init(dataSource: dataSource)
        
        CometChatUIEvents.addListener(eventID, self)
    }
    
    deinit{
        CometChatUIEvents.removeListener(eventID)
    }
    
    override func getId() -> String {
        return ExtensionConstants.aiConversationStarter
    }

    func connectEvent() {
        CometChatMessageEvents.addListener(eventID, self)
    }
    
    func disconnectEvent() {
        CometChatMessageEvents.removeListener(eventID)
    }
    
    @objc func keyBoardWillShow(notification: NSNotification) {
        isKeyBoardOpen = true
        DispatchQueue.main.async {
            CometChatUIEvents.hidePanel(id: self.uiEventID, alignment: .composerTop)
        }
    }


    @objc func keyBoardWillHide(notification: NSNotification) {
        isKeyBoardOpen = false
        if let view = conversationStarterViewForEmptyChat {
            DispatchQueue.main.async {
                CometChatUIEvents.showPanel(id: self.uiEventID, alignment: .composerTop, view: view)
            }
        }
    }
    
    func getConversationStarter(id: [String: Any]?, receiverType: CometChat.ReceiverType, receiverId: String?, configuration: [String: Any]? = nil) {
        
        guard let receiverId = receiverId else { return }
        uiEventID = id
        
        DispatchQueue.main.async {
            let aiReplyView = CometChatAIConversationStarter()
                .onMessageClicked { selectedReply in
                    self.onMessageTapped(message: selectedReply, receiverType: receiverType, receiverId: receiverId, id: id)
                }
            aiReplyView.id = id
            
            if let loadingView = self.configuration.loadingView {
                CometChatUIEvents.showPanel(id: id, alignment: .composerTop, view: loadingView)
            } else {
                aiReplyView.showLoadingView()
            }
            
            CometChat.getConversationStarter(receiverId: receiverId, receiverType: receiverType, configuration: configuration) { conversationStarter in
                self.connectEvent()
                DispatchQueue.main.async {
                    if conversationStarter.isEmpty{
                        CometChatUIEvents.hidePanel(id: id, alignment: .composerTop)
                    }else{
                        if let customView = self.configuration.customView {
                            let customView = customView(conversationStarter)
                            if customView == nil {
                                CometChatUIEvents.hidePanel(id: id, alignment: .composerTop)
                            } else {
                                CometChatUIEvents.showPanel(id: id, alignment: .composerTop, view: customView)
                            }
                            return
                        }
                        aiReplyView.set(aiMessageOptions: conversationStarter)
                    }
                }
            } onError: { error in
                DispatchQueue.main.async{
                    self.disconnectEvent()
                    aiReplyView.hideLoadingView()
                    CometChatUIEvents.hidePanel(id: id, alignment: .composerTop)
                }
            }
            
            CometChatUIEvents.showPanel(id: id, alignment: .composerTop, view: aiReplyView)
        }
    }
    
    func onMessageTapped(message: String, receiverType: CometChat.ReceiverType, receiverId: String?, id: [String: Any]?){
        
        guard let receiverId = receiverId else { return }
        let textMessage = TextMessage(receiverUid: receiverId, text: message, receiverType: receiverType)
        CometChatUIEvents.hidePanel(id: id, alignment: .composerBottom)
        CometChatUIEvents.ccComposeMessage(id: id, message: textMessage)
        
    }
    
    func hideEmptyChatView() {
        disconnectEvent()
        DispatchQueue.main.async {
            CometChatUIEvents.hidePanel(id: self.uiEventID, alignment: .composerTop)
        }
        conversationStarterViewForEmptyChat = nil
    }
    
    func presentConversationStarter(id: [String : Any]?, user: CometChatSDK.User?, group: CometChatSDK.Group?) {
        
        uiEventID = id
        connectEvent()
        
        var receiverType: CometChat.ReceiverType = .user
        var receiverId: String? = ""
        
        if let guid = id?["guid"] {
            receiverType = .group
            receiverId = guid as? String
        } else if let uid = id?["uid"] {
            receiverType = .user
            receiverId = uid as? String
        }
        
        //Building from configuration
        if let apiConfiguration = configuration.apiConfiguration {
            apiConfiguration(user, group, { [weak self] configuration in
                guard let this = self else { return }
                this.getConversationStarter(id: id, receiverType: receiverType, receiverId: receiverId, configuration: configuration)
            })
            return
        }
        
        getConversationStarter(id: id, receiverType: receiverType, receiverId: receiverId)
    }
    
}

extension AIConversationStarterDecorator: CometChatUIEventListener {
    
    func onActiveChatChanged(id: [String : Any]?, lastMessage: CometChatSDK.BaseMessage?, user: CometChatSDK.User?, group: CometChatSDK.Group?) {  
        
        if lastMessage == nil && id?["parentMessageId"] == nil {
            presentConversationStarter(id: id, user: user, group: group)
        }
    }
    
    func ccActiveChatChanged(id: [String : Any]?, lastMessage: CometChatSDK.BaseMessage?, user: CometChatSDK.User?, group: CometChatSDK.Group?) {
        if lastMessage == nil && id?["parentMessageId"] == nil {
            presentConversationStarter(id: id, user: user, group: group)
        }
    }
}


extension AIConversationStarterDecorator: CometChatMessageEventListener {
    func ccMessageSent(message: CometChatSDK.BaseMessage, status: MessageStatus) {
        hideEmptyChatView()
        if isErrorViewPresented {
            isErrorViewPresented = false
            CometChatUIEvents.hidePanel(id: uiEventID, alignment: .composerTop)
        }
    }
    
    func onTextMessageReceived(textMessage: TextMessage) {
        if shouldHidePanel(message: textMessage){
            hideEmptyChatView()
        }
        if isErrorViewPresented {
            isErrorViewPresented = false
            CometChatUIEvents.hidePanel(id: uiEventID, alignment: .composerTop)
        }
    }
    
    func onMediaMessageReceived(mediaMessage: MediaMessage) {
        if shouldHidePanel(message: mediaMessage){
            hideEmptyChatView()
        }
        if isErrorViewPresented {
            isErrorViewPresented = false
            CometChatUIEvents.hidePanel(id: uiEventID, alignment: .composerTop)
        }
    }
    
    func onCustomMessageReceived(customMessage: CustomMessage) {
        if shouldHidePanel(message: customMessage){
            hideEmptyChatView()
        }
        if isErrorViewPresented {
            isErrorViewPresented = false
            CometChatUIEvents.hidePanel(id: uiEventID, alignment: .composerTop)
        }
    }
        
    func onFormMessageReceived(message: FormMessage) { 
        if shouldHidePanel(message: message){
            hideEmptyChatView()
        }
        if isErrorViewPresented {
            isErrorViewPresented = false
            CometChatUIEvents.hidePanel(id: uiEventID, alignment: .composerTop)
        }
    }
    
    func onCardMessageReceived(message: CardMessage) { 
        if shouldHidePanel(message: message){
            hideEmptyChatView()
        }
        if isErrorViewPresented {
            isErrorViewPresented = false
            CometChatUIEvents.hidePanel(id: uiEventID, alignment: .composerTop)
        }
    }
    
    func onSchedulerMessageReceived(message: SchedulerMessage) {
        if shouldHidePanel(message: message){
            hideEmptyChatView()
        }
        if isErrorViewPresented {
            isErrorViewPresented = false
            CometChatUIEvents.hidePanel(id: uiEventID, alignment: .composerTop)
        }
    }
    
    func onCustomInteractiveMessageReceived(message: CustomInteractiveMessage) {
        if shouldHidePanel(message: message){
            hideEmptyChatView()
        }
        if isErrorViewPresented {
            isErrorViewPresented = false
            CometChatUIEvents.hidePanel(id: uiEventID, alignment: .composerTop)
        }
    }
    
    func shouldHidePanel(message: BaseMessage) -> Bool{
        if let guid = uiEventID?["guid"] as? String {
            if guid == message.receiverUid{
                return true
            }
        } else if let uid = uiEventID?["uid"] as? String {
            if uid == message.sender?.uid{
                return true
            }
        }
        return false
    }
    
}
