//
//  FormMessage.swift
//  
//
//  Created by Admin on 15/09/23.
//

import Foundation
import CometChatSDK
import UIKit

@objc public class FormMessage: InteractiveMessage {
    private var title:String?
    private var formFields:[ElementEntity]?
    private var submitElement:ButtonElement?
    private var goalCompletionText:String?
    
//    public func createFormField() {
//        interactiveMessage?.interactiveData
//    }
    
    public override init() {
        super.init()
        type = MessageTypeConstants.form
    }
    
    init(title: String, receiverUid: String, receiverType: CometChat.ReceiverType, formFields: [ElementEntity], submitElement: ButtonElement) {
        super.init()
        setTitle(title)
        setFormFields(formFields)
        setSubmitElement(submitElement)
        super.receiverUid = receiverUid
        super.receiverType = receiverType
        super.type = MessageTypeConstants.form
    }
    
    public func getFormFields() -> [ElementEntity] {
        return self.formFields ?? [ElementEntity]()
    }
    
    public func setFormFields(_ formFields: [ElementEntity]) {
        self.formFields = formFields
    }
    
    public func getTitle() -> String {
        return self.title ?? ""
    }
    
    public func setTitle(_ title: String) {
        self.title = title
    }
    
    public func getGoalCompletionText() -> String {
        return self.goalCompletionText ?? ""
    }
    
    public func setGoalCompletionText(_ text: String) {
        self.goalCompletionText = text
    }
    
    public func getSubmitElement() -> ButtonElement {
        return self.submitElement ?? ButtonElement()
    }
    
    public func setSubmitElement(_ submitElement: ButtonElement) {
        self.submitElement = submitElement
    }
    
    public static func toFormMessage(_ interactiveMessage: InteractiveMessage) -> FormMessage {
        let formMessage = FormMessage()
        formMessage.type = MessageTypeConstants.form
        formMessage.id = interactiveMessage.id
        formMessage.receiverType = interactiveMessage.receiverType
        formMessage.receiver = interactiveMessage.receiver
        formMessage.sender = interactiveMessage.sender
        formMessage.senderUid = interactiveMessage.senderUid
        formMessage.sentAt = interactiveMessage.sentAt
        formMessage.readAt = interactiveMessage.readAt
        formMessage.deliveredAt = interactiveMessage.deletedAt
        formMessage.updatedAt = interactiveMessage.updatedAt
        formMessage.deletedBy = interactiveMessage.deletedBy
        formMessage.interactionGoal = interactiveMessage.interactionGoal
        formMessage.metaData = interactiveMessage.metaData
        formMessage.muid = interactiveMessage.muid
        formMessage.rawMessage = interactiveMessage.rawMessage
        formMessage.conversationId = interactiveMessage.conversationId
        formMessage.readByMeAt = interactiveMessage.readByMeAt
        formMessage.receiverUid = interactiveMessage.receiverUid
        formMessage.replyCount = interactiveMessage.replyCount
        formMessage.tags = interactiveMessage.tags
        formMessage.allowSenderInteraction = interactiveMessage.allowSenderInteraction
        formMessage.interactions = interactiveMessage.interactions
        formMessage.reactions = interactiveMessage.reactions
        formMessage.mentionedMe = interactiveMessage.mentionedMe
        formMessage.mentionedUsers = interactiveMessage.mentionedUsers
        
        
        if let jsonObject = interactiveMessage.interactiveData {
            if let title = jsonObject[InteractiveConstants.TITLE] as? String {
                formMessage.setTitle(title)
            }
            if let text = jsonObject[InteractiveConstants.GOAL_COMPELTION_TEXT] as? String {
                formMessage.setGoalCompletionText(text)
            }
            if let formFields_ = jsonObject[InteractiveConstants.INTERACTIVE_MESSAGE_FORM_FIELD] as? [[String:Any]] {
                var elementEntityList = [ElementEntity]()
                for entity in formFields_ {
                    if let element = ElementEntity.entityFromJSON(entity) {
                        elementEntityList.append(element)
                    }
                }
                formMessage.setFormFields(elementEntityList);
            }
            if let submitField_ = jsonObject[InteractiveConstants.INTERACTIVE_MESSAGE_SUBMIT_ELEMENT] as? [String:Any] {
                if let element = ElementEntity.entityFromJSON(submitField_) as? ButtonElement {
                    formMessage.setSubmitElement(element)
                }
            }
        }
        return formMessage
    }
    
    public func interactiveMessage() -> InteractiveMessage {
        
        let interactiveMessage = InteractiveMessage()
        interactiveMessage.type = MessageTypeConstants.form
        interactiveMessage.id = self.id
        interactiveMessage.receiverType = self.receiverType
        interactiveMessage.receiver = self.receiver
        interactiveMessage.sender = self.sender
        interactiveMessage.senderUid = self.senderUid
        interactiveMessage.sentAt = self.sentAt
        interactiveMessage.readAt = self.readAt
        interactiveMessage.deliveredAt = self.deletedAt
        interactiveMessage.updatedAt = self.updatedAt
        interactiveMessage.deletedBy = self.deletedBy
        interactiveMessage.interactionGoal = self.interactionGoal
        interactiveMessage.metaData = self.metaData
        interactiveMessage.muid = self.muid
        interactiveMessage.rawMessage = self.rawMessage
        interactiveMessage.conversationId = self.conversationId
        interactiveMessage.readByMeAt = self.readByMeAt
        interactiveMessage.receiverUid = self.receiverUid
        interactiveMessage.replyCount = self.replyCount
        interactiveMessage.tags = self.tags
        interactiveMessage.allowSenderInteraction = self.allowSenderInteraction
        interactiveMessage.interactions = self.interactions
//        interactiveMessage.interactiveData = self.interactiveData
        
        var jsonObject = [String : Any]()
        
        if let title = self.title {
            jsonObject[InteractiveConstants.TITLE] = title
        }
        if let text = self.goalCompletionText {
            jsonObject[InteractiveConstants.GOAL_COMPELTION_TEXT] = text
        }
        
        if !self.getFormFields().isEmpty {
            var jsonArray = [[String:Any]]()
            for elementEntity in self.getFormFields() {
                switch elementEntity.elementType {
                case .label :
                    if let labelElement = elementEntity as? LabelElement {
                        jsonArray.append(labelElement.toJSON())
                    }
                    break
                case .button :
                    if let buttonElement = elementEntity as? ButtonElement {
                        jsonArray.append(buttonElement.toJSON())
                    }
                    break
                case .textInput:
                    if let textInput = elementEntity as? TextInputElement {
                        jsonArray.append(textInput.toJSON())
                    }
                case .checkbox:
                    if let checkbox = elementEntity as? CheckboxElement {
                        jsonArray.append(checkbox.toJSON())
                    }
                case .dropdown:
                    if let dropDown = elementEntity as? DropdownElement {
                        jsonArray.append(dropDown.toJSON())
                    }
                case .radio:
                    if let radio = elementEntity as? RadioButtonElement {
                        jsonArray.append(radio.toJSON())
                    }
                case .singleSelect:
                    if let singleSelect = elementEntity as? SingleSelectElement {
                        jsonArray.append(singleSelect.toJSON())
                    }
                case .dateTime:
                    if let dateTime = elementEntity as? DateTimeElement {
                        jsonArray.append(dateTime.toJSON())
                    }
                case .none: break
                }
            }
            jsonObject[InteractiveConstants.INTERACTIVE_MESSAGE_FORM_FIELD] = jsonArray
        }
        let buttonElement = self.getSubmitElement()
        if !buttonElement.elementId.isEmpty {
            jsonObject[InteractiveConstants.INTERACTIVE_MESSAGE_SUBMIT_ELEMENT] = buttonElement.toJSON()
        }
        interactiveMessage.interactiveData = jsonObject
        return interactiveMessage
    }
    
}
