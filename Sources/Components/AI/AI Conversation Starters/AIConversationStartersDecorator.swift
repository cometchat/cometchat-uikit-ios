//
//  AIConversationStartersDecorator.swift
//  
//
//  Created by SuryanshBisen on 13/09/23.
//

import Foundation
import UIKit
import CometChatSDK


class AIConversationStartersDecorator: DataSourceDecorator {
    
    let configuration: AIConversationStartersConfiguration?
    var enablerConfiguration: AIEnablerConfiguration?
    var uiEventID: [String: Any]?
    var eventID = "conversation-starters-helper"
    var conversationStartersViewForEmptyChat: UIView?
    var isKeyBoardOpen = false
    var aiDelegate: AICommunicatorProtocol?
    
    init(dataSource: DataSource, configuration: AIConversationStartersConfiguration? = nil, enablerConfiguration: AIEnablerConfiguration? = nil) {
        
        self.configuration = configuration
        self.enablerConfiguration = enablerConfiguration
        
        super.init(dataSource: dataSource)
        
        CometChatUIEvents.addListener(eventID, self)
    }
    
    deinit{
        CometChatUIEvents.removeListener(eventID)
    }
    
    override func getId() -> String {
        return ExtensionConstants.aiConversationStarters
    }
    
    func set(enablerConfiguration: AIEnablerConfiguration?){
        self.enablerConfiguration = enablerConfiguration
    }
    
    func connectEvent() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        CometChatMessageEvents.addListener(eventID, self)
    }
    
    func disconnectEvent() {
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
        CometChatMessageEvents.removeListener(eventID)
    }
    
    @objc func keyBoardWillShow(notification: NSNotification) {
        isKeyBoardOpen = true
        DispatchQueue.main.async {
            CometChatUIEvents.emitHidePanel(id: self.uiEventID, alignment: .composerTop)
        }
    }


    @objc func keyBoardWillHide(notification: NSNotification) {
        isKeyBoardOpen = false
        if let view = conversationStartersViewForEmptyChat {
            DispatchQueue.main.async {
                CometChatUIEvents.emitShowPanel(id: self.uiEventID, alignment: .composerTop, view: view)
            }
        }
    }
    
    func getConversationStarters(id: [String: Any]?, receiverType: CometChat.ReceiverType, receiverId: String?, compilation: @escaping ([String]?) -> Void) {
        
        guard let receiverId = receiverId else { return }
        
        CometChat.getConversationStarter(receiverId: receiverId, receiverType: receiverType) { conversationStarters in
            compilation(conversationStarters)
        } onError: { error in
            self.presentErrorView(id: id)
            compilation(nil)
        }
    }
    
    func onMessageTapped(message: String, receiverType: CometChat.ReceiverType, receiverId: String?, id: [String: Any]?){
        
        guard let receiverId = receiverId else { return }
        let textMessage = TextMessage(receiverUid: receiverId, text: message, receiverType: receiverType)
        CometChatUIEvents.emitHidePanel(id: id, alignment: .composerBottom)
        CometChatUIEvents.emitCCMessageEdited(id: id, message: textMessage)
        
    }
    
    func hideEmptyChatView() {
        disconnectEvent()
        DispatchQueue.main.async {
            CometChatUIEvents.emitHidePanel(id: self.uiEventID, alignment: .composerTop)
        }
        conversationStartersViewForEmptyChat = nil
    }
    
    func presentConversationStartersForEmptyChat(id: [String : Any]?, user: CometChatSDK.User?, group: CometChatSDK.Group?) {
        
        uiEventID = id
        connectEvent()
                
        //Building from configuration
        if let onLoad = configuration?.onLoad {
            let view = onLoad(user, group)
            
            if view != nil {
                CometChatUIEvents.emitShowPanel(id: id, alignment: .composerTop, view: view)
            }else {
                presentErrorView(id: id)
            }
            return
        }
        
        var receiverType: CometChat.ReceiverType = .user
        var receiverId: String? = ""
        
        if let guid = id?["guid"] {
            receiverType = .group
            receiverId = guid as? String
        } else if let uid = id?["uid"] {
            receiverType = .user
            receiverId = uid as? String
        }
        
        presentLoadingViewForEmptyChat(id: id)
        
        getConversationStarters(id: id, receiverType: receiverType, receiverId: receiverId) { replies in
            guard let replies = replies else { return }
            
            if replies.count == 0 {
                self.presentEmptyView(id: id)
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else { return }
                
                //Building from configuration
                if let customView = self.configuration?.customView {
                    let customView = customView(replies)
                    if customView == nil {
                        self.presentErrorView(id: id)
                    } else {
                        CometChatUIEvents.emitShowPanel(id: id, alignment: .composerTop, view: customView)
                    }
                    return
                }
                
                CometChatUIEvents.emitHidePanel(id: id, alignment: .composerTop)
                
                let aiReplyView = AIRepliesListView()
                    .set(isForEmptyMessages: true)
                    .set(backgroundColour: CometChatTheme.palatte.background)
                    .set(tableViewStyle: .none)
                    .set(aiMessageOptions: replies)
                    .set(enablerStyle: enablerConfiguration?.style)
                    .set(conversationStartersStyle: configuration?.style)
                    .onMessageClicked { selectedMessage in
                        self.onMessageTapped(message: selectedMessage, receiverType: receiverType, receiverId: receiverId, id: id)
                    }
                self.conversationStartersViewForEmptyChat = aiReplyView
                if self.isKeyBoardOpen == true { return }
                CometChatUIEvents.emitShowPanel(id: id, alignment: .composerTop, view: aiReplyView)
                
            }
        }
        
    }
    
    func presentLoadingViewForEmptyChat(id: [String: Any]?){
        
        DispatchQueue.main.async {
            
            if let configurationLoadingView = self.enablerConfiguration?.loadingView {
                CometChatUIEvents.emitShowPanel(id: id, alignment: .composerTop, view: configurationLoadingView)
                return
            }
            
            if let configurationLoadingView = self.configuration?.loadingView {
                CometChatUIEvents.emitShowPanel(id: id, alignment: .composerTop, view: configurationLoadingView)
                return
            }
            
            let loadingView = AIStateManagementView()
                .setMainText(text: "GENERATIONG_ICEBREAKER".localize())
                .configurationForLoadingView(configuration: self.enablerConfiguration, style: self.enablerConfiguration?.style)
                .configurationForLoadingView(configuration: self.configuration, style: self.configuration?.style)
            
            
            CometChatUIEvents.emitShowPanel(id: id, alignment: .composerTop, view: loadingView)
            
        }
        
    }
    
    func presentEmptyView(id: [String: Any]?) {
        
        DispatchQueue.main.async {
            
            if let configurationEmptyView = self.enablerConfiguration?.emptyRepliesView {
                CometChatUIEvents.emitShowPanel(id: id, alignment: .composerTop, view: configurationEmptyView)
                return
            }
            
            if let configurationEmptyView = self.configuration?.emptyRepliesView {
                CometChatUIEvents.emitShowPanel(id: id, alignment: .composerTop, view: configurationEmptyView)
                return
            }
            
            let icon = UIImage(named: "ai-empty-replies", in: CometChatUIKit.bundle, with: nil)
            
            let emptyView = AIStateManagementView()
                .setMainText(text: "NO_MESSAGES_FOUND".localize())
                .setStackView(axis: .horizontal)
                .setIcon(icon: icon)
                .configurationForEmptyView(configuration: self.enablerConfiguration, style: self.enablerConfiguration?.style)
                .configurationForEmptyView(configuration: self.configuration, style: self.configuration?.style)
            
            
            CometChatUIEvents.emitShowPanel(id: id, alignment: .composerTop, view: emptyView)
            
        }
    }
    
    func presentErrorView(id: [String: Any]?) {
        
        DispatchQueue.main.async {
            
            if let configurationErrorView = self.enablerConfiguration?.errorView {
                CometChatUIEvents.emitShowPanel(id: id, alignment: .composerTop, view: configurationErrorView)
                return
            }
            
            if let configurationErrorView = self.configuration?.errorView {
                CometChatUIEvents.emitShowPanel(id: id, alignment: .composerTop, view: configurationErrorView)
                return
            }
            
            let icon = UIImage(named: "ai-error", in: CometChatUIKit.bundle, with: nil)
            
            let errorView = AIStateManagementView()
                .setMainText(text: "SOMETHING_WENT_WRONG_ERROR".localize())
                .setStackView(axis: .horizontal)
                .setIcon(icon: icon)
                .configurationForErrorView(configuration: self.enablerConfiguration, style: self.enablerConfiguration?.style)
                .configurationForErrorView(configuration: self.configuration, style: self.configuration?.style)
            
            
            CometChatUIEvents.emitShowPanel(id: id, alignment: .composerTop, view: errorView)
            
        }
            
    }
    
}

extension AIConversationStartersDecorator: CometChatUIEventListener {
    func showPanel(id: [String : Any]?, alignment: UIAlignment, view: UIView?) { }
    
    func hidePanel(id: [String : Any]?, alignment: UIAlignment) {  }
    
    func onActiveChatChanged(id: [String : Any]?, lastMessage: CometChatSDK.BaseMessage?, user: CometChatSDK.User?, group: CometChatSDK.Group?) {  
        
        if lastMessage == nil && id?["parentMessageId"] == nil {
            presentConversationStartersForEmptyChat(id: id, user: user, group: group)
        }
        
    }
    
    func ccComposeMessage(id: [String : Any]?, message: CometChatSDK.BaseMessage) { }
    
    func openChat(user: CometChatSDK.User?, group: CometChatSDK.Group?) {   }
    
    
}


extension AIConversationStartersDecorator: CometChatMessageEventListener {
    func onMessageSent(message: CometChatSDK.BaseMessage, status: MessageStatus) {
        hideEmptyChatView()
    }
    
    func onMessageEdit(message: CometChatSDK.BaseMessage, status: MessageStatus) { }
    
    func onMessageDelete(message: CometChatSDK.BaseMessage) {    }
    
    func onMessageReply(message: CometChatSDK.BaseMessage, status: MessageStatus) { }
    
    func onMessageRead(message: CometChatSDK.BaseMessage) { }
    
    func onParentMessageUpdate(message: CometChatSDK.BaseMessage) { }
    
    func onLiveReaction(reaction: CometChatSDK.TransientMessage) { }
    
    func onMessageError(error: CometChatSDK.CometChatException) { }
    
    func onVoiceCall(user: CometChatSDK.User) { }
    
    func onVoiceCall(group: CometChatSDK.Group) { }
    
    func onVideoCall(user: CometChatSDK.User) { }
    
    func onVideoCall(group: CometChatSDK.Group) { }
    
    func onViewInformation(user: CometChatSDK.User) { }
    
    func onViewInformation(group: CometChatSDK.Group) { }
    
    func onError(message: CometChatSDK.BaseMessage?, error: CometChatSDK.CometChatException) { }
    
    func onMessageReact(message: CometChatSDK.BaseMessage, reaction: CometChatMessageReaction) { }
    
    
}
