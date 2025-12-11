//
//  CollaborativeDocumentViewModel.swift
//  
//
//  Created by Pushpsen Airekar on 18/02/23.
//

import Foundation
import CometChatSDK

public class CollaborativeDocumentViewModel : DataSourceDecorator, CometChatMessageEventListener {
    
    var collaborativeDocumentExtensionTypeConstant = ExtensionType.document
    var configuration: CollaborativeDocumentBubbleConfiguration?
    var loggedInUser = CometChat.getLoggedInUser()
    
    var eventID = Date().timeIntervalSince1970
    var quotedMessageId: Int?
    var quotedMessage: BaseMessage?
    
    public override init(dataSource: DataSource) {
        super.init(dataSource: dataSource)
        CometChatMessageEvents.addListener("collaborative-document-listener-\(eventID)", self)
    }
    
    deinit {
        CometChatMessageEvents.removeListener("collaborative-document-listener-\(eventID)")
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
    
    public override func getAttachmentOptions(controller: UIViewController, user: User?, group: Group?, id: [String: Any]?, additionalConfiguration: AdditionalConfiguration = AdditionalConfiguration()) -> [CometChatMessageComposerAction]? {
        var actions = super.getAttachmentOptions(controller: controller, user: user, group: group, id: id, additionalConfiguration: additionalConfiguration)
        if id?[MessagesConstants.parentMessageId] == nil {
            if let action = getAttachmentOption(controller: controller, user: user, group: group) {
                if !additionalConfiguration.hideCollaborativeDocumentOption{
                    actions?.append(action)
                }
            }
        }
        return actions
    }
    
    public override func getLastConversationMessage(conversation: Conversation, additionalConfiguration: AdditionalConfiguration?) -> NSAttributedString? {
        if let customMessage = conversation.lastMessage as? CustomMessage, let additionalConfiguration {
            if customMessage.type == MessageTypeConstants.document && customMessage.deletedAt == 0.0 {
                return addImageToText(text: ConversationConstants.customMessageDocument, image: "collaborative-document-message", additionalConfiguration: additionalConfiguration)
            }else if customMessage.deletedAt > 0.0{
                return addImageToText(text: ConversationConstants.thisMessageDeleted, image: "deleted-message", additionalConfiguration: additionalConfiguration)
            }
        }
        return super.getLastConversationMessage(conversation: conversation, additionalConfiguration: additionalConfiguration)
    }
    
    public override func getMessageTemplate(messageType: String, messageCategory: String, additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate? {
        if messageType == MessageCategoryConstants.custom && messageCategory == collaborativeDocumentExtensionTypeConstant {
            return getTemplate(additionalConfiguration: additionalConfiguration)
        }
        return super.getMessageTemplate(messageType: messageType, messageCategory: messageCategory, additionalConfiguration: additionalConfiguration)
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
            return ChatConfigurator.getDataSource().getBottomView(message: message, controller: controller, alignment: alignment, additionalConfiguration: additionalConfiguration)
        } options: { message, group, controller in
            guard let message = message, let user = LoggedInUserInformation.getUser() else { return [] }
            return ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: user, messageObject: message, controller: controller, group: group, additionalConfiguration: additionalConfiguration ?? AdditionalConfiguration())
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
        
        var body = [String: Any]()
        
        if let quotedMessage = quotedMessage {
            body.append(with: ["quotedMessage": quotedMessage.rawMessage ?? [:]])
        }
        if let id = quotedMessageId {
            body.append(with: ["quotedMessageId": id])
        }
        
        if let group = group {
            body.append(with: ["receiver":group.guid,"receiverType":"group"])
            CometChat.callExtension(slug: ExtensionConstants.document, type: .post, endPoint: ExtensionUrls.document, body: body, onSuccess: { (response) in
                if let mssg = self.quotedMessage {
                    CometChatMessageEvents.ccReplyToMessage(message: mssg, status: .success)
                }
                self.quotedMessage = nil
                self.quotedMessageId = nil
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
            body.append(with: ["receiver":user.uid ?? "","receiverType":"user"])
            CometChat.callExtension(slug: ExtensionConstants.document, type: .post, endPoint:  ExtensionUrls.document, body: body, onSuccess: { (response) in
                if let mssg = self.quotedMessage {
                    CometChatMessageEvents.ccReplyToMessage(message: mssg, status: .success)
                }
                self.quotedMessage = nil
                self.quotedMessageId = nil
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
    
    public func ccReplyToMessage(message: BaseMessage, status: MessageStatus) {
        if message.deletedAt <= 0 {
            switch status {
            case .inProgress:
                quotedMessageId = message.id
                quotedMessage = message
            case .success, .error:
                quotedMessageId = nil
                quotedMessage = nil
            }
        }
    }
}
