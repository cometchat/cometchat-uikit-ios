//
//  CardMessage.swift
//
//
//  Created by Abhishek Saralaya on 23/10/23.
//

import Foundation
import CometChatSDK

@objc public class CardMessage: InteractiveMessage {
    private var imageUrl:String?
    private var cardActions:[ElementEntity]?
    private var text:String?
    private var goalCompletionText: String?;
    
//    public func createFormField() {
//        interactiveMessage?.interactiveData
//    }
    
    public override init() {
        super.init()
        type = MessageTypeConstants.card
    }
    
    init(url: String, receiverUid: String, receiverType: CometChat.ReceiverType, cardActions: [ElementEntity], text: String) {
        super.init()
        setImageUrl(url)
        setCardActions(cardActions)
        setText(text)
        super.receiverUid = receiverUid
        super.receiverType = receiverType
        super.type = MessageTypeConstants.card
    }
    
    public func getCardActions() -> [ElementEntity] {
        return self.cardActions ?? [ElementEntity]()
    }
    
    public func setCardActions(_ cardActions: [ElementEntity]) {
        self.cardActions = cardActions
    }
    
    public func setGoalCompletionText(_ goalCompletionText: String) {
          self.goalCompletionText = goalCompletionText;
      }

      public func getGoalCompletionText() -> String {
          return goalCompletionText ?? "";
      }
    
    public func getImageUrl() -> String {
        return self.imageUrl ?? ""
    }
    
    public func setImageUrl(_ url: String) {
        self.imageUrl = url
    }
    
    public func getText() -> String {
        return self.text ?? ""
    }
    
    public func setText(_ text: String) {
        self.text = text
    }
    
    public static func toCardMessage(_ interactiveMessage: InteractiveMessage) -> CardMessage {
        let cardMessage = CardMessage()
        cardMessage.type = MessageTypeConstants.card
        cardMessage.id = interactiveMessage.id
        cardMessage.receiverType = interactiveMessage.receiverType
        cardMessage.receiver = interactiveMessage.receiver
        cardMessage.sender = interactiveMessage.sender
        cardMessage.senderUid = interactiveMessage.senderUid
        cardMessage.sentAt = interactiveMessage.sentAt
        cardMessage.readAt = interactiveMessage.readAt
        cardMessage.deliveredAt = interactiveMessage.deletedAt
        cardMessage.updatedAt = interactiveMessage.updatedAt
        cardMessage.deletedBy = interactiveMessage.deletedBy
        cardMessage.interactionGoal = interactiveMessage.interactionGoal
        cardMessage.metaData = interactiveMessage.metaData
        cardMessage.muid = interactiveMessage.muid
        cardMessage.rawMessage = interactiveMessage.rawMessage
        cardMessage.conversationId = interactiveMessage.conversationId
        cardMessage.readByMeAt = interactiveMessage.readByMeAt
        cardMessage.receiverUid = interactiveMessage.receiverUid
        cardMessage.replyCount = interactiveMessage.replyCount
        cardMessage.tags = interactiveMessage.tags
        cardMessage.allowSenderInteraction = interactiveMessage.allowSenderInteraction
        cardMessage.interactions = interactiveMessage.interactions
        cardMessage.reactions = interactiveMessage.reactions
        cardMessage.mentionedMe = interactiveMessage.mentionedMe
        cardMessage.mentionedUsers = interactiveMessage.mentionedUsers
        
        if let jsonObject = interactiveMessage.interactiveData {
            if let imageUrl = jsonObject[InteractiveConstants.IMAGE_URL] as? String {
                cardMessage.setImageUrl(imageUrl)
            }
            if let text = jsonObject[InteractiveConstants.TEXT] as? String {
                cardMessage.setText(text)
            }
            if let text = jsonObject[InteractiveConstants.GOAL_COMPELTION_TEXT] as? String {
                cardMessage.setGoalCompletionText(text)
            }
            if let cardActions_ = jsonObject[InteractiveConstants.CARD_ACTIONS] as? [[String:Any]] {
                var elementEntityList = [ElementEntity]()
                for entity in cardActions_ {
                    if let element = ElementEntity.entityFromJSON(entity) {
                        elementEntityList.append(element)
                    }
                }
                cardMessage.setCardActions(elementEntityList);
            }
//            if let submitField_ = jsonObject[InteractiveConstants.INTERACTIVE_MESSAGE_SUBMIT_ELEMENT] as? [String:Any] {
//                if let element = ElementEntity.entityFromJSON(submitField_) as? ButtonElement {
//                    cardMessage.setSubmitElement(element)
//                }
//            }
        }
        return cardMessage
    }
    
    public func interactiveMessage() -> InteractiveMessage {
        
        let interactiveMessage = InteractiveMessage()
        interactiveMessage.type = MessageTypeConstants.card
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
        
        if !self.getImageUrl().isEmpty {
            jsonObject[InteractiveConstants.IMAGE_URL] = self.getImageUrl()
        }
        if let text = self.text {
            jsonObject[InteractiveConstants.TEXT] = text
        }
        if let text = self.goalCompletionText {
            jsonObject[InteractiveConstants.GOAL_COMPELTION_TEXT] = text
        }
        
        if !self.getCardActions().isEmpty {
            var jsonArray = [[String:Any]]()
            for elementEntity in self.getCardActions() {
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
            jsonObject[InteractiveConstants.CARD_ACTIONS] = jsonArray
        }
        interactiveMessage.interactiveData = jsonObject
        return interactiveMessage
    }
    
}

