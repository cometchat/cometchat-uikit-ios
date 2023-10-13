//
//  AIExtensionsDecorator.swift
//  
//
//  Created by SuryanshBisen on 12/09/23.
//

import Foundation
import CometChatSDK

protocol AICommunicatorProtocol {
    func onRepliesButtonChosen()
    func isViewStillPresented() -> Bool
}

class AIEnablerDecorator: DataSourceDecorator {
    
    private var options: [(String, AIParentRepliesStyle?)] = []
    private var enabledAiOptions: [ExtensionDataSource]
    private var isAIViewOpen = false
    private var configuration: AIEnablerConfiguration?
    private var eventID = "ai-conversation-starters"
    private var smartRepliesHelper = AISmartRepliesHelper()
    private var optionsViewRawVC: AIAvailableOptionsView?

    
    public init(dataSource: DataSource, enabledAiOptions: [ExtensionDataSource], configuration: AIEnablerConfiguration? = nil) {
        
        self.enabledAiOptions = enabledAiOptions
        self.configuration = configuration
        
        super.init(dataSource: dataSource)
        self.connect()

        smartRepliesHelper.aiDelegate = self
        
        for aiExtension in enabledAiOptions {
            
            if let smartReplies = (aiExtension as? CometChatAISmartRepliesExtension) {
                smartRepliesHelper.set(configuration: smartReplies.getConfiguration())
                smartRepliesHelper.set(enablerConfiguration: configuration)
                options.append((smartReplies.getExtensionText(), smartReplies.getConfiguration()?.style))
            }
            
        }
        
    }
    
    deinit {
        disconnect()
    }
        
    func connect() {
        CometChatUIEvents.addListener(eventID, self)
    }
    
    func disconnect() {
        CometChatUIEvents.removeListener(eventID)
        CometChatMessageEvents.removeListener(eventID)
    }
    
    override func getAuxiliaryOptions(user: User?, group: Group?, controller: UIViewController?, id: [String : Any]?) -> UIView? {
        
        if options.count == 0 {
            return super.getAuxiliaryOptions(user: user, group: group, controller: controller, id: id)
        }
        
        var auxiliaryButtons = [UIView]()
        auxiliaryButtons.append(getAIAuxiliaryButton(user: user, group: group, controller: controller, id: id))
        if let view = super.getAuxiliaryOptions(user: user, group: group, controller: controller, id: id) {
            auxiliaryButtons.append(view)
        }
        
        return UIStackView(arrangedSubviews: auxiliaryButtons)
    }
    
    override func getId() -> String {
        return ExtensionConstants.aiExtension
    }
    
    public func getAIAuxiliaryButton(user: User?, group: Group?, controller: UIViewController?, id: [String: Any]?) -> UIView {
        
        let aiAuxillaryButton = AIAuxiliaryButton()
        aiAuxillaryButton.buildFromConfiguration(configuration: configuration)
        
        aiAuxillaryButton.setOnAIButtonTap { [weak self] in
            self?.openAllAiOptions(controller: controller, id: id)
        }
        
        return aiAuxillaryButton
    }
    
    func openAllAiOptions(controller: UIViewController?, id: [String: Any]?) {
        
        if isAIViewOpen == true {
            isAIViewOpen = false
            CometChatUIEvents.emitHidePanel(id: id, alignment: .composerBottom)
            return
        }
        
        optionsViewRawVC = AIAvailableOptionsView()
        if let optionsViewRawVC = optionsViewRawVC {
            optionsViewRawVC.set(optionList: options)
            optionsViewRawVC.buildFrom(enablerStyle: configuration?.style)
            optionsViewRawVC.onOptionSelected { selectedOption in
                self.onAiOptionSelected(option: selectedOption, controller: self.optionsViewRawVC, id: id)
            }
            controller?.presentPanModal(optionsViewRawVC)
        }
        
    }
    
    func onAiOptionSelected(option: String, controller: UIViewController?, id: [String: Any]?){
        
        controller?.dismiss(animated: true, completion: {
            
            self.isAIViewOpen = true
            
            var receiverType: CometChat.ReceiverType = .user
            var receiverId: String? = ""
            
            if let guid = id?["guid"] {
                receiverType = .group
                receiverId = guid as? String
            } else if let uid = id?["uid"] {
                receiverType = .user
                receiverId = uid as? String
            }
            
            switch AIExtension.fromKey(option){
            case .smartReplies:
                self.smartRepliesHelper.presentSmartReplies(id: id, receiverType: receiverType, receiverId: receiverId)
                break
            case .none:
                break
            }
        })
        
    }
    
}


extension AIEnablerDecorator: CometChatUIEventListener {
    func showPanel(id: [String : Any]?, alignment: UIAlignment, view: UIView?) { }
    
    func hidePanel(id: [String : Any]?, alignment: UIAlignment) {   }
    
    func onActiveChatChanged(id: [String : Any]?, lastMessage: CometChatSDK.BaseMessage?, user: CometChatSDK.User?, group: CometChatSDK.Group?) {
        
        smartRepliesHelper.set(currentUser: user)
        smartRepliesHelper.set(currentGroup: group)
        
        isAIViewOpen = false
        
    }
    
    func ccComposeMessage(id: [String : Any]?, message: CometChatSDK.BaseMessage) { }
    
    func openChat(user: CometChatSDK.User?, group: CometChatSDK.Group?) {   }
    
    
}


extension AIEnablerDecorator: AICommunicatorProtocol {
    func isViewStillPresented() -> Bool {
        return isAIViewOpen
    }
    
    func onRepliesButtonChosen() {
        isAIViewOpen = false
    }
    
    
}


 
