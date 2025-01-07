//
//  InteractiveUtils.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 03/01/24.
//

import Foundation
import CometChatSDK

class InteractiveUtils {
    
    static func markAsInteracted(messageId: Int, interactedElementId: String, onSuccess: @escaping (_ success: [String : Any]) -> Void, onError: @escaping (CometChatSDK.CometChatException?) -> ()) {
        CometChat.markAsInteracted(messageId: messageId, interactedElementId: interactedElementId, onSuccess: onSuccess, onError: onError)
    }
    
}

class ActionElementUtils {
    
    static func performAction(message: InteractiveMessage, buttonElement: ButtonElement?, payload: [String: Any]? = nil, controller: UINavigationController? = nil, completionHandler: @escaping ((_ success: Bool) -> Void)) {
        
        if let apiActionElement = (buttonElement?.clickAction as? APIAction), let url = URL(string: apiActionElement.url)  {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = apiActionElement.method.value
            var headers = [String: String]()
            
            if apiActionElement.headers.isEmpty {
                headers.append(with: ["Content-Type": "application/json", "Accept": "application/json"])
            } else {
                headers.append(with: apiActionElement.headers)
            }
            
            var _payLoad = [String: Any]()
            
            _payLoad[InteractiveConstants.ButtonUIConstants.APP_ID] = CometChatUIKit.uiKitSettings?.appID
            _payLoad[InteractiveConstants.ButtonUIConstants.REGION] = CometChatUIKit.uiKitSettings?.region
            _payLoad[InteractiveConstants.ButtonUIConstants.TRIGGER] = InteractiveConstants.ButtonUIConstants.UI_MESSAGE_INTERACTED
            if !apiActionElement.payLoad.isEmpty {
                _payLoad[InteractiveConstants.ButtonUIConstants.PAYLOAD] = apiActionElement.payLoad
            }
            
            var dataPayLoad = [String: Any]()
            dataPayLoad[InteractiveConstants.ButtonUIConstants.CONVERSATION_ID] = message.conversationId
            dataPayLoad[InteractiveConstants.ButtonUIConstants.SENDER] = message.senderUid
            dataPayLoad[InteractiveConstants.ButtonUIConstants.RECEIVER] = message.receiverUid
            dataPayLoad[InteractiveConstants.ButtonUIConstants.RECEIVER_TYPE] = message.receiverType == .user ? ReceiverTypeConstants.user : ReceiverTypeConstants.group
            dataPayLoad[InteractiveConstants.ButtonUIConstants.MESSAGE_CATEGORY] = MessageCategoryConstants.interactive
            dataPayLoad[InteractiveConstants.ButtonUIConstants.MESSAGE_TYPE] = message.type
            dataPayLoad[InteractiveConstants.ButtonUIConstants.MESSAGE_ID] = message.id
            dataPayLoad[InteractiveConstants.ButtonUIConstants.INTERACTION_TIMEZONE_CODE] = TimeZone.current.identifier
            dataPayLoad[InteractiveConstants.ButtonUIConstants.INTERACTED_BY] = CometChat.getLoggedInUser()?.uid
            dataPayLoad[InteractiveConstants.ButtonUIConstants.INTERACTED_ELEMENT_ID] = buttonElement?.elementId
            if let payload = payload {
                dataPayLoad.append(with: payload)
            }
            _payLoad[apiActionElement.dataKey] = dataPayLoad
                    
            NetworkUtils.requestData(url: apiActionElement.url, method: apiActionElement.method, header: headers, body: _payLoad) { data, response, error in
                
                if let response = response as? HTTPURLResponse {
                    if response.statusCode > 199 && response.statusCode < 300 {
                        completionHandler(true)
                    } else {
                        completionHandler(false)
                    }
                } else {
                    completionHandler(false)
                }
                
            }
            
        } else if let buttonElement = buttonElement, buttonElement.navigationAction.actionType == "urlNavigation", !buttonElement.navigationAction.url.isEmpty {
            let cometChatWebView = CometChatWebView()
            cometChatWebView.set(webViewType: .none)
                .set(url: buttonElement.navigationAction.url)
                .set(title: buttonElement.buttonText)
            controller?.navigationController?.pushViewController(cometChatWebView, animated: true)
        }
    }
}
