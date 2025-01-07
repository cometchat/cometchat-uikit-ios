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
    var isDraggedToDismissGesture = false

    //Setting Up header
    lazy var headerView: CometChatMessageHeader = {
        let headerView = CometChatMessageHeader()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        if let user = user { headerView.set(user: user) }
        if let group = group { headerView.set(group: group) }
        headerView.set(controller: self) //passing controller needs to be mandatory
        return headerView
    }()
    
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
    
    lazy var messageListView: CometChatMessageList = {
        
        let messageListView = CometChatMessageList(frame: .null)
        messageListView.translatesAutoresizingMaskIntoConstraints = false
        if let user = user { messageListView.set(user: user) }
        if let group = group { messageListView.set(group: group) }
        messageListView.set(controller: self)
        messageListView.setOnThreadRepliesClick { [weak self] message, template in
            guard let this = self else { return }
            let threadedView = ThreadedMessagesVC()
            threadedView.parentMessage = message
            threadedView.user = this.user
            threadedView.parentMessageView.controller = self
            threadedView.parentMessageView.set(parentMessage: message)
            this.navigationController?.pushViewController(threadedView, animated: true)
        }
        
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
    }
    
    deinit {
        print("deinit called for CustomMessagesViewController")
        CometChat.removeGroupListener("messages-user-event-listener-\(randamID)")
        CometChatUIEvents.removeListener("messages-user-event-listener-\(randamID)")
        CometChatUserEvents.removeListener("messages-user-event-listener-\(randamID)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self // for swipe back gesture
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func buildUI() {
        
        self.view.backgroundColor = CometChatTheme.backgroundColor01
        
        view.addSubview(headerView)
        view.addSubview(messageListView)
        view.addSubview(blockedView)
        view.addSubview(composerView)
        blockedView.addSubview(blockedLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            messageListView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            messageListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            blockedView.topAnchor.constraint(equalTo: messageListView.bottomAnchor),
            blockedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blockedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blockedView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -CometChatSpacing.Padding.p5),
            
            composerView.topAnchor.constraint(equalTo: messageListView.bottomAnchor),
            composerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            composerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            composerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            blockedLabel.topAnchor.constraint(equalTo: blockedView.topAnchor, constant: CometChatSpacing.Padding.p2),
            blockedLabel.bottomAnchor.constraint(equalTo: blockedView.bottomAnchor, constant: -CometChatSpacing.Padding.p2),
            blockedLabel.leadingAnchor.constraint(equalTo: blockedView.leadingAnchor, constant: CometChatSpacing.Padding.p5),
            blockedLabel.trailingAnchor.constraint(equalTo: blockedView.trailingAnchor, constant: -CometChatSpacing.Padding.p5)
        ])
        
        setTailViewToHeader()
                
        if user?.blockedByMe == true{
            self.composerView.removeFromSuperview()
            self.headerView.tailView.subviews.first?.subviews[0].isHidden = true
            self.headerView.tailView.subviews.first?.subviews[1].isHidden = true
            self.headerView.disable(userPresence: true)
        }
    }
    
    func setTailViewToHeader() {
        let menu = CometChatUIKit.getDataSource().getAuxiliaryHeaderMenu(user: user, group: group, controller: self, id: nil)
        let infoButton = getInfoButton()
        menu?.addArrangedSubview(infoButton)
        menu?.distribution = .fillEqually
        menu?.alignment = .fill
        menu?.spacing = CometChatSpacing.Spacing.s4
        menu?.widthAnchor.constraint(lessThanOrEqualToConstant: 120).isActive = true
        headerView.set(tailView: menu ?? infoButton)
    }
    
    func enableComposerWithCallButton() {
        
        if user != nil { blockedLabel.text = "Can’t send a message to blocked \(user?.name ?? "")" }
        if group != nil { blockedLabel.text = "You'r no longer part of this group" }
        
        self.view.addSubview(composerView)
        NSLayoutConstraint.activate([
            composerView.topAnchor.constraint(equalTo: messageListView.bottomAnchor),
            composerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            composerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            composerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        setTailViewToHeader()
        self.headerView.disable(userPresence: false)
    }
    
    func disableComposerWithCallButton() {
        self.composerView.removeFromSuperview()
        headerView.set(tailView: getInfoButton())
        setTailViewToHeader()
    }
}

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

//MARK: - GROUP EVENTS -
extension MessagesVC: CometChatGroupDelegate {
    
    func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        if bannedFrom.guid == group?.guid && CometChat.getLoggedInUser()?.uid == bannedUser.uid {
            disableComposerWithCallButton()
        }
    }
    
    func onGroupMemberLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        if leftGroup.guid == group?.guid && CometChat.getLoggedInUser()?.uid == leftUser.uid {
            disableComposerWithCallButton()
        }
    }
    
    func onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        if kickedFrom.guid == group?.guid && CometChat.getLoggedInUser()?.uid == kickedUser.uid {
            disableComposerWithCallButton()
        }
    }
    
    func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        if unbannedFrom.guid == group?.guid && CometChat.getLoggedInUser()?.uid == unbannedUser.uid {
            enableComposerWithCallButton()
        }
    }
    
    func onMemberAddedToGroup(action: ActionMessage, addedBy: User, addedUser: User, addedTo: Group) {
        if addedTo.guid == group?.guid && CometChat.getLoggedInUser()?.uid == addedUser.uid {
            enableComposerWithCallButton()
        }
    }
    
}

// MARK: - User Block Events -
extension MessagesVC : CometChatUserEventListener {
    func ccUserBlocked(user: User) {
        if user.uid == self.user?.uid {
            disableComposerWithCallButton()
        }
    }
    
    func ccUserUnblocked(user: User) {
        if user.uid == self.user?.uid {
            enableComposerWithCallButton()
        }
    }
}
