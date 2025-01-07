//
//  CollaborativeDocumentViewModel.swift
//  
//
//  Created by Pushpsen Airekar on 18/02/23.
//

import Foundation
import CometChatSDK

public class CollaborativeWhiteboardViewModel : DataSourceDecorator {
    
    var collaborativeWhiteboardExtensionTypeConstant = ExtensionType.whiteboard
    var configuration: CollaborativeWhiteboardBubbleConfiguration?
    var loggedInUser = CometChat.getLoggedInUser()
    
    public override init(dataSource: DataSource) {
        super.init(dataSource: dataSource)
    }
    
    public override func getId() -> String {
        return "whiteboard"
    }
    
    public override func getAllMessageTypes() -> [String]? {
        var messageTypes = super.getAllMessageTypes()
        messageTypes?.append(collaborativeWhiteboardExtensionTypeConstant)
        return messageTypes
    }
    
    public override func getAllMessageCategories() -> [String]? {
        var messageCategories = super.getAllMessageCategories()
        messageCategories?.append(MessageCategoryConstants.custom)
        return messageCategories
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
    
    public override func getLastConversationMessage(conversation: Conversation, isDeletedMessagesHidden: Bool, additionalConfiguration: AdditionalConfiguration?) -> NSAttributedString? {
        if let customMessage = conversation.lastMessage as? CustomMessage, let additionalConfiguration {
            if customMessage.type == MessageTypeConstants.whiteboard {
                return addImageToText(text: ConversationConstants.customMessageWhiteboard, image: "collaborative-message-icon", additionalConfiguration: additionalConfiguration)
            }
        }
        return super.getLastConversationMessage(conversation: conversation, isDeletedMessagesHidden: isDeletedMessagesHidden, additionalConfiguration: additionalConfiguration)
    }
    
    public func getTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.custom, type: collaborativeWhiteboardExtensionTypeConstant, contentView: { [weak self] message, alignment, controller in
            
            guard let this = self else { return nil }
            guard let message = message as? CustomMessage else { return UIView() }
            if (message.deletedAt != 0.0) {
                if let deletedBubble = this.getDeleteMessageBubble(messageObject: message, additionalConfiguration: additionalConfiguration) {
                    return deletedBubble
                }
            }
            let documentBubble = this.getContentView(_customMessage: message, controller: controller, additionalConfiguration: additionalConfiguration)
            return documentBubble
            
        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let message = message else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: message, controller: controller, alignment: alignment)
        } options: { message, group, controller in
            guard let message = message, let user = LoggedInUserInformation.getUser() else { return [] }
            return ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: user, messageObject: message, controller: controller, group: group)
        }

    }
    
    public override func getMessageTemplate(messageType: String, messageCategory: String, additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate? {
        if messageType == MessageCategoryConstants.custom && messageCategory == collaborativeWhiteboardExtensionTypeConstant {
            return getTemplate(additionalConfiguration: additionalConfiguration)
        }
        return super.getMessageTemplate(messageType: messageType, messageCategory: messageCategory)
    }

    public func getContentView(_customMessage: CustomMessage, controller: UIViewController?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        
        let whiteboardBubble = CometChatCollaborativeBubble(frame: .null, message: _customMessage)
            .set(title: "COLLABORATIVE_WHITEBOARD".localize())
            .set(subTitle: "OPEN_WHITEBOARD_TO_DRAW_TOGETHER".localize())
            .set(buttonText: "OPEN_WHITEBOARD".localize())
            .set(onOpenButtonClicked: { [weak _customMessage, weak controller] in
                if let controller = controller , let customMessage = _customMessage {
                    controller.navigationController?.navigationBar.isHidden = false
                    if let metaData = customMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected[ExtensionConstants.extensions] as? [String : Any], let collaborativeDictionary = cometChatExtension[ExtensionConstants.whiteboard] as? [String : Any], let collaborativeURL =  collaborativeDictionary["board_url"] as? String {
                        
                        let cometChatWebView = CometChatWebView()
                        cometChatWebView.set(webViewType: .whiteboard)
                        cometChatWebView.set(url: collaborativeURL)
                        controller.navigationController?.pushViewController(cometChatWebView, animated: true)
                    }
                }
            })
        
        whiteboardBubble.topImage = UIImage(named: "collaborative-white-board-image", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysOriginal)

        
        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: _customMessage.senderUid)
        let messageBubbleStyle = isLoggedInUser ? additionalConfiguration?.messageBubbleStyle.outgoing : additionalConfiguration?.messageBubbleStyle.incoming
        if let style = messageBubbleStyle?.collaborativeWhiteboardBubbleStyle {
            whiteboardBubble.style = style
        }

        whiteboardBubble.pin(anchors: [.width], to: 228)
        whiteboardBubble.pin(anchors: [.height], to: 145)
        
        return whiteboardBubble
    }
    
    public func getAttachmentOption(controller: UIViewController?, user: User?, group: Group?) -> CometChatMessageComposerAction? {

        return CometChatMessageComposerAction(id: ExtensionConstants.whiteboard, text: "COLLABORATIVE_WHITEBOARD".localize(), startIcon: UIImage(named: "collaborative-whiteboard.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil) { [weak self, weak controller] in
            guard let this = self else { return }
            this.sentWhiteboard(user: user, group: group, controller: controller)
        }
    }
    
    private func sentWhiteboard(user: User?, group: Group?, controller: UIViewController?) {
        if let group = group {
            CometChat.callExtension(slug: ExtensionConstants.whiteboard, type: .post, endPoint: ExtensionUrls.whiteboard, body: ["receiver":group.guid,"receiverType":"group"], onSuccess: { (response) in
                
            }) { (error) in
                if let error = error {
                    DispatchQueue.main.async {
                        let confirmDialog = CometChatDialog()
                        confirmDialog.set(confirmButtonText: "OK".localize())
                        confirmDialog.set(cancelButtonText: "CANCEL".localize())
                        confirmDialog.set(error: CometChatServerError.get(error: error))
                        confirmDialog.open(onConfirm: {
                        })
                    }
                }
            }
        } else if let user = user {
            CometChat.callExtension(slug: ExtensionConstants.whiteboard, type: .post, endPoint:  ExtensionUrls.whiteboard, body: ["receiver":user.uid ?? "","receiverType":"user"], onSuccess: { (response) in
                
            }) { (error) in
                if let error = error {
                    DispatchQueue.main.async {
                        let confirmDialog = CometChatDialog()
                        confirmDialog.set(confirmButtonText: "OK".localize())
                        confirmDialog.set(cancelButtonText: "CANCEL".localize())
                        confirmDialog.set(error: CometChatServerError.get(error: error))
                        confirmDialog.open(onConfirm: {
                        })
                    }
                }
            }
        }
    }
}
