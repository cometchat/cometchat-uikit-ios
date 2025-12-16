//
//  MentionTextFormatter.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 04/03/24.
//

import Foundation
import CometChatSDK

open class CometChatMentionsFormatter: CometChatTextFormatter {
    
    var userRequestBuilder: UsersRequest?
    var groupMemberRequestBuilder: GroupMembersRequest?
    var customUserRequestBuilder: UsersRequest.UsersRequestBuilder?
    var customGroupMemberRequestBuilder: GroupMembersRequest.GroupMembersRequestBuilder?
    var limit = 10
    var onMentionClicked: ((_ baseMessage: BaseMessage, _ tappedText: String, _ controller: UIViewController?)->())?
    var mentionsType: MentionsType = MentionsType.usersAndGroupMembers
    var visibility: MentionsVisibility = .both
    
    public var disableMentionAll: Bool = false
    public var mentionAllId: String = "all"
    public var mentionAllLabel: String = "all"
    
    
    // Shared (computed) styles so they reflect updated fonts/colors when language/theme changes
    public static var composerTextStyle: MentionTextStyle {
        var mentionStyle = MentionTextStyle()
        mentionStyle.textColor = CometChatTheme.primaryColor
        mentionStyle.textBackgroundColor = .clear
        mentionStyle.textFont = CometChatTypography.Body.regular
        mentionStyle.loggedInUserTextFont = CometChatTypography.Body.regular
        mentionStyle.loggedInUserTextColor = CometChatTheme.warningColor
        mentionStyle.loggedInUserTextBackgroundColor = .clear
        return mentionStyle
    }
    
    public static var conversationListTextStyle: MentionTextStyle {
        var mentionStyle = MentionTextStyle()
        mentionStyle.textColor = CometChatTheme.primaryColor
        mentionStyle.textBackgroundColor = CometChatTheme.primaryColor.withAlphaComponent(0.2)
        mentionStyle.textFont = CometChatTypography.Body.regular
        mentionStyle.loggedInUserTextFont = CometChatTypography.Body.regular
        mentionStyle.loggedInUserTextColor = CometChatTheme.warningColor
        mentionStyle.loggedInUserTextBackgroundColor = CometChatTheme.warningColor.withAlphaComponent(0.2)
        return mentionStyle
    }
    
    public static var leftBubbleTextStyle: MentionTextStyle {
        var mentionStyle = MentionTextStyle()
        mentionStyle.textColor = CometChatTheme.primaryColor
        mentionStyle.textBackgroundColor = CometChatTheme.primaryColor.withAlphaComponent(0.2)
        mentionStyle.textFont = CometChatTypography.Body.regular
        mentionStyle.loggedInUserTextFont = CometChatTypography.Body.regular
        mentionStyle.loggedInUserTextColor = CometChatTheme.warningColor
        mentionStyle.loggedInUserTextBackgroundColor = CometChatTheme.warningColor.withAlphaComponent(0.2)
        return mentionStyle
    }
    
    public static var rightBubbleTextStyle: MentionTextStyle {
        var mentionStyle = MentionTextStyle()
        mentionStyle.textColor = CometChatTheme.white
        mentionStyle.textBackgroundColor = CometChatTheme.white.withAlphaComponent(0.2)
        mentionStyle.textFont = CometChatTypography.Body.regular
        mentionStyle.loggedInUserTextFont = CometChatTypography.Body.regular
        mentionStyle.loggedInUserTextColor = CometChatTheme.warningColor
        mentionStyle.loggedInUserTextBackgroundColor = CometChatTheme.warningColor.withAlphaComponent(0.2)
        return mentionStyle
    }
    
    // Instance (mutable) styling - initialized from computed shared styles
    public var rightBubbleTextStyle = CometChatMentionsFormatter.rightBubbleTextStyle
    public var leftBubbleTextStyle = CometChatMentionsFormatter.leftBubbleTextStyle
    public var conversationListTextStyle = CometChatMentionsFormatter.conversationListTextStyle
    public var composerTextStyle = CometChatMentionsFormatter.composerTextStyle
    
    // Call this when language/typography/theme changes to refresh instance styles
    public func reloadStyles() {
        self.rightBubbleTextStyle = CometChatMentionsFormatter.rightBubbleTextStyle
        self.leftBubbleTextStyle = CometChatMentionsFormatter.leftBubbleTextStyle
        self.conversationListTextStyle = CometChatMentionsFormatter.conversationListTextStyle
        self.composerTextStyle = CometChatMentionsFormatter.composerTextStyle
    }
    
    public enum MentionsType {
        case usersAndGroupMembers
        case users
    }
    
    public enum MentionsVisibility {
        case usersConversationOnly
        case groupConversationOnly
        case both
    }
    
    public init() {
        super.init(trackingCharacter: "@")
        
        formatterID = "internal_mentions"
        
    }
    
    open override func getRegex() -> String {
        let escapedAllId = NSRegularExpression.escapedPattern(for: mentionAllId)
        return "<@(?:uid|all):([^>]+)>"
    }
    
    open override func search(string: String, suggestedItems listItemModelCallBack: ((_: [SuggestionItem]) -> ())? = nil) {
        
        var string = string
        if string.first == trackingCharacter { string.removeFirst() }
        
        if mentionsType == .users {
            
            if user != nil && visibility != .groupConversationOnly {
                searchForUser(string: string, suggestedItems: listItemModelCallBack)
            } else if group != nil && visibility != .usersConversationOnly {
                searchForUser(string: string, suggestedItems: listItemModelCallBack)
            } else {
                listItemModelCallBack?([])
            }
            
        } else if mentionsType == .usersAndGroupMembers {
            
            if user != nil && visibility != .groupConversationOnly {
                searchForUser(string: string, suggestedItems: listItemModelCallBack)
            } else if group != nil && visibility != .usersConversationOnly {
                searchForGroup(string: string, suggestedItems: listItemModelCallBack)
            } else {
                listItemModelCallBack?([])
            }
            
        }
        
    }
    
    open func searchForUser(string: String, suggestedItems listItemModelCallBack: ((_: [SuggestionItem]) -> ())?) {
        
        userRequestBuilder = customUserRequestBuilder?.build() ?? UsersRequest.UsersRequestBuilder()
            .set(limit: limit)
            .set(searchKeyword: string)
            .build()
        
        userRequestBuilder!.fetchNext { users in
            var listItemModel = [SuggestionItem]()
            for user in users {
                listItemModel.append(self.buildSuggestionItem(user: user))
            }
            listItemModelCallBack?(listItemModel)
        } onError: { _ in
            listItemModelCallBack?([])
        }
        
    }
    
    open func searchForGroup(string: String, suggestedItems listItemModelCallBack: ((_: [SuggestionItem]) -> ())?) {
        
        guard let group = group else {
            listItemModelCallBack?([])
            return
        }
        
        groupMemberRequestBuilder = customGroupMemberRequestBuilder?.build() ?? GroupMembersRequest.GroupMembersRequestBuilder(guid: group.guid)
            .set(limit: limit)
            .set(searchKeyword: string)
            .build()
        
        groupMemberRequestBuilder?.fetchNext(onSuccess: { users in
            var listItemModel = [SuggestionItem]()
            
            let trimmed = string.trimmingCharacters(in: .whitespaces)
            let alias = self.mentionAllLabel.lowercased()
            let query = trimmed.lowercased()
            
            if self.disableMentionAll == false,
               self.group != nil,
               (query.isEmpty || alias.hasPrefix(query)) {

                let style = self.composerTextStyle.getLoggedInUserTextAttributes()

                let allItem = SuggestionItem(
                    id: self.mentionAllId,
                    name: "@\(self.mentionAllLabel)",
                    leftIconUrl: group.icon ?? group.name,
                    visibleText: "@\(self.mentionAllLabel)",
                    underlyingText: "<@\("all"):\(self.mentionAllId)>",
                    visibleTextAttributes: style,
                    status: .offline
                )

                listItemModel.append(allItem)
            }
            
            for user in users {
                listItemModel.append(self.buildSuggestionItem(user: user))
            }
            listItemModelCallBack?(listItemModel)
        }, onError: { error in
            listItemModelCallBack?([])
        })
        
    }
    
    open func buildSuggestionItem(user: User) -> SuggestionItem {
        
        var style: [NSAttributedString.Key: Any] = [:]
        if user.uid == CometChat.getLoggedInUser()?.uid {
            style = composerTextStyle.getLoggedInUserTextAttributes()
        } else {
            style = composerTextStyle.getTextAttributes()
        }
        
        return SuggestionItem(id: user.uid, name: user.name, leftIconUrl: user.avatar, visibleText: "@\(user.name ?? "")", underlyingText: "<@uid:\(user.uid ?? "")>", visibleTextAttributes: style, status: UserStatus(rawValue: user.status.rawValue) ?? .offline)
    }
    
    open override func onScrollToBottom(suggestionItemList: [SuggestionItem], listItem: (([SuggestionItem]) -> ())?) {
        
        if userRequestBuilder != nil {
            onScrollToBottomForUser(suggestionItemList: suggestionItemList, listItem: listItem)
        } else if groupMemberRequestBuilder != nil {
            onScrollToBottomForGroup(suggestionItemList: suggestionItemList, listItem: listItem)
        }

    }
    
    open func onScrollToBottomForGroup(suggestionItemList: [SuggestionItem], listItem: (([SuggestionItem]) -> ())?) {
        guard let groupMemberRequestBuilder = groupMemberRequestBuilder else {
            listItem?([])
            return
        }
        groupMemberRequestBuilder.fetchNext { users in
            var listItemModel = [SuggestionItem]()
            users.forEach { user in
                listItemModel.append(self.buildSuggestionItem(user: user))
            }
            listItem?(listItemModel)
        } onError: { error in
            listItem?([])
        }
    }
    
    open func onScrollToBottomForUser(suggestionItemList: [SuggestionItem], listItem: (([SuggestionItem]) -> ())?) {
        guard let userRequestBuilder = userRequestBuilder else {
            listItem?([])
            return
        }
        userRequestBuilder.fetchNext { users in
            var listItemModel = [SuggestionItem]()
            users.forEach { user in
                listItemModel.append(self.buildSuggestionItem(user: user))
            }
            listItem?(listItemModel)
        } onError: { error in
            listItem?([])
        }
    }
    
    open override func handlePreMessageSend(baseMessage: BaseMessage, suggestionItemList: [SuggestionItem]) {
        suggestionItemList.forEach { suggestionItem in
            if suggestionItem.id == mentionAllId {
                baseMessage.metaData?["mentionedAll"] = true   // optional metadata
            }

            let user = User(uid: suggestionItem.id ?? "", name: suggestionItem.name ?? "")
            baseMessage.mentionedUsers.append(user)
        }
    }
    
    open override func prepareMessageString(
        baseMessage: BaseMessage,
        regexString: String,
        alignment: MessageBubbleAlignment = .right,
        formattingType: FormattingType
    ) -> NSAttributedString {

        if regexString == mentionAllId {
            let style = getNSAttributesForAllMention(alignment: alignment, formattingType: formattingType)
            return NSAttributedString(string: "@\(mentionAllLabel)", attributes: style)
        }

        for user in baseMessage.mentionedUsers {
            if user.uid == regexString {
                let style = getNSAttributes(for: user, alignment: alignment, formattingType: formattingType)
                return NSAttributedString(string: "@\(user.name ?? "")", attributes: style)
            }
        }

        return NSAttributedString(string: "@\(regexString)")
    }

    
    func getNSAttributesForAllMention(alignment: MessageBubbleAlignment, formattingType: FormattingType) -> [NSAttributedString.Key: Any] {
        switch formattingType {
        case .MESSAGE_BUBBLE:
            return alignment == .left ? leftBubbleTextStyle.getLoggedInUserTextAttributes() : rightBubbleTextStyle.getLoggedInUserTextAttributes()
        case .COMPOSER:
            return composerTextStyle.getLoggedInUserTextAttributes()
        case .CONVERSATION_LIST:
            return conversationListTextStyle.getLoggedInUserTextAttributes()
        }
    }

    
    open func getNSAttributes(for user: User, alignment: MessageBubbleAlignment, formattingType: FormattingType) -> [NSAttributedString.Key: Any] {
        switch formattingType {
        case .MESSAGE_BUBBLE:
            if user.uid == CometChat.getLoggedInUser()?.uid {
                if alignment == .left {
                    return leftBubbleTextStyle.getLoggedInUserTextAttributes()
                } else {
                    return rightBubbleTextStyle.getLoggedInUserTextAttributes()
                }
            } else {
                if alignment == .left {
                    return leftBubbleTextStyle.getTextAttributes()
                } else {
                    return rightBubbleTextStyle.getTextAttributes()
                }
            }
        case .COMPOSER:
            if user.uid == CometChat.getLoggedInUser()?.uid {
                return composerTextStyle.getLoggedInUserTextAttributes()
            } else {
                return composerTextStyle.getTextAttributes()
            }
        case .CONVERSATION_LIST:
            if user.uid == CometChat.getLoggedInUser()?.uid {
                return conversationListTextStyle.getLoggedInUserTextAttributes()
            } else {
                return conversationListTextStyle.getTextAttributes()
            }
            
        }
    }
    
    open override func onTextTapped(baseMessage: BaseMessage, tappedText: String, controller: UIViewController?) {
        onMentionClicked?(baseMessage, tappedText, controller)
    }
    
}

extension CometChatMentionsFormatter {

    @discardableResult
    public func set(composerTextStyle: MentionTextStyle) -> Self {
        self.composerTextStyle = composerTextStyle
        return self
    }
    
    @discardableResult
    public func set(conversationListTextStyle:  MentionTextStyle) -> Self {
        self.conversationListTextStyle = conversationListTextStyle
        return self
    }
    
    @discardableResult
    public func set(leftBubbleTextStyle: MentionTextStyle) -> Self {
        self.leftBubbleTextStyle = leftBubbleTextStyle
        return self
    }
    
    @discardableResult
    public func set(rightBubbleTextStyle: MentionTextStyle) -> Self {
        self.rightBubbleTextStyle = rightBubbleTextStyle
        return self
    }
    
    @discardableResult
    public func set(userRequestBuilder: UsersRequest.UsersRequestBuilder?) -> Self {
        self.customUserRequestBuilder = userRequestBuilder
        return self
    }
    
    @discardableResult
    public func set(groupRequestBuilder: GroupMembersRequest.GroupMembersRequestBuilder?) -> Self {
        self.customGroupMemberRequestBuilder = groupRequestBuilder
        return self
    }
    
    @discardableResult
    public func set(onMentionClicked: ((_ baseMessage: BaseMessage, _ tappedText: String, _ controller: UIViewController?)->())?) -> Self {
        self.onMentionClicked = onMentionClicked
        return self
    }
    
    @discardableResult
    public func set(mentionsType: MentionsType) -> Self {
        self.mentionsType = mentionsType
        return self
    }
    
    @discardableResult
    public func set(visibility: MentionsVisibility) -> Self {
        self.visibility = visibility
        return self
    }
    
    @discardableResult
    public func setDisableMentionAll(_ disable: Bool) -> Self {
        self.disableMentionAll = disable
        return self
    }

    @discardableResult
    public func setMentionAllLabel(id: String, label: String) -> Self {
        self.mentionAllId = id
        self.mentionAllLabel = label
        return self
    }

    
}
