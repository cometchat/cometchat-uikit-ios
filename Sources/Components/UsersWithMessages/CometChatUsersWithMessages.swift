//
//  CometChatUsersWithMessages.swift
 
//
//  Created by Pushpsen Airekar on 23/05/22.
//

import UIKit
import CometChatSDK

public class CometChatUsersWithMessages: CometChatUsers {
    
    private(set) var messagesConfiguration: MessagesConfiguration?
    private(set) var usersConfiguration: UsersConfiguration?
    private(set) var user: User? = nil
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if let user = user {
            navigateToMessages(user: user)
        }
        addUsersWithMessagesListener()
        callbacks()
    }
    
    private func addUsersWithMessagesListener() {
        CometChatUserEvents.addListener("users-with-messages-event-listener", self as CometChatUserEventListener)
        CometChat.addUserListener("users-with-messages-sdk-listener", self)
        CometChatUIEvents.addListener("users-with-message-ui-event-listener", self)
    }
    
    func disconnect() {
        CometChatUserEvents.removeListener("users-with-messages-event-listener")
        CometChat.removeUserListener("users-with-messages-sdk-listener")
        CometChatUIEvents.removeListener("users-with-message-ui-event-listener")
    }
    
    private func callbacks() {
        
        // when user do onItemClick
        onDidSelect = { [weak self] (user, indexPath) in
            if let onItemClick = self?.onItemClick {
                onItemClick(user, indexPath)
            } else {
                guard let this = self else { return }
                this.navigateToMessages(user: user)
            }
        }
    }
    
    override func onBackCallback() {
        if let onBack = onBack {
            onBack()
        } else {
            self.dismiss(animated: true)
        }
    }
    
    private func navigateToMessages(user: User) {
        let cometChatMessages: CometChatMessages = CometChatMessages()
        cometChatMessages.set(user: user)
        if let messagesConfiguration = messagesConfiguration {
            cometChatMessages.set(detailsConfiguration: messagesConfiguration.detailsConfiguration)
            cometChatMessages.set(messageListConfiguration: messagesConfiguration.messageListConfiguration)
            cometChatMessages.set(messageComposerConfiguration: messagesConfiguration.messageComposerConfiguration)
            cometChatMessages.set(messageHeaderConfiguration: messagesConfiguration.messageHeaderConfiguration)
            cometChatMessages.setMessageListView(messageListView: messagesConfiguration.messageListView)
            cometChatMessages.setMessageHeaderView(messageHeaderView: messagesConfiguration.messageHeaderView)
            cometChatMessages.setMessageComposerView(messageComposerView: messagesConfiguration.messageComposerView)
            
            if let auxiliaryMenu = messagesConfiguration.auxiliaryMenu {
                cometChatMessages.setAuxiliaryMenu(auxiliaryMenu: auxiliaryMenu)
            }
            
            if let hideMessageHeader = messagesConfiguration.hideMessageHeader {
                cometChatMessages.hide(messageHeader: hideMessageHeader)
            }
            
            if let hideMessageComposer = messagesConfiguration.hideMessageComposer {
                cometChatMessages.hide(messageComposer: hideMessageComposer)
            }
            
            if let messageStyle = messagesConfiguration.messagesStyle {
                cometChatMessages.set(messagesStyle: messageStyle)
            }
            
            if let disableSoundForMessages = messagesConfiguration.disableSoundForMessages {
                cometChatMessages.disable(soundForMessages: disableSoundForMessages)
            }
            
            if let customSoundForIncomingMessages = messagesConfiguration.customSoundForIncomingMessages {
                cometChatMessages.set(customSoundForIncomingMessages: customSoundForIncomingMessages)
            }
            
            if let customSoundForOutgoingMessages =  messagesConfiguration.customSoundForOutgoingMessages {
                cometChatMessages.set(customSoundForOutgoingMessages: customSoundForOutgoingMessages)
            }
            
            if let disableTyping = messagesConfiguration.disableTyping {
                cometChatMessages.disable(disableTyping: disableTyping)
            }
        }
        
        cometChatMessages.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(cometChatMessages, animated: true)
    }
    
    private func setUserConfiguration() {
        if let usersConfiguration = usersConfiguration {
            if let onItemClick = usersConfiguration.onItemClick {
                setOnItemClick(onItemClick: onItemClick)
            }
            disable(userPresence: usersConfiguration.disableUsersPresence)
            selectionMode(mode: usersConfiguration.selectionMode)
            setSubtitle(subtitle: usersConfiguration.subtitle)
            setListItemView(listItemView: usersConfiguration.listItemView)
            setOptions(options: usersConfiguration.options)
            hide(separator: usersConfiguration.hideSeparator)
            set(backButtonTitle: usersConfiguration.backButtonTitle)
            set(backButtonFont: usersConfiguration.backButtonFont)
            
            if let searchBoxIcon = usersConfiguration.searchBoxIcon {
                set(searchIcon: searchBoxIcon)
            }
            
            if let title = usersConfiguration.title {
                set(title: title, mode: usersConfiguration.titleMode)
            }
            if let emptyStateText = usersConfiguration.emptyStateText {
                set(emptyStateText: emptyStateText)
            }
            if let errorStateText = usersConfiguration.errorStateText {
                set(errorStateText: errorStateText)
            }
            
            if let backButtonColor = usersConfiguration.backButtonColor {
                set(backButtonTitleColor: backButtonColor)
            }
            
            if let backButtonTint = usersConfiguration.backButtonTint {
                set(backButtonTint: backButtonTint)
            }
            
            if let backIcon = usersConfiguration.backIcon {
                set(backButtonIcon: backIcon)
            }
            
            if let emptyStateView = usersConfiguration.emptyStateView {
                set(emptyView: emptyStateView )
            }
            
            if let showSectionHeader = usersConfiguration.showSectionHeader {
                show(sectionHeader: showSectionHeader)
            }
            
            if let errorStateView = usersConfiguration.errorStateView {
                set(errorView: errorStateView)
            }
            
            if let hideSearch = usersConfiguration.hideSearch {
                hide(search: hideSearch)
            }
            
            if let menus = usersConfiguration.menus {
                set(menus: menus)
            }
            
            if let usersStyle = usersConfiguration.usersStyle {
                set(usersStyle: usersStyle)
            }
            
            if let avatarStyle = usersConfiguration.avatarStyle {
                set(avatarStyle: avatarStyle)
            }
            
            if let statusIndicatorStyle = usersConfiguration.statusIndicatorStyle {
                set(statusIndicatorStyle: statusIndicatorStyle)
            }
            
            if let listItemStyle = usersConfiguration.listItemStyle {
                set(listItemStyle: listItemStyle)
            }
            
            if let showBackButton = usersConfiguration.showBackButton {
                show(backButton: showBackButton)
            }
        }
    }
    
}

extension CometChatUsersWithMessages {
    @discardableResult
    public func set(messagesConfiguration: MessagesConfiguration) -> Self {
        self.messagesConfiguration = messagesConfiguration
        return self
    }
    
    @discardableResult
    public func set(usersConfiguration: UsersConfiguration) -> Self {
        self.usersConfiguration = usersConfiguration
        setUserConfiguration()
        return self
    }
}

extension CometChatUsersWithMessages: CometChatUserEventListener {
    
    public func onItemClick(user: CometChatSDK.User, index: IndexPath?) {
        navigateToMessages(user: user)
        print("CometChatUsersWithMessages - events - onItemClick")
    }
    
    public func onItemLongClick(user: CometChatSDK.User, index: IndexPath?) {
        
        print("CometChatUsersWithMessages - events - onItemLongClick")
    }
    
    public func onUserBlock(user: CometChatSDK.User) {
        
        print("CometChatUsersWithMessages - events - onUserBlock")
    }
    
    public func onUserUnblock(user: CometChatSDK.User) {
        
        print("CometChatUsersWithMessages - events - onUserUnblock")
    }
    
    public func onError(user: CometChatSDK.User?, error: CometChatSDK.CometChatException) {
        
        print("CometChatUsersWithMessages - events - onError")
    }
}

extension CometChatUsersWithMessages : CometChatUserDelegate {
    
    public func onUserOnline(user: User) {
        
        print("CometChatUsersWithMessages - sdk - onUserOnline")
    }
    
    public func onUserOffline(user: User) {
        
        print("CometChatUsersWithMessages - sdk - onUserOffline")
    }
    
}

extension CometChatUsersWithMessages : CometChatUIEventListener {
    public func showPanel(id: [String : Any]?, alignment: UIAlignment, view: UIView?) {}
    
    public func hidePanel(id: [String : Any]?, alignment: UIAlignment) {}
    
    public func onActiveChatChanged(id: [String : Any]?, lastMessage: CometChatSDK.BaseMessage?, user: CometChatSDK.User?, group: CometChatSDK.Group?) {}
    
    public func openChat(user: CometChatSDK.User?, group: CometChatSDK.Group?) {
        if let user = user {
            navigateToMessages(user: user)
        }
    }
    
    
}
