//
//  CometChatMessageList + AIConversationStarters.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 13/02/25.
//

import Foundation
import UIKit
import CometChatSDK


//MARK: CONVERSATIONS STARTS
extension CometChatMessageList: CometChatMessageEventListener, CometChatUIEventListener{
    
    func getConversationStarter(configuration: [String: Any]? = nil) {
        
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            
            let receiverId = this.viewModel.user?.uid ?? this.viewModel.group?.guid
            let receiverType: CometChat.ReceiverType = this.viewModel.user?.uid != nil ? .user : .group
            guard let receiverId = receiverId else { return }
            
            this.aiConversationStarterView = CometChatAIConversationStarter()
            this.aiConversationStarterView.onMessageClicked { selectedReply in
                this.onMessageTapped(message: selectedReply, receiverType: receiverType, receiverId: receiverId, id: this.getId())
            }
            this.aiConversationStarterView.showLoadingView()
            
            CometChat.getConversationStarter(receiverId: receiverId, receiverType: receiverType, configuration: configuration) { conversationStarter in
                DispatchQueue.main.async {
                    if conversationStarter.isEmpty{
                        this.aiConversationStarterView.removeFromSuperview()
                    }else{
                        this.aiConversationStarterView.set(aiMessageOptions: conversationStarter)
                    }
                }
            } onError: { error in
                DispatchQueue.main.async{
                    this.aiConversationStarterView.hideLoadingView()
                    this.aiConversationStarterView.removeFromSuperview()
                }
            }
            
            this.set(footerView: this.aiConversationStarterView)
        }
    }
    
    func onMessageTapped(message: String, receiverType: CometChat.ReceiverType, receiverId: String?, id: [String: Any]?){
        
        guard let receiverId = receiverId else { return }
        let textMessage = TextMessage(receiverUid: receiverId, text: message, receiverType: receiverType)
        aiConversationStarterView.removeFromSuperview()
        CometChatUIEvents.ccComposeMessage(id: getId(), message: textMessage)
        
    }
    
    func hideEmptyChatView() {
        
    }
}

extension CometChatMessageList{
    
    public func updateAIOnNewMessageReceived(message: BaseMessage) {
        
        if message.parentMessageId == 0 {
            
            if let textMessage = message as? TextMessage, message.senderUid != CometChat.getLoggedInUser()?.uid {
                
                if enableSmartReplies {
                    if !smartRepliesKeywords.isEmpty {
                        var isKeyPresent = false
                        let text = textMessage.text
                        
                        if !text.isEmpty {
                            for keyword in smartRepliesKeywords {
                                if text.lowercased().contains(keyword.lowercased()) {
                                    isKeyPresent = true
                                }else{
                                    isKeyPresent = false
                                }
                            }
                        }
                        if enableSmartReplies && isKeyPresent{
                            getSmartReplies()
                        }
                    } else{
                        getSmartReplies()
                    }
                }
                
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.aiConversationStarterView.removeFromSuperview()
                    self?.aiSmartReplyView.removeFromSuperview()
                }
            }
            
        }
        
    }
    
}


//MARK: SMART REPLIES
extension CometChatMessageList{
    
    func getSmartReplies(configuration: [String: Any]? = nil) {
        
        smartRepliesWorkItem?.cancel()
        aiSmartReplyView.removeFromSuperview()
    
        smartRepliesWorkItem = DispatchWorkItem(block: { [weak self] in
            
            guard let self = self else { return }
            
            let receiverId = viewModel.user?.uid ?? viewModel.group?.guid
            let receiverType: CometChat.ReceiverType = viewModel.user?.uid != nil ? .user : .group
            let id = getId()
            guard let receiverId = receiverId else { return }

            aiSmartReplyView = CometChatAISmartReply()
            aiSmartReplyView.onMessageClicked { [weak self] selectedReply in
                self?.onSmartReplyMessageTapped(message: selectedReply, receiverType: receiverType, receiverId: receiverId, id: id)
            }
            aiSmartReplyView.onAiCloseButtonClicked = {
                self.aiSmartReplyView.removeFromSuperview()
            }
            aiSmartReplyView.showLoadingView()
            
            CometChat.getSmartReplies(receiverId: receiverId, receiverType: receiverType, configuration: configuration) { [weak self] smartRepliesMap in
                DispatchQueue.main.async {
                    
                    guard let this = self else { return }
                    if smartRepliesMap.isEmpty{
                        this.aiSmartReplyView.show(error: true)
                    } else{
                        let replies = Array(smartRepliesMap.values)
                        this.aiSmartReplyView.set(aiMessageOptions: replies)
                    }
                }
            } onError: { [weak self] error in
                DispatchQueue.main.async {
                    debugPrint("getSmartReplies failed with error: \(String(describing: error?.errorDescription))")
                    guard let this = self else { return }
                    this.aiSmartReplyView.hideLoadingView()
                    this.aiSmartReplyView.show(error: true)
                }
            }
            self.set(footerView: aiSmartReplyView)
            
        })
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(smartRepliesDelayDuration), execute: smartRepliesWorkItem!)
        

    }
    
    func onSmartReplyMessageTapped(message: String, receiverType: CometChat.ReceiverType, receiverId: String?, id: [String: Any]?) {
        guard let receiverId = receiverId else { return }
        let textMessage = TextMessage(receiverUid: receiverId, text: message, receiverType: receiverType)
        self.aiSmartReplyView.removeFromSuperview()
        CometChatUIEvents.ccComposeMessage(id: id, message: textMessage)
    }
}
