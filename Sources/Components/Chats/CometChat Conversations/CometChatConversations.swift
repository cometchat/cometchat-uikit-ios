//
//  CometChatConversations.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 22/12/21.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.
import UIKit
import CometChatPro


/**
 `CometChatConversations`  is a subclass of `UIViewController` which is inherited from `CometChatListBase`.   `CometChatConversations` uses an events from `CometChatListBaseDelegate` for search and back functionality.
 - Author: CometChat Team
 - Copyright:  ©  2022 CometChat Inc.
 */
open class CometChatConversations: CometChatListBase {

    // MARK: - Declaration of Outlets
    @IBOutlet weak var conversationList: CometChatConversationList!
    
    // MARK: - Declaration of Variables
    var startConversationIcon = UIImage(named: "chats-create.png", in: CometChatUIKit.bundle, compatibleWith: nil)
    var startConversationButton: UIBarButtonItem?
    var enableSoundForConversations: Bool = true
    var customSoundForConversations: URL?
    var configurations: [CometChatConfiguration]?
    
    
    public override func loadView() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view = contentView
        }
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        addObervers()
        configureConversationList()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
       
    }
    
    deinit {
       
    }
    
    @discardableResult
    public func set(customSoundForConversations: URL) ->  CometChatConversations {
        self.customSoundForConversations = customSoundForConversations
        return self
    }
    
    @discardableResult
    public func enableSoundForConversations(bool: Bool) ->  CometChatConversations {
        self.enableSoundForConversations = bool
        return self
    }
    
    @discardableResult
    public func set(configurations: [CometChatConfiguration]) ->  CometChatConversations {
        self.configurations = configurations
        return self
    }
    
    /**
     `CometChatConversations` is having an option to show start conversation using which user can show the option to start a conversation from a list of users or groups.
     - Parameters:
     - startConversation: This method will show the start conversation option in the CometChatConversations when the value is true.
     - Returns: This method will return `CometChatConversations`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func hide(startConversation: Bool) ->  CometChatConversations {
        if !startConversation {
            startConversationButton = UIBarButtonItem(image: startConversationIcon, style: .plain, target: self, action: #selector(self.didStartConversationPressed))
            self.navigationItem.rightBarButtonItem = startConversationButton
        }
        return self
    }
    
    /**
     This method will set the icon for the start conversation icon image in `CometChatConversations`
     - Parameters:
     - startConversationIcon: This method will set the icon for the start conversation icon image in CometChatConversations
     - Returns: This method will return `CometChatConversations`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(startConversationIcon: UIImage) ->  CometChatConversations {
        self.startConversationIcon = startConversationIcon.withRenderingMode(.alwaysTemplate)
        return self
    }
    
    /**
     This method will set the icon for the start conversation icon tint color  in `CometChatConversations`
     - Parameters:
     - startConversationIcon: This method will set the icon tint color for the start conversation  in CometChatConversations
     - Returns: This method will return `CometChatConversations`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(startConversationIconTint: UIColor) ->  CometChatConversations {
        startConversationButton?.tintColor = startConversationIconTint
        return self
    }

    
    private func setupAppearance() {
        self.set(background: [CometChatTheme.palatte?.background?.cgColor ?? UIColor.systemBackground.cgColor])
        self.conversationList.set(background: [CometChatTheme.palatte?.background?.cgColor ?? UIColor.systemBackground.cgColor])
        self.set(searchBackground: CometChatTheme.palatte?.accent100 ?? UIColor.systemFill)
            .set(searchPlaceholder: "SEARCH".localize())
            .set(searchTextColor: .label)
            .set(searchPlaceholderColor: CometChatTheme.palatte?.accent600 ?? .gray)
            .set(title: "CHATS".localize(), mode: .automatic)
            .set(titleColor: CometChatTheme.palatte?.accent ?? UIColor.clear)
           .set(searchCancelButtonFont: CometChatTheme.typography?.Body ?? UIFont.systemFont(ofSize: 17), searchCancelButtonColor: CometChatTheme.palatte?.primary ?? .blue)
            self.hide(search: true)
            self.hide(startConversation: true)
            .set(startConversationIcon: startConversationIcon ?? UIImage())
            .set(startConversationIconTint: CometChatTheme.palatte?.primary ?? UIColor.clear)
    
        conversationList.set(controller: self)
    }
    
    private func addObervers() {
        self.cometChatListBaseDelegate = self
        CometChatConversationEvents.addListener("conversations-listner", self as CometChatConversationEventListner)
        CometChatMessageEvents.addListener("messages-listner", self as CometChatMessageEventListner)
        CometChatGroupEvents.addListener("groups-listner", self as CometChatGroupEventListner)
        CometChatUserEvents.addListener("users-listner", self as CometChatUserEventListener)
                                               
    }
    
    private func removeObervers() {
        CometChatConversationEvents.removeListner("conversations-listner")
        CometChatMessageEvents.removeListner("messages-listner")
        CometChatGroupEvents.removeListner("groups-listner")
        CometChatUserEvents.removeListner("users-listner")
    }
    
    private func configureConversationList() {
        
        if let customSoundForConversations = customSoundForConversations {
            conversationList.set(customSoundForConversations: customSoundForConversations)
        }
        conversationList.set(conversationType: .none)
            .show(deleteConversation: true)
            .set(enableSoundForConversations: enableSoundForConversations)
            .set(configurations: configurations)
            .set(controller: self)
            
    }
    
    @objc func didStartConversationPressed(){
        CometChatConversationEvents.emitStartConversationClick()
    }
    
}


extension CometChatConversations: CometChatListBaseDelegate {
 
    public func onSearch(state: SearchState, text: String) {
        switch state {
        case .clear:
            conversationList.isSearching = false
            conversationList.filterConversations(forText: "")
        case .filter:
            conversationList.isSearching = true
            conversationList.filterConversations(forText: text)
        }
    }
    
    public func onBack() {
        switch self.isModal() {
        case true:
            self.dismiss(animated: true, completion: nil)
            removeObervers()
        case false:
            self.navigationController?.popViewController(animated: true)
            removeObervers()
        }
    }
}


extension CometChatConversations: CometChatConversationEventListner {
    
    
    public func onItemClick(conversation: Conversation, index: IndexPath?) {
        print(#function)
    }
    
    public func onItemLongClick(conversation: Conversation, index: IndexPath?) {
        print(#function)
    }
    
    public func onConversationDelete(conversation: Conversation) {
        print(#function)
    }
    
    public func onStartConversationClick() {
        print(#function)
    }
    
    public func onError(conversation: Conversation?, error: CometChatException) {
        print(#function)
    }
    
    
}


extension CometChatConversations: CometChatMessageEventListner {
    
    public func onMessageSent(message: BaseMessage, status: UIKitConstants.MessageStatusConstants) {
        if status == .success {
            conversationList.update(lastMessage: message)
        }
    }
    
    public func onMessageEdit(message: BaseMessage, status: UIKitConstants.MessageStatusConstants) {
        
    }
    
    public func onMessageDelete(message: BaseMessage, status: UIKitConstants.MessageStatusConstants) {
        
    }
    
    public func onMessageReply(message: BaseMessage, status: UIKitConstants.MessageStatusConstants) {
        
    }
    
    public func onMessageRead(message: BaseMessage) {
        
    }
    
    public func onLiveReaction(reaction: TransientMessage) {
        
    }
    
    public func onMessageError(error: CometChatException) {
        
    }
    
    public func onVoiceCall(user: User) {
        
    }
    
    public func onVoiceCall(group: Group) {
        
    }
    
    public func onVideoCall(user: User) {
        
    }
    
    public func onVideoCall(group: Group) {
        
    }
    
    public func onViewInformation(user: User) {
        
    }
    
    public func onViewInformation(group: Group) {
        
    }
    
    public func onError(message: BaseMessage?, error: CometChatException) {
        
    }
    
    public func onMessageReact(message: BaseMessage, reaction: CometChatMessageReaction) {
        
    }
    
    
}

extension CometChatConversations: CometChatGroupEventListner {
    
    public func onOwnershipChange(group: Group?, member: GroupMember?) {
        
    }
    
    
    public func onItemClick(group: Group, index: IndexPath?) {
        
    }
    
    public func onGroupMemberAdd(group: Group, members: [GroupMember]) {
        
    }
    
    public func onItemLongClick(group: Group, index: IndexPath?) {
        
    }
    
    public func onCreateGroupClick() {
        
    }
    
    public func onGroupCreate(group: Group) {
        
    }
    
    public func onGroupDelete(group: Group) {
        conversationList.refreshConversations()
    }
    
    public func onGroupMemberLeave(leftUser: User, leftGroup: Group) {
        conversationList.refreshConversations()
    }
    
    public func onGroupMemberJoin(joinedUser: User, joinedGroup: Group) {
        
    }
    
    public func onGroupMemberBan(bannedUser: User, bannedGroup: Group) {
        
    }
    
    public func onGroupMemberUnban(unbannedUserUser: User, unbannedUserGroup: Group) {
        
    }
    
    public func onGroupMemberKick(kickedUser: User, kickedGroup: Group) {
        
    }
    
    public func onGroupMemberChangeScope(updatedBy: User, updatedUser: User, scopeChangedTo: CometChat.MemberScope, scopeChangedFrom: CometChat.MemberScope, group: Group) {
        
    }
    
    public func onError(group: Group?, error: CometChatException) {
        
    }
    


}


extension CometChatConversations: CometChatUserEventListener {
    
    public func onItemClick(user: User, index: IndexPath?) {
        
    }
    
    public func onItemLongClick(user: User, index: IndexPath?) {
        
    }
    
    public func onUserBlock(user: User) {
        conversationList.refreshConversations()
    }
    
    public func onUserUnblock(user: User) {
        conversationList.refreshConversations()
    }
    
    public func onError(user: User?, error: CometChatException) {
        
    }
    


}
