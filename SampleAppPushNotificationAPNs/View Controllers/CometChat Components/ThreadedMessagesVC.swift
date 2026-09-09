//
//  ThreadedRepliesViewController.swift
//  Sample App
//
//  Created by Suryansh on 19/07/24.
//

import UIKit
import CometChatUIKitSwift
import CometChatSDK

class ThreadedMessagesVC: UIViewController {
    
    var user: User?
    var parentMessage: BaseMessage?
    var bubbleView: UIView?
    var targetMessageId: Int?
    
    /// In-hierarchy header, matching MessagesVC. Kept out of the system navigation
    /// bar so it renders full-width instead of as a floating bar-button item.
    ///
    /// The kit component carries the follow/unfollow bell in its trailing area once
    /// `parentMessage` is set, so this screen renders no control of its own.
    lazy var headerView: CometChatMessageHeader = {
        let headerView = CometChatMessageHeader()
        headerView.translatesAutoresizingMaskIntoConstraints = false

        // The header titles itself from the conversation; a thread screen titles
        // itself "Thread" over the conversation's name instead.
        headerView.set(titleView: { _, _ in
            let title = UILabel()
            title.text = "THREAD".localize()
            title.textColor = CometChatTheme.textColorPrimary
            title.font = CometChatTypography.Heading4.bold
            return title
        })
        headerView.set(subtitleView: { [weak self] _, _ in
            let subtitle = UILabel()
            subtitle.text = self?.conversationName ?? ""
            subtitle.textColor = CometChatTheme.textColorSecondary
            subtitle.font = CometChatTypography.Caption1.regular
            return subtitle
        })

        if let user = threadCounterpartUser {
            headerView.set(user: user)
        } else if let group = parentMessage?.receiver as? Group {
            headerView.set(group: group)
        }

        headerView.set(controller: self)
        headerView.hideVoiceCallButton = true
        headerView.hideVideoCallButton = true
        headerView.disableTyping = true
        headerView.set(onBack: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        })

        // Puts the header in thread mode: this is what renders the bell.
        headerView.set(parentMessage: parentMessage)
        return headerView
    }()

    /// The conversation a thread belongs to, named as the header subtitle shows it.
    private var conversationName: String {
        if let group = parentMessage?.receiver as? Group { return group.name ?? "" }
        return threadCounterpartUser?.name ?? ""
    }

    /// The other party in a 1-1 thread: the receiver when we sent the root, else the sender.
    private var threadCounterpartUser: User? {
        guard (parentMessage?.receiver as? Group) == nil else { return nil }
        if parentMessage?.receiverUid == CometChat.getLoggedInUser()?.uid {
            return parentMessage?.sender as? User
        }
        return parentMessage?.receiver as? User
    }

    lazy var parentMessageView: CometChatThreadedMessageHeader = {
        let parentMessageContainerView = CometChatThreadedMessageHeader()
        parentMessageContainerView.translatesAutoresizingMaskIntoConstraints = false
        if let parentMessage {
            parentMessageContainerView.set(parentMessage: parentMessage)
        }
        parentMessageContainerView.set(controller: self)
        // The bell lives in the header bar on this screen, so the threaded header's
        // own control stays hidden — the two must never both render.
        parentMessageContainerView.set(hideThreadSubscriptionButton: true)
        return parentMessageContainerView
    }()
    
    lazy var messageListView: CometChatMessageList = {
        let messageListView = CometChatMessageList(frame: .null)
        
        //Checking for the other user
        if let user = (parentMessage?.senderUid == CometChat.getLoggedInUser()?.uid ? parentMessage?.receiver : parentMessage?.sender) as? User {
            messageListView.set(user: user, parentMessage: parentMessage)
        }
        
        if let group = parentMessage?.receiver as? Group {
            messageListView.set(group: group, parentMessage: parentMessage)
        }

        messageListView.set(controller: self)
        // Replies are pinnable and savable, same as parent messages.
        messageListView.enablePinMessage = true
        messageListView.enableSaveMessage = true
        messageListView.set(onThreadRepliesClick: { [weak self] message, messageBubbleView in
            guard let this = self else { return }
        })
        messageListView.translatesAutoresizingMaskIntoConstraints = false
        return messageListView
    }()
    
    lazy var composerView: CometChatCompactMessageComposer = {
        let messageComposer = CometChatCompactMessageComposer(frame: .null)
        
        //Checking for the group or other user
        if let group = parentMessage?.receiver as? Group {
            messageComposer.set(group: group)
        } else if let user = (parentMessage?.senderUid == CometChat.getLoggedInUser()?.uid ? parentMessage?.receiver : parentMessage?.sender) as? User {
            messageComposer.set(user: user)
        }
        
        messageComposer.set(parentMessageId: parentMessage?.id ?? 0)
        messageComposer.set(controller: self)
        messageComposer.translatesAutoresizingMaskIntoConstraints = false
        messageComposer.enableRichTextFormatting = true
        messageComposer.showRichTextFormattingOptions = true
        return messageComposer
    }()
    
    lazy var blockedUserView: UIView = {
        let view = UIView(frame: .null)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var blockedUserLabel: UILabel = {
        let label = UILabel(frame: .null)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = CometChatTheme.textColorSecondary
        label.font = CometChatTypography.Body.regular
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Populates headerView, which buildUI's constraints depend on.
        setupNavigationBar()
        buildUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // The header lives in the view hierarchy, so the system bar would be a second
        // one stacked above it.
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let targetMessageId = targetMessageId {
            messageListView.goToMessage(withId: targetMessageId)
            self.targetMessageId = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Only on the way out — pushing a detail screen from here keeps the bar hidden
        // until that screen sets its own.
        if isMovingFromParent || isBeingDismissed {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    func setupNavigationBar() {
        navigationItem.hidesBackButton = true

        // The header is a kit component; it builds its own back button, title and bell.
        NSLayoutConstraint.activate([
            headerView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }


    
    
    func buildUI() {
        
        self.view.backgroundColor = CometChatTheme.backgroundColor01
        
        view.addSubview(headerView)
        view.addSubview(parentMessageView)
        view.addSubview(messageListView)
        view.addSubview(composerView)
        view.addSubview(blockedUserView)
        view.addSubview(composerView)
        blockedUserView.addSubview(blockedUserLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            parentMessageView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            parentMessageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            parentMessageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            messageListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageListView.topAnchor.constraint(equalTo: parentMessageView.bottomAnchor),
            
            blockedUserView.topAnchor.constraint(equalTo: messageListView.bottomAnchor),
            blockedUserView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blockedUserView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blockedUserView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -CometChatSpacing.Padding.p5),
            
            composerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            composerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            composerView.topAnchor.constraint(equalTo: messageListView.bottomAnchor),
            composerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            blockedUserLabel.topAnchor.constraint(equalTo: blockedUserView.topAnchor, constant: CometChatSpacing.Padding.p2),
            blockedUserLabel.bottomAnchor.constraint(equalTo: blockedUserView.bottomAnchor, constant: -CometChatSpacing.Padding.p2),
            blockedUserLabel.leadingAnchor.constraint(equalTo: blockedUserView.leadingAnchor, constant: CometChatSpacing.Padding.p5),
            blockedUserLabel.trailingAnchor.constraint(equalTo: blockedUserView.trailingAnchor, constant: -CometChatSpacing.Padding.p5)
        ])
        
        blockedUserLabel.text = "\("SEND_MESSAGE_ERROR_TO_BLOCK_USER".localize()) \(user?.name ?? "")"
        
        if user?.blockedByMe == true{
            self.composerView.removeFromSuperview()
        }
    }
}

