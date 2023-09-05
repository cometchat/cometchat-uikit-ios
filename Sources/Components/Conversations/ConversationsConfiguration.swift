//
//  ConversationsConfiguration.swift
//
//
//  Created by Abdullah Ansari on 18/08/22.
//
import Foundation
import UIKit
import CometChatSDK

public final class ConversationsConfiguration {
    
    private(set) var disableUsersPresence: Bool?
    private(set) var disableReceipt: Bool?
    private(set) var disableTyping: Bool?
    private(set) var disableSoundForMessages: Bool?
    private(set) var customSoundForMessages: URL?
    private(set) var protectedGroupIcon: UIImage?
    private(set) var privateGroupIcon: UIImage?
    private(set) var readIcon: UIImage?
    private(set) var deliveredIcon: UIImage?
    private(set) var sentIcon: UIImage?
    private(set) var datePattern: ((_ conversation: Conversation) -> String)?
    private(set) var listItemView: ((_ conversation: Conversation) -> UIView)?
    private(set) var subtitleView: ((_ conversation: Conversation) -> UIView)?
    private(set) var menus: [UIBarButtonItem]?
    private(set) var conversationsRequestBuilder: ConversationRequest.ConversationRequestBuilder?
    private(set) var options: ((_ conversation: Conversation) -> [CometChatConversationOption])?
    private(set) var hideSeparator: Bool?
    private(set) var searchPlaceholder: String?
    private(set) var backButton: UIImage?
    private(set) var showBackButton: Bool?
    private(set) var selectionMode: SelectionMode?
    private(set) var onSelection: (([Conversation]) -> Void)?
    private(set) var selectedConversations: [Conversation]?
    private(set) var searchBoxIcon: UIImage?
    private(set) var hideSearch: Bool?
    private(set) var emptyView: UIView?
    private(set) var errorView: UIView?
    private(set) var statusIndicatorStyle: StatusIndicatorStyle?
    private(set) var avatarStyle: AvatarStyle?
    private(set) var receiptStyle: ReceiptStyle?
    private(set) var dateStyle: DateStyle?
    private(set) var conversationsStyle: ConversationsStyle?
    private(set) var listItemStyle: ListItemStyle?
    private(set) var badgeStyle: BadgeStyle?
    private(set) var onItemClick: ((_ conversation: Conversation, _ indexPath: IndexPath) -> Void)?
    private(set) var onItemLongClick: ((_ conversation: Conversation, _ indexPath: IndexPath) -> Void)?
    private(set) var onError: ((_ error: CometChatException) -> Void)?
    private(set) var onBack: (() -> ())?
    private(set) var emptyStateText: String?
    private(set) var errorStateText: String?
    private(set) var title: String?
    private(set) var titleMode: UINavigationItem.LargeTitleDisplayMode = .automatic
    
    public init() {}

    @discardableResult
      public func set(title: String, mode: UINavigationItem.LargeTitleDisplayMode) -> Self {
        self.title = title
        self.titleMode = mode
        return self
      }
    
    @discardableResult
    public func set(emptyStateText: String) -> Self {
        self.emptyStateText = emptyStateText
        return self
    }
    
    @discardableResult
    public func set(errorStateText: String) -> Self {
        self.errorStateText = errorStateText
        return self
    }

    @discardableResult
    public func hide(hideSeparator: Bool) -> Self {
        self.hideSeparator = hideSeparator
        return self
    }
    
    @discardableResult
    public func disable(userPresence: Bool) -> Self {
        disableUsersPresence = userPresence
        return self
    }
    
    @discardableResult
    public func disable(receipt: Bool) -> Self {
        disableReceipt = receipt
        return self
    }
    
    @discardableResult
    public func disable(typing: Bool) -> Self {
        disableTyping = typing
        return self
    }
    
    @discardableResult
    public func disable(soundForMessages: Bool) -> Self {
        disableSoundForMessages = soundForMessages
        return self
    }
    
    @discardableResult
    public func set(customSoundForMessages: URL) -> Self {
        self.customSoundForMessages = customSoundForMessages
        return self
    }
    
    @discardableResult
    public func set(privateGroupIcon: UIImage) -> Self {
        self.privateGroupIcon = privateGroupIcon
        return self
    }
    
    @discardableResult
    public func set(protectedGroupIcon: UIImage) -> Self {
        self.protectedGroupIcon = protectedGroupIcon
        return self
    }
    
    @discardableResult
    public func set(readIcon: UIImage) -> Self {
        self.readIcon = readIcon
        return self
    }
    
    @discardableResult
    public func set(deliveredIcon: UIImage) -> Self {
        self.deliveredIcon = deliveredIcon
        return self
    }
    
    @discardableResult
    public func set(sentIcon: UIImage) -> Self {
        self.sentIcon = sentIcon
        return self
    }
    
    @discardableResult
    public func setDatePattern(datePattern: @escaping ((_ conversation: Conversation) -> String)) -> Self {
        self.datePattern = datePattern
        return self
    }
    
    @discardableResult
    public func setListItemView(listItemView: @escaping ((_ conversation: Conversation) -> UIView)) -> Self {
        self.listItemView = listItemView
        return self
    }
    
    @discardableResult
    public func setSubtitle(subtitleView: @escaping ((_ conversation: Conversation) -> UIView)) -> Self {
        self.subtitleView = subtitleView
        return self
    }
    
    @discardableResult
    public func setMenus(menus: [UIBarButtonItem]) -> Self {
        self.menus = menus
        return self
    }
    
    @discardableResult
    public func hide(hideSearch: Bool) -> Self {
        self.hideSearch = hideSearch
        return self
    }
    
    @discardableResult
    public func set(searchPlaceholder: String) -> Self {
        self.searchPlaceholder = searchPlaceholder
        return self
    }
    
    @discardableResult
    public func set(backButton: UIImage) -> Self {
        self.backButton = backButton
        return self
    }
    
    @discardableResult
    public func show(showBackButton: Bool) -> Self {
        self.showBackButton =  showBackButton
        return self
    }
    
    @discardableResult
    public func selectionMode(mode: SelectionMode) -> Self {
        self.selectionMode = mode
        return self
    }
    
    @discardableResult
    public func getSelectedConversations(selectedConversations: [Conversation]) -> Self {
        self.selectedConversations = selectedConversations
        return self
    }
    
    @discardableResult
    public func set(searchBoxIcon: UIImage) -> Self {
        self.searchBoxIcon = searchBoxIcon
        return self
    }
    
    @discardableResult
    public func set(emptyView: UIView) -> Self {
        self.emptyView = emptyView
        return self
    }
    
    @discardableResult
    public func setOptions(options: ((_ conversation: Conversation?) -> [CometChatConversationOption])?) -> Self {
      self.options = options
      return self
    }
    
    @discardableResult
      public func setOnSelection(onSelection : @escaping (([Conversation]) -> Void)) -> Self {
        self.onSelection = onSelection
        return self
      }
    
    @discardableResult
    public func set(errorView: UIView) -> Self {
        self.errorView = errorView
        return self
    }
    
    @discardableResult
    public func set(statusIndicatorStyle: StatusIndicatorStyle) -> Self {
        self.statusIndicatorStyle = statusIndicatorStyle
        return self
    }
    
    @discardableResult
    public func set(avatarStyle: AvatarStyle) -> Self {
        self.avatarStyle = avatarStyle
        return self
    }
    
    @discardableResult
    public func set(listItemStyle: ListItemStyle) -> Self {
        self.listItemStyle = listItemStyle
        return self
    }
    
    @discardableResult
    public func set(badgeStyle: BadgeStyle) -> Self {
        self.badgeStyle = badgeStyle
        return self
    }
    
    @discardableResult
    public func set(conversationsStyle: ConversationsStyle) -> Self {
        self.conversationsStyle = conversationsStyle
        return self
    }
    
    @discardableResult
    public func set(dateStyle: DateStyle) -> Self {
        self.dateStyle = dateStyle
        return self
    }
    
    @discardableResult
    public func set(receiptStyle: ReceiptStyle) -> Self {
        self.receiptStyle = receiptStyle
        return self
    }
    
    @discardableResult
    public func setRequestBuilder(conversationRequestBuilder: ConversationRequest.ConversationRequestBuilder) -> Self {
        self.conversationsRequestBuilder = conversationRequestBuilder
        return self
    }
    
    @discardableResult
    public func setOnItemClick(onItemClick: @escaping ((_ conversation: Conversation, _ indexPath: IndexPath) -> Void)) -> Self {
        self.onItemClick = onItemClick
        return self
    }
    
    @discardableResult
    public func setOnItemLongClick(onItemLongClick: @escaping ((_ conversation: Conversation, _ indexPath: IndexPath) -> Void)) -> Self {
        self.onItemLongClick = onItemLongClick
        return self
    }
    
    @discardableResult
    public func setOnError(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
    @discardableResult
    public func set(onBack: () -> ()) -> Self {
        self.onBack = self.onBack
        return self
    }
}
