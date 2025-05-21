//
//  MessagesViewController.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 17/10/24.
//

import UIKit
import CometChatSDK
import CometChatUIKitSwift

class MessagesVC: UIViewController {
    
    var user: User?
    var group: Group?
    lazy var randamID = Date().timeIntervalSince1970

    //Setting Up header
    lazy var headerView: CometChatMessageHeader = {
        let headerView = CometChatMessageHeader()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        if let user = user { headerView.set(user: user) }
        if let group = group { headerView.set(group: group) }
        headerView.set(controller: self) //passing controller needs to be mandatory
        headerView.set(trailView: { [weak self] user, group in
            guard let this = self else { return UIView() }
            return this.getInfoButton()
        })
        if user?.blockedByMe == true { headerView.hideUserStatus = true }
        return headerView
    }()
        
    lazy var messageListView: CometChatMessageList = {
        
        let messageListView = CometChatMessageList(frame: .null)
        messageListView.translatesAutoresizingMaskIntoConstraints = false
        if let user = user { messageListView.set(user: user) }
        if let group = group { messageListView.set(group: group) }
        messageListView.set(controller: self)
        messageListView.set(onThreadRepliesClick: { [weak self] message,template in
            guard let this = self else { return }
            let threadedView = ThreadedMessagesVC()
            threadedView.parentMessage = message
            threadedView.user = this.user
            threadedView.parentMessageView.controller = self
            threadedView.parentMessageView.set(parentMessage: message)
            this.navigationController?.pushViewController(threadedView, animated: true)
        })
        
        //adding tap gesture on mention click
        let mentionsFormatter = CometChatMentionsFormatter()
        mentionsFormatter.set { [weak self] message, uid, controller in
            let messageVC = MessagesVC()
            if let tappedUser = message.mentionedUsers.first(where: { $0.uid == uid }) {
                messageVC.user = tappedUser
                if CometChat.getLoggedInUser()?.uid != tappedUser.uid{
                    self?.navigationController?.pushViewController(messageVC, animated: true)
                }
            }
        }
        messageListView.set(textFormatters: [mentionsFormatter])
        
        return messageListView
    }()
    
    lazy var composerView: CometChatMessageComposer = {
        let messageComposer = CometChatMessageComposer(frame: .null)
        if let user = user { messageComposer.set(user: user) }
        if let group = group { messageComposer.set(group: group) }
        messageComposer.set(controller: self)
        messageComposer.translatesAutoresizingMaskIntoConstraints = false
        return messageComposer
    }()
    
    lazy var blockedView: UIView = {
        let view = UIView(frame: .null)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var blockedLabel: UILabel = {
        let label = UILabel(frame: .null)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = CometChatTheme.textColorSecondary
        label.font = CometChatTypography.Body.regular
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        buildUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        CometChatUIEvents.addListener("messages-user-event-listener-\(randamID)", self)
        CometChatUserEvents.addListener("messages-user-event-listener-\(randamID)", self)
        CometChat.addGroupListener("messages-user-event-listener-\(randamID)", self)
        CometChatGroupEvents.addListener("messages-groups-event-listner-\(randamID)", self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self // for swipe back gesture
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        navigationItem.hidesBackButton = true
        title = "MESSAGES".localize()
        
        // setting this for notification
        // (notification will not be displayed if that users or groups chat is active on screen)
        CometChatPNHelper.currentActiveGroup = group
        CometChatPNHelper.currentActiveUser = user
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        CometChatPNHelper.currentActiveGroup = nil
        CometChatPNHelper.currentActiveUser = nil
    }
    
    deinit {
        CometChat.removeGroupListener("messages-user-event-listener-\(randamID)")
        CometChatUIEvents.removeListener("messages-user-event-listener-\(randamID)")
        CometChatUserEvents.removeListener("messages-user-event-listener-\(randamID)")
        CometChatGroupEvents.removeListener("messages-groups-event-listner-\(randamID)")
    }
    
    func buildUI() {
        
        self.view.backgroundColor = CometChatTheme.backgroundColor01
        
        view.addSubview(headerView)
        view.addSubview(messageListView)
        view.addSubview(composerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            messageListView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            messageListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            composerView.topAnchor.constraint(equalTo: messageListView.bottomAnchor),
            composerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            composerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            composerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
                
        if user?.blockedByMe == true{
            disableMessageSending()
        }
    }
    
    func getInfoButton() -> UIView {
        let detailButton = CometChatButton()
        let infoIcon: UIImage = UIImage(systemName: "info.circle")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        detailButton.set(text: "")
        detailButton.set(icon: infoIcon)
        detailButton.tintColor = CometChatTheme.iconColorPrimary
        detailButton.backgroundColor = .clear
        detailButton.set(controller: self)
        detailButton.setOnClick { [weak self] in
            DispatchQueue.main.async {
                guard let this = self else { return }
                if let group = this.group{
                    let detailsView = GroupDetailsViewController()
                    detailsView.group = self?.headerView.viewModel.group
                    detailsView.onExitGroup = { group in
                        self?.group = group
                        if !(group.hasJoined){
                            //Handle bann members real time update here
                        }
                    }
                    this.navigationController?.pushViewController(detailsView, animated: true)
                }else{
                    let detailsView = UserDetailsViewController()
                    detailsView.user = self?.headerView.viewModel.user
                    this.navigationController?.pushViewController(detailsView, animated: true)
                }
            }
        }
        return detailButton
    }

}

//MARK: - HANDLING BACK GESTURE AND UI EVENT -
extension MessagesVC: CometChatUIEventListener, UIGestureRecognizerDelegate {
    
    func openChat(user: User?, group: Group?) {
        let messages = MessagesVC()
        messages.group = group
        messages.user = user
        self.navigationController?.pushViewController(messages, animated: true)
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: - HANDLING GROUP EVENTS -
extension MessagesVC: CometChatGroupDelegate, CometChatGroupEventListener {
    
    func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        if bannedFrom.guid == group?.guid && CometChat.getLoggedInUser()?.uid == bannedUser.uid {
            disableMessageSending()
        }
    }
    
    func ccGroupLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        if leftGroup.guid == group?.guid && CometChat.getLoggedInUser()?.uid == leftUser.uid {
            disableMessageSending()
            headerView.set(group: leftGroup)
        }
    }
    
    func onGroupMemberLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        if leftGroup.guid == group?.guid && CometChat.getLoggedInUser()?.uid == leftUser.uid {
            disableMessageSending()
        }
    }
    
    func onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        if kickedFrom.guid == group?.guid && CometChat.getLoggedInUser()?.uid == kickedUser.uid {
            disableMessageSending()
        }
    }
    
    func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        if unbannedFrom.guid == group?.guid && CometChat.getLoggedInUser()?.uid == unbannedUser.uid {
            enableMessageSending()
        }
    }
    
    func onMemberAddedToGroup(action: ActionMessage, addedBy: User, addedUser: User, addedTo: Group) {
        if addedTo.guid == group?.guid && CometChat.getLoggedInUser()?.uid == addedUser.uid {
            enableMessageSending()
        }
    }
    
}

// MARK: - HANDLING USER BLOCK EVENTS -
extension MessagesVC : CometChatUserEventListener {
    func ccUserBlocked(user: User) {
        if user.uid == self.user?.uid {
            disableMessageSending()
        }
    }
    
    func ccUserUnblocked(user: User) {
        if user.uid == self.user?.uid {
            enableMessageSending()
        }
    }
}


extension MessagesVC {
    
    //This function will disable message sending by removing composer and adding some info when in logged in user has blocked the open user in chat or when the logged in user is no longer part of the open group.
    func disableMessageSending() {
        self.composerView.removeFromSuperview()

        //adding blocked view
        self.view.addSubview(blockedView)
        var constraintsToActivate: [NSLayoutConstraint] = [NSLayoutConstraint]()
        constraintsToActivate += [
            blockedView.topAnchor.constraint(equalTo: messageListView.bottomAnchor),
            blockedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blockedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blockedView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        //adding label that shows messages
        let infoLabel = UILabel(frame: .null)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textColor = CometChatTheme.textColorSecondary
        infoLabel.font = CometChatTypography.Body.regular
        infoLabel.textAlignment = .center
        blockedView.addSubview(infoLabel)
        constraintsToActivate += [
            infoLabel.topAnchor.constraint(equalTo: blockedView.topAnchor,constant: 10),
            infoLabel.leadingAnchor.constraint(equalTo: blockedView.leadingAnchor, constant: CometChatSpacing.Padding.p2),
            infoLabel.trailingAnchor.constraint(equalTo: blockedView.trailingAnchor, constant: -CometChatSpacing.Padding.p2),
        ]
        
        if user != nil {
            infoLabel.text = "SEND_MESSAGE_ERROR_TO_BLOCK_USER".localize() + " " + (user?.name ?? "")
            
            //adding unblock button only in group
            let unblockButton = UIButton()
            unblockButton.translatesAutoresizingMaskIntoConstraints = false
            unblockButton.setTitle("UNBLOCK".localize(), for: .normal)
            unblockButton.layer.borderWidth = 0.2
            unblockButton.layer.borderColor = CometChatTheme.borderColorDark.cgColor
            unblockButton.layer.cornerRadius = 3
            unblockButton.titleLabel?.font = CometChatTypography.Caption1.regular
            unblockButton.setTitleColor(CometChatTheme.neutralColor900, for: .normal)
            unblockButton.addTarget(self, action: #selector(onUnBlockButtonTapped), for: .primaryActionTriggered)
            blockedView.addSubview(unblockButton)
            constraintsToActivate += [
                unblockButton.heightAnchor.constraint(equalToConstant: 32),
                unblockButton.leadingAnchor.constraint(equalTo: blockedView.leadingAnchor, constant: CometChatSpacing.Padding.p3),
                unblockButton.trailingAnchor.constraint(equalTo: blockedView.trailingAnchor, constant: -CometChatSpacing.Padding.p3),
                unblockButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 10),
                unblockButton.bottomAnchor.constraint(equalTo: blockedView.bottomAnchor, constant: -30),
            ]
        }
        
        if group != nil {
            infoLabel.text = "NO_LONGER_IN_GROUP_ERROR".localize()
            constraintsToActivate.append(contentsOf: [
                infoLabel.bottomAnchor.constraint(equalTo: blockedView.bottomAnchor, constant: -30),
            ])
        }
        
        NSLayoutConstraint.activate(constraintsToActivate)
    }
    
    func enableMessageSending() {
        
        blockedView.removeFromSuperview()
        
        self.view.addSubview(composerView)
        NSLayoutConstraint.activate([
            composerView.topAnchor.constraint(equalTo: messageListView.bottomAnchor),
            composerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            composerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            composerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func onUnBlockButtonTapped() {
        
        CometChat.unblockUsers([user?.uid ?? ""]) { [weak self] success in
            guard let this = self else { return }
            DispatchQueue.main.async {
                this.user?.blockedByMe = false
                this.enableMessageSending()
                CometChatUserEvents.ccUserUnblocked(user: this.user!)
            }
        } onError: { error in
            //TODO: ERROR
        }
    }
    
}
