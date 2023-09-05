//
//  CometChatGroupsWithMessages.swift
 
//
//  Created by Pushpsen Airekar on 11/12/21.
//

import UIKit
import CometChatSDK

public class CometChatGroupsWithMessages: CometChatGroups {
    
    private(set) var messagesConfiguration: MessagesConfiguration?
    private(set) var groupsConfiguration: GroupsConfiguration?
    private(set) var group: Group?
    private(set) var joinProtectedGroupConfiguration: JoinProtectedGroupConfiguration?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        addGroupsWithMessagesListener()
        if let group = group {
            navigateToMessages(group: group)
        }
        callbacks()
    }
    
    func callbacks() {
        // on item click
        onDidSelect = { [weak self] (group, indexPath) in
            guard let this = self else { return }
            if let onItemClick = self?.onItemClick {
                onItemClick(group, indexPath)
            } else {
                if group.hasJoined == true {
                    this.navigateToMessages(group: group)
                } else {
                    // call the join group
                    let joinProtectedGroup = CometChatJoinProtectedGroup()
                    this.set(protectedGroup: joinProtectedGroup, configuration: this.joinProtectedGroupConfiguration)
                    joinProtectedGroup.set(group: group)
                    if this.navigationController != nil {
                        this.navigationController?.pushViewController(joinProtectedGroup, animated: true)
                    }
                }
            }
        }
    }
    
    // MARK:- Set the configuration for CometChatJoinProtectedGroup
    private func set(protectedGroup: CometChatJoinProtectedGroup, configuration: JoinProtectedGroupConfiguration?) {
        if let configuration = configuration {
            
            if let closeIcon = configuration.closeIcon {
                protectedGroup.set(backButtonIcon: closeIcon)
            }
                    
            if let joinIcon = configuration.joinIcon {
                protectedGroup.set(joinIcon: joinIcon)
            }
            
            if let onJoinClick = configuration.onJoinClick {
                protectedGroup.setOnJoinClick(onJoinClick: onJoinClick)
            }
            
            if let joinProtectedGroupStyle = configuration.joinProtectedGroupStyle {
                protectedGroup.set(joinProtectedGroupStyle: joinProtectedGroupStyle)
            }
            
            if let onError = configuration.onError {
                protectedGroup.setOnError(onError: onError)
            }
            
            if let onBack = configuration.onBack {
                protectedGroup.setOnBack(onBack: onBack)
            }
        }
    }
    
    public override func onBackCallback() {
        if let onBack = onBack {
            onBack()
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @discardableResult
    public func set(messagesConfiguration: MessagesConfiguration) -> Self {
        self.messagesConfiguration = messagesConfiguration
        return self
    }
    
    @discardableResult
    public func set(groupsConfiguration: GroupsConfiguration) -> Self {
        self.groupsConfiguration = groupsConfiguration
        setupGroupConfiguration()
        return self
    }
    
    @discardableResult
    public func set(joinProtectedGroupConfiguration: JoinProtectedGroupConfiguration) -> Self {
        self.joinProtectedGroupConfiguration = joinProtectedGroupConfiguration
        return self
    }
    
    private func addGroupsWithMessagesListener() {
        CometChatGroupEvents.addListener("group-with-messages-groups-events-listener", self as CometChatGroupEventListener)
        CometChat.addGroupListener("groups-with-messages-groups-sdk-listener", self)
        CometChatUIEvents.addListener("group-with-message-ui-event-listener", self)
    }
    
    private func disconnect() {
        CometChatGroupEvents.removeListener("group-with-messages-groups-events-listener")
        CometChat.removeGroupListener("groups-with-messages-groups-sdk-listener")
        CometChatUIEvents.removeListener("group-with-message-ui-event-listener")
    }
    
    private func navigateToMessages(group: Group) {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            let cometChatMessages = CometChatMessages()
            
            cometChatMessages.set(group: group)
            if let messagesConfiguration = this.messagesConfiguration {
                cometChatMessages.set(detailsConfiguration: messagesConfiguration.detailsConfiguration)
                cometChatMessages.set(messageListConfiguration: messagesConfiguration.messageListConfiguration)
                cometChatMessages.set(messageComposerConfiguration: messagesConfiguration.messageComposerConfiguration)
                cometChatMessages.set(messageHeaderConfiguration: messagesConfiguration.messageHeaderConfiguration)
                cometChatMessages.setMessageListView(messageListView: messagesConfiguration.messageListView)
                cometChatMessages.setMessageHeaderView(messageHeaderView: messagesConfiguration.messageHeaderView)
                cometChatMessages.setMessageComposerView(messageComposerView: messagesConfiguration.messageComposerView)
                
                if let hideMessageHeader = messagesConfiguration.hideMessageHeader {
                    cometChatMessages.hide(messageHeader: hideMessageHeader)
                }
                
                if let hideMessageComposer = messagesConfiguration.hideMessageComposer {
                    cometChatMessages.hide(messageComposer: hideMessageComposer)
                }
                
                if let messageStyle = messagesConfiguration.messagesStyle {
                    cometChatMessages.set(messagesStyle: messageStyle)
                }
                
                if let auxiliaryMenu = messagesConfiguration.auxiliaryMenu {
                    cometChatMessages.setAuxiliaryMenu(auxiliaryMenu: auxiliaryMenu)
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
            
            if this.navigationController != nil {
                cometChatMessages.hidesBottomBarWhenPushed = true
                this.navigationController?.pushViewController(cometChatMessages, animated: true)
            } else {
                this.present(cometChatMessages, animated: true)
            }
        }
    }
    
    private func setupGroupConfiguration() {
        if let groupsConfiguration = groupsConfiguration {
            set(searchIcon: groupsConfiguration.searchBoxIcon)
            selectionMode(mode: groupsConfiguration.selectionMode)
            setSubtitleView(subtitle: groupsConfiguration.subtitleView)
            setListItemView(listItemView: groupsConfiguration.listItemView)
            setOptions(options: groupsConfiguration.options)
            
            if let title = groupsConfiguration.title {
                set(title: title, mode: groupsConfiguration.titleMode)
            }
            if let emptyStateText = groupsConfiguration.emptyStateText {
                set(emptyStateText: emptyStateText)
            }
            if let errorStateText = groupsConfiguration.errorStateText {
                set(errorStateText: errorStateText)
            }

            if let hideSeparator = groupsConfiguration.hideSeparator {
                hide(separator: hideSeparator)
            }
            
            if let emptyView = groupsConfiguration.emptyStateView {
                set(emptyView: emptyView)
            }
            
            if let errorView = groupsConfiguration.errorStateView {
                set(errorView: errorView)
            }
            
            if let searchPlaceholderText = groupsConfiguration.searchPlaceholderText {
                set(searchPlaceholder: searchPlaceholderText)
            }
            
            if let hideSearch = groupsConfiguration.hideSearch {
                hide(search: hideSearch)
            }
            
            if let menus = groupsConfiguration.menus {
                set(menus: menus)
            }
            
            if let style = groupsConfiguration.style {
                set(groupsStyle: style)
            }
            
            if let showBackButton = groupsConfiguration.showBackButton {
                show(backButton: showBackButton)
            }
            
            if let privateGroupIcon = groupsConfiguration.privateGroupIcon {
                set(privateGroupIcon: privateGroupIcon)
            }
            
            if let protectedGroupIcon = groupsConfiguration.protectedGroupIcon {
                set(protectedGroupIcon: protectedGroupIcon)
            }
            
            if let onSelection = groupsConfiguration.onSelection {
                //TODO:- will do it later
            }
            
            if let searchBoxIcon = groupsConfiguration.searchBoxIcon {
                set(searchIcon: searchBoxIcon)
            }
            
            if let groupsRequestBuilder = groupsConfiguration.groupsRequestBuilder {
                set(groupsRequestBuilder: groupsRequestBuilder)
            }
        }
    }
}


extension CometChatGroupsWithMessages: CometChatGroupEventListener {
    
    public func onGroupCreate(group: Group) {
        navigateToMessages(group: group)
    }
    
    public func onGroupDelete(group: Group) {}

    
    public func onGroupMemberJoin(joinedUser: User, joinedGroup:  Group) {
        /*
         
         update active group
         
         launch messages
         
         
         */
        print("CometChatGroupsWithMessages - Events - onGroupMemberJoin")
    }
    
    public func onGroupMemberBan(bannedUser: User, bannedGroup: Group, bannedBy: User) {
        self.update(group: bannedGroup)
        print("CometChatGroupsWithMessages - Events - onGroupMemberBan")
    }
    
    public func onGroupMemberUnban(unbannedUserUser: User, unbannedUserGroup: Group, unbannedBy: User) {
        print("CometChatGroupsWithMessages - Events - onGroupMemberUnban")
    }
    
    
    public func onGroupMemberKick(kickedUser: User, kickedGroup: Group, kickedBy: User) {
        self.update(group: kickedGroup)
        print("CometChatGroupsWithMessages - Events - onGroupMemberKick")
    }
    
    public func onGroupMemberAdd(group: Group, members: [GroupMember], addedBy: User) {
        self.update(group: group)
    }
    
    public func onGroupMemberChangeScope(updatedBy: User , updatedUser: User , scopeChangedTo: CometChat.MemberScope , scopeChangedFrom: CometChat.MemberScope, group: Group) {
        /*
         Do Nothing as per figma
         */
        print("CometChatGroupsWithMessages - Events - onGroupMemberChangeScope")
    }

}

extension CometChatGroupsWithMessages: CometChatGroupDelegate {
    
    public func onGroupMemberJoined(action: CometChatSDK.ActionMessage, joinedUser: CometChatSDK.User, joinedGroup: CometChatSDK.Group) {
        self.update(group: joinedGroup)
        print("CometChatGroupsWithMessages - sdk - onGroupMemberJoined")
    }
    
    public func onGroupMemberLeft(action: CometChatSDK.ActionMessage, leftUser: CometChatSDK.User, leftGroup: CometChatSDK.Group) {
        self.update(group: leftGroup)
        print("CometChatGroupsWithMessages - sdk - onGroupMemberLeft")
    }
    
    public func onGroupMemberKicked(action: CometChatSDK.ActionMessage, kickedUser: CometChatSDK.User, kickedBy: CometChatSDK.User, kickedFrom: CometChatSDK.Group) {
        self.update(group: kickedFrom)
        print("CometChatGroupsWithMessages - sdk - onGroupMemberKicked")
    }
    
    public func onGroupMemberBanned(action: CometChatSDK.ActionMessage, bannedUser: CometChatSDK.User, bannedBy: CometChatSDK.User, bannedFrom: CometChatSDK.Group) {
        self.update(group: bannedFrom)
        print("CometChatGroupsWithMessages - sdk - onGroupMemberBanned")
    }
    
    public func onGroupMemberUnbanned(action: CometChatSDK.ActionMessage, unbannedUser: CometChatSDK.User, unbannedBy: CometChatSDK.User, unbannedFrom: CometChatSDK.Group) {
        self.update(group: unbannedFrom)
        print("CometChatGroupsWithMessages - sdk - onGroupMemberUnbanned")
    }
    
    public func onGroupMemberScopeChanged(action: CometChatSDK.ActionMessage, scopeChangeduser: CometChatSDK.User, scopeChangedBy: CometChatSDK.User, scopeChangedTo: String, scopeChangedFrom: String, group: CometChatSDK.Group) {
        /*
         Do Nothing as per figma
         */
        print("CometChatGroupsWithMessages - sdk - onGroupMemberScopeChanged")
    }
    
    public func onMemberAddedToGroup(action: CometChatSDK.ActionMessage, addedBy: CometChatSDK.User, addedUser: CometChatSDK.User, addedTo: CometChatSDK.Group) {
        self.update(group: addedTo)
        print("CometChatGroupsWithMessages - sdk - onMemberAddedToGroup")
    }
}

extension CometChatGroupsWithMessages: CometChatUIEventListener {
    public func showPanel(id: [String : Any]?, alignment: UIAlignment, view: UIView?) {}
    
    public func hidePanel(id: [String : Any]?, alignment: UIAlignment) {}
    
    public func onActiveChatChanged(id: [String : Any]?, lastMessage: CometChatSDK.BaseMessage?, user: CometChatSDK.User?, group: CometChatSDK.Group?) {}
    
    public func openChat(user: CometChatSDK.User?, group: CometChatSDK.Group?) {
        if let user = user {
            navigateToMessages(user: user)
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
    
    
}
