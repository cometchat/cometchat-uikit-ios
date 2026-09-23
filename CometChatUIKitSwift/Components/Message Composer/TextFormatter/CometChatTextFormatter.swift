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

    /// Strips this formatter's display form back to the text that goes on the
    /// wire, the reverse of `prepareMessageString`.
    ///
    /// A formatter that renders its own inline style overrides this so the style
    /// survives send: the token stays in the message text and re-renders on every
    /// surface. A formatter whose token is already the displayed text — mentions
    /// and URLs — needs no reverse step, which is why the default returns `text`
    /// unchanged.
    ///
    /// Call it when reading composer text whose display form differs from the
    /// stored token: before send, and when populating the composer to edit an
    /// existing message.
    ///
    /// - Parameter text: the composer's current text, in display form.
    /// - Returns: the storable form, e.g. `"{color:#f00}hi{/color}"` from a run
    ///   the formatter had coloured.
    open func getOriginalText(_ text: String) -> String {
        return text
    }

    /// Styles this formatter's tokens on the live composer input.
    ///
    /// The composer calls this on every text change, after its own rich-text and
    /// mention styling. Apply attributes only — do not add or remove characters,
    /// or the token stops matching what goes on the wire. A formatter that hides
    /// its markers does so with an attribute, not by deleting them.
    ///
    /// Implementations remove their own previously-applied attributes first, so
    /// repeated calls settle rather than accumulate.
    ///
    /// The default does nothing, so a token shows as plain source while typing
    /// and renders only once sent.
    ///
    /// - Parameter text: the composer's live text, mutated in place.
    open func applyComposerAttributes(to text: NSMutableAttributedString) {
        
    }

    /// Display form for the reply and edit preview panels.
    ///
    /// A read-only surface, distinct from the live input: a formatter whose
    /// composer form keeps a raw token intact should override this to strip the
    /// token and apply its styling, so the panel shows styled text rather than
    /// the marker characters.
    ///
    /// Defaults to `prepareMessageString(baseMessage:regexString:formattingType:)`
    /// with `.COMPOSER`, so a formatter that does not override is unaffected.
    open func preparePreviewString(baseMessage: BaseMessage, regexString: String) -> NSAttributedString {
        return prepareMessageString(
            baseMessage: baseMessage,
            regexString: regexString,
            formattingType: .COMPOSER
        )
    }
    
}
