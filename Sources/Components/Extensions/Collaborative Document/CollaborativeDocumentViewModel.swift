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
    
    public override func getAllMessageTemplates() -> [CometChatMessageTemplate] {
        var templates = super.getAllMessageTemplates()
        templates.append(getTemplate())
        return templates
    }
    
    public override func getAttachmentOptions(controller: UIViewController, user: User?, group: Group?) -> [CometChatMessageComposerAction]? {
        var actions = super.getAttachmentOptions(controller: controller, user: user, group: group)
        if let action = getAttachmentOption(controller: controller, user: user, group: group) {
            actions?.append(action)
        }
        return actions
    }
    
    public func getTemplate() -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.custom, type: collaborativeDocumentExtensionTypeConstant, contentView: { message, alignment, controller in
            guard let message = message as? CustomMessage else { return UIView() }
            if (message.deletedAt != 0.0) {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: message) {
                    return deletedBubble
                }
            }
            
            let documentBubble = self.getContentView(_customMessage: message, controller: controller)
            return documentBubble
            
        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let message = message else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: message, controller: controller, alignment: alignment)
        } options: { message, group, controller in
            guard let message = message, let user = LoggedInUserInformation.getUser() else { return [] }
            return ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: user, messageObject: message, controller: controller, group: group)
        }

    }

    
    public func getContentView(_customMessage: CustomMessage, controller: UIViewController?) -> UIView? {
        let documentBubble = CometChatDocumentBubble(frame: CGRect(x: 0, y: 0, width: 228, height: 145), message: _customMessage, collaborativeDocumentBubbleConfiguration: configuration)
        documentBubble.set(customMessage: _customMessage)
        if let controller = controller {
            documentBubble.set(controller: controller)
        }
        return documentBubble
    }
    
    public func getAttachmentOption(controller: UIViewController?, user: User?, group: Group?) -> CometChatMessageComposerAction? {
        return CometChatMessageComposerAction(id: ExtensionConstants.document, text: "COLLABORATIVE_DOCUMENT".localize(), startIcon: UIImage(named: "collaborative-document.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil) {
            self.sentDocument(user: user, group: group)
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
