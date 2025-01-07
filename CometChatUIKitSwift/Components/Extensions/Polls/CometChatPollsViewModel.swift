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
    
    public override func getLastConversationMessage(conversation: Conversation, isDeletedMessagesHidden: Bool, additionalConfiguration: AdditionalConfiguration?) -> NSAttributedString? {
        if let customMessage = conversation.lastMessage as? CustomMessage, let additionalConfiguration {
            if customMessage.type == MessageTypeConstants.poll {
                return addImageToText(text: ConversationConstants.customMessagePoll, image: "messages-poll", additionalConfiguration: additionalConfiguration)
            }
        }
        return super.getLastConversationMessage(conversation: conversation, isDeletedMessagesHidden: isDeletedMessagesHidden, additionalConfiguration: additionalConfiguration)
    }
    
    public override func getAllMessageTemplates(additionalConfiguration: AdditionalConfiguration?) -> [CometChatMessageTemplate] {
        var templates = super.getAllMessageTemplates(additionalConfiguration: additionalConfiguration)
        templates.append(getTemplate(additionalConfiguration: additionalConfiguration))
        return templates
    }
    
    public override func getAttachmentOptions(controller: UIViewController, user: User?, group: Group?, id: [String: Any]?) -> [CometChatMessageComposerAction]? {
        var actions = super.getAttachmentOptions(controller: controller, user: user, group: group, id: id)
        if id?[MessagesConstants.parentMessageId] == nil {
            if let option = getAttachmentOption(controller: controller, user: user, group: group) {
                actions?.append(option)
            }
        }
        return actions
    }
    
    public override func getMessageTemplate(messageType: String, messageCategory: String, additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate? {
        if messageType == MessageCategoryConstants.custom && messageCategory == pollsExtensionTypeConstant {
            return getTemplate(additionalConfiguration: additionalConfiguration)
        }
        return super.getMessageTemplate(messageType: messageType, messageCategory: messageCategory)
    }
    
    public func getTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.custom, type: pollsExtensionTypeConstant, contentView: { message, alignment, controller in
            guard let message = message as? CustomMessage else { return UIView() }
            if (message.deletedAt != 0.0) {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: message, additionalConfiguration: additionalConfiguration) {
                    return deletedBubble
                }
            }
            let pollsBubble = self.getContentView(_customMessage: message, controller: controller, additionalConfiguration: additionalConfiguration)
            return pollsBubble
            
        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let message = message else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: message, controller: controller, alignment: alignment)
        } options: { message, group, controller in
            guard let message = message, let user = LoggedInUserInformation.getUser() else { return [] }
            return ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: user, messageObject: message, controller: controller, group: group)
        }

    }

    public func getContentView(_customMessage: CustomMessage, controller: UIViewController?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        let pollsBubble = CometChatPollsBubble()
        pollsBubble.pin(anchors: [.width], to: 240)
        
        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: _customMessage.senderUid)
        let messageBubbleStyle = isLoggedInUser ? additionalConfiguration?.messageBubbleStyle.outgoing : additionalConfiguration?.messageBubbleStyle.incoming
        if let style = messageBubbleStyle?.pollBubbleStyle {
            pollsBubble.style = style
        }
        
        pollsBubble.set(pollMessage: _customMessage)
        if let controller = controller {
            pollsBubble.set(controller: controller)
        }
        return pollsBubble
    }
    
    public func getAttachmentOption(controller: UIViewController?, user: User?, group: Group?) -> CometChatMessageComposerAction? {

        return CometChatMessageComposerAction(id: ExtensionConstants.polls, text: "CREATE_A_POLL".localize(), startIcon: UIImage(named: "polls.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil)
        { [weak self, weak controller] in
            guard let this = self else { return }
            this.presentCreatePoll(user: user, group: group, controller: controller)
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
        controller?.present(navigationController, animated: true, completion: nil)
    }
}
