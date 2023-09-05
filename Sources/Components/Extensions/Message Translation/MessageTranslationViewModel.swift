//
//  MessageTranslationViewModel.swift
//  
//
//  Created by Ajay Verma on 27/02/23.
//

import Foundation
import CometChatSDK

public class MessageTranslationViewModel: DataSourceDecorator {
    
    var messageTranslationConstant = ExtensionConstants.messageTranslation
    var loggedInUser = CometChat.getLoggedInUser()
    
    public override init(dataSource: DataSource) {
        super.init(dataSource: dataSource)
    }
    
    public override func getId() -> String {
        return "message-translation"
    }
    
    public override func getTextMessageBubble(messageText: String?, message: TextMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?) -> UIView? {
        if let translatedMessage = message?.metaData?["translated-message"] as? String, !translatedMessage.isEmpty {
            return super.getTextMessageBubble(messageText: translatedMessage, message: message, controller: controller, alignment: alignment, style: style)
        } else {
            return  super.getTextMessageBubble(messageText: messageText, message: message, controller: controller, alignment: alignment, style: style)
        }
    }
    
    public override func getTextMessageContentView(message: TextMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?) -> UIView? {
        return super.getTextMessageContentView(message: message, controller: controller, alignment: alignment, style: style)
    }
    
    public override func getTextMessageOptions(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]? {
        var option = super.getTextMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group)
        let translationOption = textMessageOption(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group)
        option?.append(translationOption)
        return option
    }
    
    private func textMessageOption(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?) -> CometChatMessageOption {
        return CometChatMessageOption(id: ExtensionConstants.messageTranslation, title: "TRANSLATED_MESSAGE".localize(), icon: UIImage(named: "message-translate", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage()) {  message in
            self.translateMessage(messageObject: messageObject, controller: controller)
        }
    }
}

extension MessageTranslationViewModel {
    private func translateMessage(messageObject: BaseMessage, controller: UIViewController?)  {
        var textMessage: TextMessage?
        if let message = messageObject as?  TextMessage {
            textMessage = message
            let systemLanguage = Locale.preferredLanguages.first?.replacingOccurrences(of: "-US", with: "")
            CometChat.callExtension(slug: ExtensionConstants.messageTranslation, type: .post, endPoint: "v2/translate", body: ["msgId": message.id ,"languages": [systemLanguage], "text": message.text] as [String : Any], onSuccess: { (response) in
                DispatchQueue.main.async {
                    if let response = response, let originalLanguage = response["language_original"] as? String {
                        if originalLanguage == systemLanguage {
                            let confirmDialog = CometChatDialog()
                            confirmDialog.set(messageText: "NO_TRANSLATION_AVAILABLE".localize())
                            confirmDialog.set(confirmButtonText: "OK".localize())
                            confirmDialog.open(onConfirm: {})
                        } else {
                            if let translatedLanguages = response["translations"] as? [[String:Any]] {
                                for tranlates in translatedLanguages {
                                    if let languageTranslated = tranlates["language_translated"] as? String, let messageTranslated = tranlates["message_translated"] as? String {
                                        textMessage?.metaData?.append(with: ["translated-message": messageTranslated])
                                            if let textMessage = textMessage, let messages = controller as? CometChatMessages, messageTranslated != textMessage.text {
                                                messages.messageList.update(message: textMessage)
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
            }) { (error) in
                if let error = error {
                    let confirmDialog = CometChatDialog()
                    confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                    confirmDialog.set(cancelButtonText: "CANCEL".localize())
                    confirmDialog.set(error: CometChatServerError.get(error: error))
                    confirmDialog.open(onConfirm: { [weak self] in
                        guard let strongSelf = self else { return }
                        
                    })
                }
            }
        }
    }
    
}


