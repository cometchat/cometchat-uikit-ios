//
//  AISmartRepliesHelper.swift
//
//
//  Created by SuryanshBisen on 16/09/23.
//

import Foundation
import CometChatSDK

class AISmartRepliesHelper {
    
    var configuration: AISmartRepliesConfiguration?
    var enablerConfiguration: AIEnablerConfiguration?
    var aiDelegate: AICommunicatorProtocol?
    var currentUser: User?
    var currentGroup: Group?
    
    func set(configuration: AISmartRepliesConfiguration?){
        self.configuration = configuration
    }
    
    func set(currentUser: User?){
        self.currentUser = currentUser
    }
    
    func set(currentGroup: Group?){
        self.currentGroup = currentGroup
    }
    
    func set(enablerConfiguration: AIEnablerConfiguration?){
        self.enablerConfiguration = enablerConfiguration
    }
    
    
    func getSmartReplies(id: [String: Any]?, receiverType: CometChat.ReceiverType, receiverId: String?,  compilation: @escaping ([String: String]?) -> Void) {
        
        guard let receiverId = receiverId else { return }

        CometChat.getSmartReplies(receiverId: receiverId, receiverType: receiverType) { smartRepliesMap in
            compilation(smartRepliesMap)
        } onError: { error in
            debugPrint("getSmartReplies failed with error: \(String(describing: error?.errorDescription))")
            self.presentErrorReplies(id: id)
            compilation(nil)
        }

    }
    
    func presentSmartReplies(id: [String: Any]?, receiverType: CometChat.ReceiverType, receiverId: String?) {
        
        presentLoadingView(id: id)
        
        //Building from configuration
        if let onLoad = configuration?.onClick {
            let view = onLoad(currentUser, currentGroup)
            
            if view != nil {
                CometChatUIEvents.emitShowPanel(id: id, alignment: .composerTop, view: view)
            }else {
                presentErrorReplies(id: id)
            }
            return
        }
        
        getSmartReplies(id: id, receiverType: receiverType, receiverId: receiverId) { smartRepliesMap in
            if self.aiDelegate?.isViewStillPresented() == true {
                
                guard let smartRepliesMap = smartRepliesMap else { return }
                
                if smartRepliesMap.count == 0 {
                    self.presentEmptyReplies(id: id)
                    return
                }
            
                var replies = [String]()
                for i in smartRepliesMap {
                    replies.append(i.value)
                }
                
                DispatchQueue.main.async {
                    
                    if let customView = self.configuration?.customView {
                        let customView = customView(smartRepliesMap)
                        if customView == nil {
                            self.presentErrorReplies(id: id)
                        } else {
                            CometChatUIEvents.emitShowPanel(id: id, alignment: .composerBottom, view: customView)
                        }
                        return
                    }
                    
                    
                    let aiReplyView = AIRepliesListView()
                        .set(aiMessageOptions: replies)
                        .set(enablerStyle: self.enablerConfiguration?.style)
                        .set(smartRepliesStyle: self.configuration?.style as? AISmartRepliesStyle)
                        .onMessageClicked(onAiMessageClicked: { selectedReply in
                            self.aiDelegate?.onRepliesButtonChosen()
                            self.onMessageTapped(message: selectedReply, receiverType: receiverType, receiverId: receiverId, id: id)
                        })
                    
                    CometChatUIEvents.emitShowPanel(id: id, alignment: .composerBottom, view: aiReplyView)
                    
                }
            }
        }
        
    }
    
    func onMessageTapped(message: String, receiverType: CometChat.ReceiverType, receiverId: String?, id: [String: Any]?){
        
        guard let receiverId = receiverId else { return }
        let textMessage = TextMessage(receiverUid: receiverId, text: message, receiverType: receiverType)
        CometChatUIEvents.emitHidePanel(id: id, alignment: .composerBottom)
        CometChatUIEvents.emitCCMessageEdited(id: id, message: textMessage)
        
    }
    
    func presentLoadingView(id: [String: Any]?) {
        
        DispatchQueue.main.async {
            
            if let configurationLoadingView = self.enablerConfiguration?.loadingView {
                CometChatUIEvents.emitShowPanel(id: id, alignment: .composerBottom, view: configurationLoadingView)
                return
            }
            
            if let configurationLoadingView = self.configuration?.loadingView {
                CometChatUIEvents.emitShowPanel(id: id, alignment: .composerBottom, view: configurationLoadingView)
                return
            }
            
            let loadingView = AIStateManagementView()
                .setHeight(height: 200)
                .setMainText(text: ("GENERATING_REPLIES".localize()))
                .setStackView(axis: .vertical)
                .configurationForLoadingView(configuration: self.enablerConfiguration, style: self.enablerConfiguration?.style)
                .configurationForLoadingView(configuration: self.configuration, style: self.configuration?.style)
            
            CometChatUIEvents.emitShowPanel(id: id, alignment: .composerBottom, view: loadingView)
            
        }
        
    }
    
    func presentEmptyReplies(id: [String: Any]?) {
        
        DispatchQueue.main.async {
            
            
            if let configurationEmptyView = self.enablerConfiguration?.emptyRepliesView {
                CometChatUIEvents.emitShowPanel(id: id, alignment: .composerBottom, view: configurationEmptyView)
                return
            }
            
            if let configurationEmptyView = self.configuration?.emptyRepliesView {
                CometChatUIEvents.emitShowPanel(id: id, alignment: .composerBottom, view: configurationEmptyView)
                return
            }
            
            let icon = UIImage(named: "ai-empty-replies", in: CometChatUIKit.bundle, with: nil)
            
            let loadingView = AIStateManagementView()
                .setMainText(text: "NO_MESSAGES_FOUND".localize())
                .setStackView(axis: .vertical)
                .setHeight(height: 200)
                .setIcon(icon: icon, iconWidth: 80, iconHeight: 80)
                .configurationForEmptyView(configuration: self.enablerConfiguration, style: self.enablerConfiguration?.style)
                .configurationForEmptyView(configuration: self.configuration, style: self.configuration?.style)
            
            CometChatUIEvents.emitShowPanel(id: id, alignment: .composerBottom, view: loadingView)
            
        }
        
    }
    
    func presentErrorReplies(id: [String: Any]?) {
        
        DispatchQueue.main.async {
            
            if let configurationErrorView = self.enablerConfiguration?.errorView {
                CometChatUIEvents.emitShowPanel(id: id, alignment: .composerBottom, view: configurationErrorView)
                return
            }
            
            if let configurationErrorView = self.configuration?.errorView {
                CometChatUIEvents.emitShowPanel(id: id, alignment: .composerBottom, view: configurationErrorView)
                return
            }
            
            let icon = UIImage(named: "ai-error", in: CometChatUIKit.bundle, with: nil)
            
            let loadingView = AIStateManagementView()
                .setMainText(text: "SOMETHING_WENT_WRONG_ERROR".localize())
                .setStackView(axis: .vertical)
                .setHeight(height: 200)
                .setIcon(icon: icon, iconWidth: 80, iconHeight: 80)
                .configurationForErrorView(configuration: self.enablerConfiguration, style: self.enablerConfiguration?.style)
                .configurationForErrorView(configuration: self.configuration, style: self.configuration?.style)
            
            
            CometChatUIEvents.emitShowPanel(id: id, alignment: .composerBottom, view: loadingView)
            
        }
        
    }
    
}
