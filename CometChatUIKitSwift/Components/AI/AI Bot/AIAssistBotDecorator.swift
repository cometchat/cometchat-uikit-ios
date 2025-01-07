//
//  AIAssistBotDecorator.swift
//  
//
//  Created by SuryanshBisen on 31/10/23.
//

import Foundation
import CometChatSDK

class AIAssistBotDecorator: DataSourceDecorator {
    
    var configuration: AIAssistBotConfiguration?
    let usersRequestBuilder = UsersRequest.UsersRequestBuilder()
        .set(limit: 30)
        .set(tags: ["aibot"])
        .build()
    var botList = [User]()
    weak var controller: UIViewController?
    var user: User?
    var group: Group?
    var aiAssistView: AIAssistViewController?


    init(dataSource: DataSource, configuration: AIAssistBotConfiguration?) {
        self.configuration = configuration
        
        super.init(dataSource: dataSource)
        getBotList()
    }
    
    override func getId() -> String {
        return ExtensionConstants.aiAssistBot
    }
    
    override func getAIOptions(controller: UIViewController, user: User?, group: Group?, id: [String : Any]?, aiOptionsStyle: AIOptionsStyle?) -> [CometChatMessageComposerAction]? {
        
        self.controller = controller
        self.user = user
        self.group = group
        
        var superComposerAction = super.getAIOptions(controller: controller, user: user, group: group, id: id, aiOptionsStyle: aiOptionsStyle)
        
        let botComposerAction = CometChatMessageComposerAction(
            id: getId(),
            text: "",
            startIcon: nil,
            startIconTint: nil,
            textColor: (
                aiOptionsStyle?.textColor
            ),
            textFont: (
                aiOptionsStyle?.textFont
            ),
            backgroundColour: (
                aiOptionsStyle?.backgroundColor
            ),
            borderRadius: (
                aiOptionsStyle?.cornerRadius
            ),
            borderWidth: (
                aiOptionsStyle?.borderWidth
            ),
            borderColor: (
                aiOptionsStyle?.borderColor
            )
        )
        
        if botList.count == 1 {
            botComposerAction.text = "ASK".localize() + " " + (botList[0].name ?? "")
            botComposerAction.onActionClick = { [weak self] in
                self?.startAskBot(bot: self?.botList[0])
            }
        } else if botList.count > 1 {
            botComposerAction.text = "ASK_AI_BOT".localize()
            botComposerAction.onActionClick = { [weak self] in
                self?.openBotListView(aiOptionsStyle: aiOptionsStyle)
            }
        } else {
            return superComposerAction
        }
        
        superComposerAction?.append(botComposerAction)
        return superComposerAction
    }
    
    private func openBotListView(aiOptionsStyle: AIOptionsStyle?) {
        
        
        var actionSheetItems = [ActionItem]()
        
        for bot in botList {
            //TODO: AI-flow
            
//            let actionStyle = ActionSheetStyle()
//                .set(titleColor: (
//                    configuration?.style?.buttonTextColor
//                    ?? aiOptionsStyle?.buttonTextColor
//                    ?? CometChatTheme_v4.palatte.accent
//                ))
//                .set(titleFont: (
//                    configuration?.style?.buttonTextFont
//                    ?? aiOptionsStyle?.buttonTextFont
//                    ?? CometChatTheme_v4.typography.text1
//                ))
//                .set(background: (
//                    configuration?.style?.buttonBackground
//                    ?? aiOptionsStyle?.buttonBackground
//                    ?? CometChatTheme_v4.palatte.background
//                ))
//                .set(borderColor: (
//                    configuration?.style?.buttonBorderColor
//                    ?? aiOptionsStyle?.buttonBorderColour
//                    ?? .clear
//                ))
//                .set(borderWidth: (
//                    configuration?.style?.buttonBorder
//                    ?? aiOptionsStyle?.buttonBorder
//                    ?? 0
//                ))
//                .set(cornerRadius: (
//                    configuration?.style?.buttonBorderRadius
//                    ?? aiOptionsStyle?.buttonBorderRadius
//                    ?? CometChatCornerStyle()
//                ))
                
            let actionItem = ActionItem(id: bot.uid ?? "", text: bot.name, leadingIcon: nil) { [weak self] in
                self?.startAskBot(bot: bot)
            }
            
            actionSheetItems.append(actionItem)
            
        }
        
        let aiActionSheet = CometChatActionSheet()
            .set(tableViewStyle: .plain)
            .hide(footerView: true)
        
        //TODO: AI-flow
        
        //adding style for aiOptionsStyle
//        if let cornerRadius = aiOptionsStyle?.cornerRadius {
//            aiActionSheet.set(corner: cornerRadius)
//        }
        
//        if let background = aiOptionsStyle?.background {
//            aiActionSheet.set(background: background)
//        }
        
        //adding cancel action item
//        let cancelActionStyle = ActionSheetStyle()
//            .set(titleColor: aiOptionsStyle?.cancelButtonColor ?? CometChatTheme_v4.palatte.error)
//            .set(titleFont: aiOptionsStyle?.cancelButtonFont ?? CometChatTheme_v4.typography.text1)
//            .set(background: aiOptionsStyle?.cancelBackground ?? CometChatTheme_v4.palatte.background)
//            .set(borderWidth: aiOptionsStyle?.cancelButtonBorder ?? 0)
//            .set(cornerRadius: aiOptionsStyle?.cancelButtonBorderRadius ?? CometChatCornerStyle())
//            .set(borderColor: aiOptionsStyle?.cancelButtonBorderColor ?? .clear)
        
        let cancelActionItems = ActionItem(id: "cancel-button", text: "CANCEL".localize(), leadingIcon: nil) {
            aiActionSheet.dismiss(animated: true)
        }
        actionSheetItems.append(cancelActionItems)
        aiActionSheet.set(actionItems: actionSheetItems)
        controller?.presentPanModal(aiActionSheet)
    }
    
    private func getBotList() {
        usersRequestBuilder.fetchNext { users in
            self.botList = users
        } onError: { error in
            print("fetching bot fetching failed with error: \(String(describing: error?.errorDescription))")
        }
    }
    
    private func startAskBot(bot: User?) {
        
        //adding first message for the bot
        var botFirstMessageString = "AI_BOT_FIRST_MESSAGE".localize()
        if let botFirstMessageText = configuration?.botFirstMessageText, let bot = bot {
            botFirstMessageString = botFirstMessageText(bot)
        }
        let firstMessage = TextMessage(receiverUid: CometChat.getLoggedInUser()?.uid ?? "", text: botFirstMessageString, receiverType: .user)
        (firstMessage as BaseMessage).sender = bot
        firstMessage.sentAt = Int(Date().timeIntervalSince1970)
        
        let navigationController = controller?.navigationController
        
        aiAssistView = AIAssistViewController()
            .set(closeIcon: (UIImage(systemName: "multiply")?.withRenderingMode(.alwaysTemplate) ?? UIImage()))
            .set(title: (bot?.name ?? ""))
            .add(message: firstMessage)
            .set(bot: bot)
            .set { message in
                
                self.aiAssistView?.view.endEditing(true)
                guard let textMessage = (message as? TextMessage) else { return }
                guard let loggedInUser = CometChatUIKit.getLoggedInUser() else { return }
                textMessage.sender = loggedInUser
                textMessage.metaData = ["isProcessing": true]
                textMessage.sentAt = Int(Date().timeIntervalSince1970)
                
                self.aiAssistView?.add(message: textMessage)
                
                self.askBot(bot: bot, question: textMessage.text) { assistants in
                    textMessage.metaData = nil
                    textMessage.sentAt = Int(Date().timeIntervalSince1970)
                    self.aiAssistView?.update(message: textMessage)
                    let assistTextMessage = TextMessage(receiverUid: loggedInUser.uid ?? "", text: assistants, receiverType: .user)
                    assistTextMessage.sender = bot
                    assistTextMessage.sentAt = Int(Date().timeIntervalSince1970)
                    self.aiAssistView?.add(message: assistTextMessage)
                } onError: { error in
                    textMessage.metaData = ["error": true]
                    self.aiAssistView?.update(message: textMessage)
                }
            }
                
        if #available(iOS 16.0, *) {
            if let presentationController = aiAssistView?.presentationController as? UISheetPresentationController {
                presentationController.detents = [ .custom(resolver: { context in
                    return (UIScreen.main.bounds.size.height / 2)
                })]
                presentationController.prefersGrabberVisible = true
                presentationController.prefersScrollingExpandsWhenScrolledToEdge = true
            }
        }
        
        if let aiAssistView = aiAssistView {
            navigationController?.present(aiAssistView, animated: true)
        }
        
        
    }

    private func askBot(bot: User?, question: String, onSuccess: @escaping (_ assistants: String) -> Void, onError: @escaping (_ error: CometChatSDK.CometChatException?) -> Void) {
        
        guard let botId = bot?.uid else { return }
        
        let receiverType = CometChat.ReceiverType.user
        var receiverId = ""
        if let uid = user?.uid {
            receiverId = uid
        }
        if let guid = group?.guid {
            receiverId = guid
        }
        
        if let apiConfiguration = configuration?.apiConfiguration, let bot = bot {
            apiConfiguration(bot, user, group, { [weak self] configuration in
                guard let this = self else { return }
                CometChat.askBot(receiverId: receiverId, receiverType: receiverType, botID: botId, question: question, configuration: configuration, onSuccess: onSuccess, onError: onError)
            })
            return
        }
        
        CometChat.askBot(receiverId: receiverId, receiverType: receiverType, botID: botId, question: question, onSuccess: onSuccess, onError: onError)

    }
    
}
