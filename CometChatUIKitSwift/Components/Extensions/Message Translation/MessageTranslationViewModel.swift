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
    
    public override func getTextMessageBubble(messageText: String?, message: TextMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        if let translatedMessage = message?.metaData?["translated-message"] as? String, !translatedMessage.isEmpty {
            return buildTextMessageContentView(messageText: translatedMessage, message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
        } else {
            return super.getTextMessageBubble(messageText: messageText, message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
        }
    }
    
    public override func getTextMessageOptions(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]? {
        var option = super.getTextMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group)
        let translationOption = textMessageOption(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group)
        option?.append(translationOption)
        return option
    }
    
    func buildTextMessageContentView(messageText: String?, message: TextMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView {
        
        let formatter = additionalConfiguration?.textFormatter ?? []
        let translatedTextBubble = CometChatMessageTranslationBubble()
        
        if let translatedMessage = message?.metaData?["translated-message"] as? String, !translatedMessage.isEmpty {
            let originalMessageString = "\(message?.text ?? "")"
            
            let translatedMessage = MessageUtils.processTextFormatter(for: message, customText: translatedMessage, in: translatedTextBubble.translatedMessageLabel, textFormatter: formatter, controller: controller, alignment: alignment) ?? NSAttributedString(string: translatedMessage)
            
            let originalMessage = MessageUtils.processTextFormatter(for: message, customText: originalMessageString, in: translatedTextBubble.originalMessageLabel, textFormatter: formatter, controller: controller, alignment: alignment) ?? NSAttributedString(string: "\(message?.text ?? "")")
            
            translatedTextBubble.set(originalMessage: originalMessage, translatedMessage: translatedMessage)
            
            let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message?.senderUid)
            let messageBubbleStyle = isLoggedInUser ? additionalConfiguration?.messageBubbleStyle.outgoing : additionalConfiguration?.messageBubbleStyle.incoming
            if let style = messageBubbleStyle?.messageTranslationBubbleStyle {
                translatedTextBubble.style = style
            }
        }
        return translatedTextBubble
    }
    
    private func textMessageOption(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?) -> CometChatMessageOption {
        return CometChatMessageOption(id: ExtensionConstants.messageTranslation, title: "TRANSLATE_MESSAGE".localize(), icon: AssetConstants.translate) {  message in
            self.translateMessage(messageObject: messageObject, controller: controller)
        }
    }
}

extension MessageTranslationViewModel {
    
    private func openCometChatDialog() {
        let confirmDialog = CometChatDialog()
        confirmDialog.set(messageText: "NO_TRANSLATION_AVAILABLE".localize())
        confirmDialog.set(confirmButtonText: "OK".localize())
        confirmDialog.open(onConfirm: {})
    }
    
    private func translateMessage(messageObject: BaseMessage, controller: UIViewController?)  {
        var textMessage: TextMessage?
        if let message = messageObject as?  TextMessage {
            textMessage = message
            let systemLanguage = Locale.preferredLanguages.first?.replacingOccurrences(of: "-US", with: "")
            
            let spannedStringForMention = MessageUtils.wrapRegexMatches(in: textMessage?.text ?? "", regexPattern: CometChatMentionsFormatter().getRegex())
            
            CometChat.callExtension(slug: ExtensionConstants.messageTranslation, type: .post, endPoint: "v2/translate", body: ["msgId": message.id ,"languages": [systemLanguage], "text": spannedStringForMention] as [String : Any], onSuccess: { (response) in
                DispatchQueue.main.async {
                    if let response = response, let originalLanguage = response["language_original"] as? String {
                        if originalLanguage == systemLanguage {
                            self.openCometChatDialog()
                        } else {
                            if let translatedLanguages = response["translations"] as? [[String:Any]] {
                                for tranlates in translatedLanguages {
                                    if let languageTranslated = tranlates["language_translated"] as? String,
                                        let messageTranslated = tranlates["message_translated"] as? String
                                    {
                                        if var metaData = textMessage?.metaData {
                                            metaData.append(with: ["translated-message": MessageUtils.removeSpanWrapping(in: messageTranslated)])
                                            textMessage?.metaData = metaData
                                        } else {
                                            textMessage?.metaData = ["translated-message": MessageUtils.removeSpanWrapping(in: messageTranslated)]
                                        }
                                        if let textMessage = textMessage {
                                            CometChatMessageEvents.onMessageEdited(message: textMessage)
                                        } else {
                                            self.openCometChatDialog()
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


