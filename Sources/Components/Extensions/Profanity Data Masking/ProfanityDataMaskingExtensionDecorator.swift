//
//  ProfanityDataMaskingExtensionDecorator.swift
//  
//
//  Created by Pushpsen Airekar on 21/02/23.
//
import Foundation
import CometChatSDK

public class ProfanityDataMaskingExtensionDecorator: DataSourceDecorator {
 
    override init(dataSource: DataSource) {
        super.init(dataSource: dataSource)
    }

    public override func getTextMessageBubble(messageText: String?, message: TextMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?) -> UIView? {
        guard let message = message else { return nil }
        let filteredText = ProfanityDataMaskingExtensionDecorator.getContentText(message: message)
        return super.getTextMessageBubble(messageText: filteredText, message: message, controller: controller, alignment: alignment, style: style)
    }
    
    public static func getContentText(message: TextMessage) -> String {
        var text = checkProfanityMessage(message: message)
        if text == message.text {
            text = checkDataMasking(message: message)
        }
        return text
    }
   
    public static func checkProfanityMessage(message: TextMessage) -> String {
        var result = (message as TextMessage).text
        if let map = ExtensionModerator.extensionCheck(baseMessage: message), !map.isEmpty && map.containsKey(ExtensionConstants.profanityFilter), let profanityFilter = map[ExtensionConstants.profanityFilter], let profanity = profanityFilter["profanity"] as? String, let cleanMessage = profanityFilter["message_clean"] as? String {
            if (profanity == "no") {
                result = message.text
            } else {
                result = cleanMessage
            }
        }else {
            result = message.text
        }
        return result
    }
    
    public static func checkDataMasking(message: TextMessage) -> String {
        var result = (message as TextMessage).text
        if let map = ExtensionModerator.extensionCheck(baseMessage: message), message.sender?.uid != CometChat.getLoggedInUser()?.uid ,!map.isEmpty && map.containsKey(ExtensionConstants.dataMasking), let dataMaskingDict = map[ExtensionConstants.dataMasking], let dataMasking = dataMaskingDict["data"] as? [String:Any], let sensitiveData = dataMasking["sensitive_data"] as? String, let messageMasked = dataMasking["message_masked"] as? String {
            
            if (sensitiveData == "no") {
                result = message.text
            } else {
                result = messageMasked
            }
        }else {
            result = message.text
        }
        return result
    }
    
    public override func getId() -> String {
        return "profanity-filter"
    }
}
