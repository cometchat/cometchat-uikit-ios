//
//  CometChatTextFormatter.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 04/03/24.
//

import Foundation
import CometChatSDK

public enum FormattingType {
    case MESSAGE_BUBBLE
    case COMPOSER
    case CONVERSATION_LIST
}

open class CometChatTextFormatter {
    
    public var trackingCharacter: Character
    public var suggestionItemList: [SuggestionItem] = [SuggestionItem]()
    public var user: User?
    public var group: Group?
    internal var formatterID: String?
        
    public init(trackingCharacter: Character) {
        self.trackingCharacter = trackingCharacter
    }
    
    //If the conversation is open for this user this function will get called and text the current user
    open func set(user: User) {
        self.user = user
        self.group = nil
    }
    
    //If the conversation is open for this group this function will get called and text the current group
    open func set(group: Group) {
        self.group = group
        self.user = nil
    }
    
    //This will be the Regex that is going to get used for identifying  TextFormatter in the TextMessage
    open func getRegex() -> String {
        return ""
    }
    
    //This character will be used in the composer to trigger search func like @ for mentions
    open func getTrackingCharacter() -> Character {
        return trackingCharacter
    }
    
    //This function will get trigger when a tracking character is identified in the composer text
    open func search(string: String, suggestedItems: ((_: [SuggestionItem]) -> ())? = nil)  {
        
    }
    
    //When the Suggestion List view is scrolled to bottom this func will get trigger. You implement pagination from this function by calling fetchNext.
    open func onScrollToBottom(suggestionItemList: [SuggestionItem], listItem: ((_: [SuggestionItem]) -> ())?) {
        
    }
    
    //When a Suggestion List Item is Clicked this func will get triggered.
    open func onItemClick(suggestedItem: SuggestionItem, user: User?, group: Group?) {
        
    }
    
    //This function will get trigger when message is about to sent.
    open func handlePreMessageSend(baseMessage: BaseMessage, suggestionItemList: [SuggestionItem]) {
        
    }
    
    //This function will get triggered from the TextBubble Whenever the regex is found this it will trigger this function with the regexString(i.e. text inside the regex) and returned string will get replaced with the found regex.
    open func prepareMessageString(baseMessage: BaseMessage, regexString: String, alignment: MessageBubbleAlignment = .left, formattingType: FormattingType) -> NSAttributedString {
        return NSAttributedString(string: "")
    }
    
    //When a textFormatter is tapped from the TextBubble this function will get trigged.
    open func onTextTapped(baseMessage: BaseMessage, tappedText: String, controller: UIViewController?) {
        
    }
    
}
