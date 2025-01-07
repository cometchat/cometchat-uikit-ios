//
//  AISmartRepliesDecorator.swift
//  
//
//  Created by SuryanshBisen on 12/09/23.
//

import Foundation
import CometChatSDK

class AISmartRepliesDecorator: DataSourceDecorator {
    
    private var aiConfiguration: AISmartRepliesConfiguration?
    private var currentUser: User?
    private var currentGroup: Group?
    private var isErrorViewPresented = false
    private var uiEventId: [String: Any]?
    private let eventID = "conversation-summary-decorator"
    
    var aiOptionsStyle = AIOptionsStyle()
    
    init(dataSource: DataSource, configuration: AISmartRepliesConfiguration? = nil) {
        self.aiConfiguration = configuration
        super.init(dataSource: dataSource)
    }
    
    override func getId() -> String {
        return ExtensionConstants.aiSmartReply
    }
    
    override func getAIOptions(controller: UIViewController, user: User?, group: Group?, id: [String: Any]?, aiOptionsStyle: AIOptionsStyle?) -> [CometChatMessageComposerAction]? {
        
        let receiverType: CometChat.ReceiverType = user != nil ? .user : .group
        let receiverID = user?.uid ?? group?.guid
        self.uiEventId = id
        
        let smartRepliesComposerAction = CometChatMessageComposerAction(
            id: getId(),
            text: AIConstants.smartRepliesText,
            startIcon: UIImage(named: "ai_suggest_reply", in: CometChatUIKit.bundle, with: nil),
            startIconTint: aiOptionsStyle?.aiImageTintColor,
            textColor: aiOptionsStyle?.textColor,
            textFont: aiOptionsStyle?.textFont,
            backgroundColour: aiOptionsStyle?.backgroundColor,
            borderRadius: aiOptionsStyle?.cornerRadius,
            borderWidth: aiOptionsStyle?.borderWidth,
            borderColor: aiOptionsStyle?.borderColor
        ) {
            self.getSmartReplies(id: id, receiverType: receiverType, receiverId: receiverID)
        }
        
        var composerActions = super.getAIOptions(controller: controller, user: user, group: group, id: id, aiOptionsStyle: aiOptionsStyle) ?? []
        composerActions.append(smartRepliesComposerAction)
        return composerActions
    }
    
    func getSmartReplies(id: [String: Any]?, receiverType: CometChat.ReceiverType, receiverId: String?, configuration: [String: Any]? = nil) {
        guard let receiverId = receiverId else { return }
        
        let aiReplyView = CometChatAISmartReply()
            .onMessageClicked { selectedReply in
                self.onMessageTapped(message: selectedReply, receiverType: receiverType, receiverId: receiverId, id: id)
            }
        aiReplyView.id = id
        
        if let loadingView = aiConfiguration?.loadingView {
            CometChatUIEvents.showPanel(id: id, alignment: .composerTop, view: loadingView)
        } else {
            aiReplyView.showLoadingView()
        }
        
        CometChat.getSmartReplies(receiverId: receiverId, receiverType: receiverType, configuration: configuration) { smartRepliesMap in
            DispatchQueue.main.async {
                if smartRepliesMap.isEmpty{
                    self.showEmptyRepliesView(id: id, aiReplyView: aiReplyView)
                }else{
                    if let customView = self.aiConfiguration?.customView {
                        let customView = customView(smartRepliesMap)
                        if customView == nil {
                            self.showErrorView(id: id, aiReplyView: aiReplyView)
                        } else {
                            CometChatUIEvents.showPanel(id: id, alignment: .composerTop, view: customView)
                        }
                        return
                    }
                    let replies = Array(smartRepliesMap.values)
                    aiReplyView.set(aiMessageOptions: replies)
                }
            }
        } onError: { error in
            DispatchQueue.main.async {
                debugPrint("getSmartReplies failed with error: \(String(describing: error?.errorDescription))")
                aiReplyView.hideLoadingView()
                self.showErrorView(id: id, aiReplyView: aiReplyView)
            }
        }
        
        CometChatUIEvents.showPanel(id: id, alignment: .composerTop, view: aiReplyView)
    }

    private func showEmptyRepliesView(id: [String: Any]?, aiReplyView: CometChatAISmartReply) {
        if let emptyView = aiConfiguration?.emptyRepliesView {
            CometChatUIEvents.showPanel(id: id, alignment: .composerTop, view: emptyView)
            return
        } else {
            aiReplyView.show(error: true)
        }
    }

    private func showErrorView(id: [String: Any]?, aiReplyView: CometChatAISmartReply) {
        if let errorView = aiConfiguration?.errorView {
            CometChatUIEvents.showPanel(id: id, alignment: .composerTop, view: errorView)
            return
        } else {
            aiReplyView.show(error: true)
        }
    }
    
    func onMessageTapped(message: String, receiverType: CometChat.ReceiverType, receiverId: String?, id: [String: Any]?) {
        guard let receiverId = receiverId else { return }
        let textMessage = TextMessage(receiverUid: receiverId, text: message, receiverType: receiverType)
        CometChatUIEvents.hidePanel(id: id, alignment: .composerTop)
        CometChatUIEvents.ccComposeMessage(id: id, message: textMessage)
    }
}


extension AISmartRepliesDecorator: CometChatUIEventListener {
    
    func onActiveChatChanged(id: [String : Any]?, lastMessage: CometChatSDK.BaseMessage?, user: CometChatSDK.User?, group: CometChatSDK.Group?) { 
        self.currentUser = user
        self.currentGroup = group
    }
    
}

extension AISmartRepliesDecorator: CometChatMessageEventListener {
    
    func onTextMessageReceived(textMessage: TextMessage) {
        if isErrorViewPresented {
            isErrorViewPresented = false
            CometChatUIEvents.hidePanel(id: uiEventId, alignment: .composerTop)
            CometChatMessageEvents.removeListener(eventID)
        }
    }
    
    func onMediaMessageReceived(mediaMessage: MediaMessage) {
        if isErrorViewPresented {
            isErrorViewPresented = false
            CometChatUIEvents.hidePanel(id: uiEventId, alignment: .composerTop)
            CometChatMessageEvents.removeListener(eventID)
        }
    }
    
    func onCustomMessageReceived(customMessage: CustomMessage) {
        if isErrorViewPresented {
            isErrorViewPresented = false
            CometChatUIEvents.hidePanel(id: uiEventId, alignment: .composerTop)
            CometChatMessageEvents.removeListener(eventID)
        }
    }
    
    func onFormMessageReceived(message: FormMessage) { 
        if isErrorViewPresented {
            isErrorViewPresented = false
            CometChatUIEvents.hidePanel(id: uiEventId, alignment: .composerTop)
            CometChatMessageEvents.removeListener(eventID)
        }
    }
    
    func onCardMessageReceived(message: CardMessage) { 
        if isErrorViewPresented {
            isErrorViewPresented = false
            CometChatUIEvents.hidePanel(id: uiEventId, alignment: .composerTop)
            CometChatMessageEvents.removeListener(eventID)
        }
    }
    
    func onSchedulerMessageReceived(message: SchedulerMessage) {
        if isErrorViewPresented {
            isErrorViewPresented = false
            CometChatUIEvents.hidePanel(id: uiEventId, alignment: .composerTop)
            CometChatMessageEvents.removeListener(eventID)
        }
    }
    
    func onCustomInteractiveMessageReceived(message: CustomInteractiveMessage) {
        if isErrorViewPresented {
            isErrorViewPresented = false
            CometChatUIEvents.hidePanel(id: uiEventId, alignment: .composerTop)
            CometChatMessageEvents.removeListener(eventID)
        }
    }
    
    func ccMessageSent(message: CometChatSDK.BaseMessage, status: MessageStatus) {
        if isErrorViewPresented {
            isErrorViewPresented = false
            CometChatUIEvents.hidePanel(id: uiEventId, alignment: .composerTop)
            CometChatMessageEvents.removeListener(eventID)
        }
    }
        
}
