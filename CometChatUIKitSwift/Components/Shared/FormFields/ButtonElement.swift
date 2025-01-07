//
//  ButtonElement.swift
//  
//
//  Created by Abhishek Saralaya on 15/09/23.
//

import Foundation
import UIKit

@objc public class ButtonElement: ElementEntity {
    @objc public var buttonText = ""
    @objc public var disableAfterInteracted = true
    public var clickAction: ActionEntity?
    var action = APIAction()
    var navigationAction = URLNavigationAction()
    
    internal override init() { 
        super.init()
        self.elementType = .button
    }
    
    public init(elementID: String, clickAction: ActionEntity, buttonText: String) {
        self.clickAction = clickAction
        self.buttonText = buttonText
        super.init()
        super.elementId = elementID
        super.elementType = .button
    }
    
    @available(*, deprecated)
    public init(elementType: elementType, elementID: String, clickAction: ActionEntity, buttonText: String) {
        self.clickAction = clickAction
        self.buttonText = buttonText
        super.init()
        super.elementId = elementID
        super.elementType = .button
    }
    
    @objc public static func buttonElementFromJSON(_ data:[String:Any])-> ButtonElement? {
        
        let buttonElement = ButtonElement()
        buttonElement.elementType = (data[InteractiveConstants.ELEMENT_TYPE] as? String)?.stringValueToElementType
        if let id = data[InteractiveConstants.ELEMENT_ID] as? String {
            buttonElement.elementId = id
        }
        if let text = data[InteractiveConstants.ButtonUIConstants.BUTTONTEXT] as? String {
            buttonElement.buttonText =  text
        }
        if let action = data[InteractiveConstants.ButtonUIConstants.ACTION] as? [String:Any] {
            if let actionType = action[InteractiveConstants.ButtonUIConstants.ACTION_TYPE] as? String {
                if actionType == "apiAction" {
                    let action_ = APIAction()
                    action_.method = actionType.stringValueToHttpMethodType ?? .POST
                    action_.url = action[InteractiveConstants.ButtonUIConstants.ACTION_URL] as? String ?? ""
                    action_.headers = action[InteractiveConstants.ButtonUIConstants.ACTION_HEADERS] as? [String:String] ?? [:]
                    action_.payLoad = action[InteractiveConstants.ButtonUIConstants.ACTION_PAYLOAD] as? [String:Any] ?? [:]
                    buttonElement.action = action_
                } else {
                    let action_ = URLNavigationAction()
                    action_.url = action[InteractiveConstants.ButtonUIConstants.ACTION_URL] as? String ?? ""
                    buttonElement.navigationAction = action_
                }
            }
            
        }
        return buttonElement
    }
    
    @objc public static func buttonElementFromJSON_(_ data:[String:Any])-> ButtonElement? {
        
        let buttonElement = ButtonElement()
        buttonElement.elementType = (data[InteractiveConstants.ELEMENT_TYPE] as? String)?.stringValueToElementType
        if let id = data[InteractiveConstants.ELEMENT_ID] as? String {
            buttonElement.elementId = id
        }
        if let text = data[InteractiveConstants.ButtonUIConstants.BUTTONTEXT] as? String {
            buttonElement.buttonText =  text
        }
        if let action = data[InteractiveConstants.ButtonUIConstants.ACTION] as? [String:Any] {
            if let actionType = action[InteractiveConstants.ButtonUIConstants.ACTION_TYPE] as? String {
                if actionType == InteractiveConstants.ButtonUIConstants.ACTION_API {
                    let action_ = APIAction()
                    action_.method = actionType.stringValueToHttpMethodType ?? .POST
                    action_.url = action[InteractiveConstants.ButtonUIConstants.ACTION_URL] as? String ?? ""
                    action_.headers = action[InteractiveConstants.ButtonUIConstants.ACTION_HEADERS] as? [String:String] ?? [:]
                    action_.payLoad = action[InteractiveConstants.ButtonUIConstants.ACTION_PAYLOAD] as? [String:Any] ?? [:]
                    buttonElement.clickAction = action_
                } else {
                    let action_ = URLNavigationAction()
                    action_.url = action[InteractiveConstants.ButtonUIConstants.ACTION_URL] as? String ?? ""
                    buttonElement.clickAction = action_
                }
            }
            
        }
        return buttonElement
    }
    
    @objc func onButtonClickAction() {
        if let url = URL(string: self.action.url) {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = self.action.method.value
            if !self.action.payLoad.isEmpty {
                do {
                    let jsonAsData = try JSONSerialization.data(withJSONObject: self.action.payLoad, options: []);
                    urlRequest.httpBody = jsonAsData;
                    if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept");
                    }
                } catch  {
                    
                }
                dataTaskWith(request: urlRequest)
            }
        } else {
            
        }
    }
    
    internal func dataTaskWith(request : URLRequest) {
        
        let session = URLSession.shared;
        session.configuration.timeoutIntervalForRequest = 30
         let task = session.dataTask(with: request){ (data, response, error) -> Void in
                          
            // ensure there is data returned from this HTTP response
            guard let content = data else {
                return;
            }
            
        }
        
        task.resume();
    }
    
    public func toJSON() -> [String: Any] {
        var jsonRepresentation = [String: Any]()
        
        jsonRepresentation[InteractiveConstants.ELEMENT_TYPE] = self.elementType?.value
        jsonRepresentation[InteractiveConstants.ELEMENT_ID] = self.elementId
        jsonRepresentation[InteractiveConstants.ButtonUIConstants.BUTTONTEXT] = self.buttonText
        jsonRepresentation[InteractiveConstants.ButtonUIConstants.DISABLE_AFTER_INTERACTED] = self.disableAfterInteracted
        
        if let apiAction = self.clickAction as? APIAction {
            var actionJSON = [String: Any]()
            actionJSON[InteractiveConstants.ButtonUIConstants.ACTION_TYPE] = InteractiveConstants.ButtonUIConstants.ACTION_API
            if !apiAction.url.isEmpty {
                actionJSON[InteractiveConstants.ButtonUIConstants.ACTION_URL] = apiAction.url
            }
            if !apiAction.headers.isEmpty {
                actionJSON[InteractiveConstants.ButtonUIConstants.ACTION_HEADERS] = apiAction.headers
            }
            if !apiAction.payLoad.isEmpty {
                actionJSON[InteractiveConstants.ButtonUIConstants.ACTION_PAYLOAD] = apiAction.payLoad
            }
            actionJSON[InteractiveConstants.ButtonUIConstants.METHOD] = apiAction.method.value
            jsonRepresentation[InteractiveConstants.ButtonUIConstants.ACTION] = actionJSON
        }
        
        if let navigationAction = self.clickAction as? URLNavigationAction {
            var navigationJSON = [String: Any]()
            navigationJSON[InteractiveConstants.ButtonUIConstants.ACTION_TYPE] = "urlNavigation"
            navigationJSON[InteractiveConstants.ButtonUIConstants.ACTION_URL] = navigationAction.url
            jsonRepresentation[InteractiveConstants.ButtonUIConstants.ACTION] = navigationJSON
        }
        
        
        return jsonRepresentation
    }
}
