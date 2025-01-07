//
//  CollaborativeDocumentViewModel.swift
//  
//
//  Created by Pushpsen Airekar on 18/02/23.
//

import Foundation
import CometChatSDK

public class CollaborativeDocumentViewModel : DataSourceDecorator {
    
    var collaborativeDocumentExtensionTypeConstant = ExtensionType.document
    var configuration: CollaborativeDocumentBubbleConfiguration?
    var loggedInUser = CometChat.getLoggedInUser()
    
    public override init(dataSource: DataSource) {
        super.init(dataSource: dataSource)
    }
    
    public override func getId() -> String {
        return "document"
    }
    
    public override func getAllMessageTypes() -> [String]? {
        var messageTypes = super.getAllMessageTypes()
        messageTypes?.append(collaborativeDocumentExtensionTypeConstant)
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
            if let action = getAttachmentOption(controller: controller, user: user, group: group) {
                actions?.append(action)
            }
        }
        return actions
    }
    
    public override func getLastConversationMessage(conversation: Conversation, isDeletedMessagesHidden: Bool, additionalConfiguration: AdditionalConfiguration?) -> NSAttributedString? {
        if let customMessage = conversation.lastMessage as? CustomMessage, let additionalConfiguration {
            if customMessage.type == MessageTypeConstants.document {
                return addImageToText(text: ConversationConstants.customMessageDocument, image: "collaborative-document-message", additionalConfiguration: additionalConfiguration)
            }
        }
        return super.getLastConversationMessage(conversation: conversation, isDeletedMessagesHidden: isDeletedMessagesHidden, additionalConfiguration: additionalConfiguration)
    }
    
    public override func getMessageTemplate(messageType: String, messageCategory: String, additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate? {
        if messageType == MessageCategoryConstants.custom && messageCategory == collaborativeDocumentExtensionTypeConstant {
            return getTemplate(additionalConfiguration: additionalConfiguration)
        }
        return super.getMessageTemplate(messageType: messageType, messageCategory: messageCategory)
    }
    
    public func getTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.custom, type: collaborativeDocumentExtensionTypeConstant, contentView: { message, alignment, controller in
            guard let message = message as? CustomMessage else { return UIView() }
            if (message.deletedAt != 0.0) {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: message, additionalConfiguration: additionalConfiguration) {
                    return deletedBubble
                }
            }
            
            let documentBubble = self.getContentView(_customMessage: message, controller: controller, additionalConfiguration: additionalConfiguration)
            return documentBubble
            
        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let message = message else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: message, controller: controller, alignment: alignment)
        } options: { message, group, controller in
            guard let message = message, let user = LoggedInUserInformation.getUser() else { return [] }
            return ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: user, messageObject: message, controller: controller, group: group)
        }

    }

    
    public func getContentView(_customMessage: CustomMessage, controller: UIViewController?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        
        let documentBubble = CometChatCollaborativeBubble(frame: .null, message: _customMessage).withoutAutoresizingMaskConstraints()
            .set(title: "COLLABORATIVE_DOCUMENT".localize())
            .set(subTitle: "OPEN_DOCUMENT_TO_EDIT_CONTENT_TOGETHER".localize())
            .set(buttonText: "OPEN_DOCUMENT".localize())
            .set { [weak _customMessage, weak controller] in
                if let controller = controller , let customMessage = _customMessage {
                    if let metaData = customMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected[ExtensionConstants.extensions] as? [String : Any], let collaborativeDictionary = cometChatExtension[ExtensionConstants.document] as? [String : Any], let collaborativeURL = collaborativeDictionary["document_url"] as? String {
                        
                        let cometChatWebView = CometChatWebView()
                        cometChatWebView.set(webViewType: .document)
                            .set(url: collaborativeURL)
                        controller.navigationController?.pushViewController(cometChatWebView, animated: true)
                        
                    }
                }
            }
        
        documentBubble.pin(anchors: [.width], to: 228)
        documentBubble.pin(anchors: [.height], to: 145)
        
        documentBubble.topImage = UIImage(named: "collaborative-document-image", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        
        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: _customMessage.senderUid)
        let messageBubbleStyle = isLoggedInUser ? additionalConfiguration?.messageBubbleStyle.outgoing : additionalConfiguration?.messageBubbleStyle.incoming
        if let style = messageBubbleStyle?.collaborativeWhiteboardBubbleStyle {
            documentBubble.style = style
        }
        
        return documentBubble
    }
    
    public func getAttachmentOption(controller: UIViewController?, user: User?, group: Group?) -> CometChatMessageComposerAction? {
        return CometChatMessageComposerAction(id: ExtensionConstants.document, text: "COLLABORATIVE_DOCUMENT".localize(), startIcon: UIImage(named: "collaborative-document.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil) { [weak self] in
            guard let this = self else { return }
            this.sentDocument(user: user, group: group)
        }
    }
    
    private func sentDocument(user: User?, group: Group?) {
        if let group = group {
            CometChat.callExtension(slug: ExtensionConstants.document, type: .post, endPoint: ExtensionUrls.document, body: ["receiver":group.guid,"receiverType":"group"], onSuccess: { (response) in
                
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
            CometChat.callExtension(slug: ExtensionConstants.document, type: .post, endPoint:  ExtensionUrls.document, body: ["receiver":user.uid ?? "","receiverType":"user"], onSuccess: { (response) in
                
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
