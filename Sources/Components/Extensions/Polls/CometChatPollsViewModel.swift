//
//  CollaborativeDocumentViewModel.swift
//  
//
//  Created by Pushpsen Airekar on 18/02/23.
//

import Foundation
import CometChatSDK

public class CometChatPollsViewModel : DataSourceDecorator {
    
    var pollsExtensionTypeConstant = ExtensionType.extensionPoll
    var configuration: PollBubbleConfiguration?
    var loggedInUser = CometChat.getLoggedInUser()
    
    public override init(dataSource: DataSource) {
        super.init(dataSource: dataSource)
    }
    
    public override func getId() -> String {
        return "polls"
    }
    
    public override func getAllMessageTypes() -> [String]? {
        var messageTypes = super.getAllMessageTypes()
        messageTypes?.append(pollsExtensionTypeConstant)
        return messageTypes
    }
    
    public override func getAllMessageCategories() -> [String]? {
        var messageCategories = super.getAllMessageCategories()
        messageCategories?.append(MessageCategoryConstants.custom)
        return messageCategories
    }
    
    public override func getAllMessageTemplates() -> [CometChatMessageTemplate] {
        var templates = super.getAllMessageTemplates()
        templates.append(getTemplate())
        return templates
    }
    
    public override func getAttachmentOptions(controller: UIViewController, user: User?, group: Group?) -> [CometChatMessageComposerAction]? {
        var actions = super.getAttachmentOptions(controller: controller, user: user, group: group)
        if let option = getAttachmentOption(controller: controller, user: user, group: group) {
            actions?.append(option)
        }
        return actions
    }
    
    public func getTemplate() -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.custom, type: pollsExtensionTypeConstant, contentView: { message, alignment, controller in
            guard let message = message as? CustomMessage else { return UIView() }
            if (message.deletedAt != 0.0) {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: message) {
                    return deletedBubble
                }
            }
            let pollsBubble = self.getContentView(_customMessage: message, controller: controller)
            return pollsBubble
            
        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let message = message else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: message, controller: controller, alignment: alignment)
        } options: { message, group, controller in
            guard let message = message, let user = LoggedInUserInformation.getUser() else { return [] }
            return ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: user, messageObject: message, controller: controller, group: group)
        }

    }

    public func getContentView(_customMessage: CustomMessage, controller: UIViewController?) -> UIView? {
        let pollsBubble = CometChatPollsBubble(frame: CGRect(x: 0, y: 0, width: 228, height: 300), message: _customMessage, isStandard: true, pollBubbleConfiguration: configuration)
        if let controller = controller {
            pollsBubble.set(controller: controller)
        }
        return pollsBubble
    }
    
    public func getAttachmentOption(controller: UIViewController?, user: User?, group: Group?) -> CometChatMessageComposerAction? {

        return CometChatMessageComposerAction(id: ExtensionConstants.polls, text: "CREATE_A_POLL".localize(), startIcon: UIImage(named: "polls.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil) {
            self.presentCreatePoll(user: user, group: group, controller: controller)
        }
    }
    
    private func presentCreatePoll(user: User?, group: Group?, controller: UIViewController?) {
        let createPoll = CometChatCreatePoll()
        if let user = user {
            createPoll.set(user: user)
        }
        if let group = group {
            createPoll.set(group: group)
        }
        let navigationController = UINavigationController(rootViewController: createPoll)
        controller?.present(navigationController, animated: true)
    }
}
