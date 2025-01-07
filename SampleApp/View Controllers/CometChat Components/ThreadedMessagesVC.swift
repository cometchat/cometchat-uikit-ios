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
    
    lazy var parentMessageView: CometChatThreadedMessageHeader = {
        let parentMessageContainerView = CometChatThreadedMessageHeader()
        parentMessageContainerView.translatesAutoresizingMaskIntoConstraints = false
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
        messageListView.setOnThreadRepliesClick { [weak self] message, messageBubbleView in
            guard let this = self else { return }
        }
        messageListView.translatesAutoresizingMaskIntoConstraints = false
        return messageListView
    }()
    
    lazy var composerView: CometChatMessageComposer = {
        let messageComposer = CometChatMessageComposer(frame: .null)
        
        //Checking for the group or other user
        if let group = parentMessage?.receiver as? Group {
            messageComposer.set(group: group)
        } else if let user = (parentMessage?.senderUid == CometChat.getLoggedInUser()?.uid ? parentMessage?.receiver : parentMessage?.sender) as? User {
            messageComposer.set(user: user)
        }
        
        messageComposer.set(parentMessageId: parentMessage?.id ?? 0)
        messageComposer.set(controller: self)
        messageComposer.translatesAutoresizingMaskIntoConstraints = false
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
        buildUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.hidesBackButton = true
        
        let navigationBarView = UIView()
        navigationBarView.translatesAutoresizingMaskIntoConstraints = false
        navigationBarView.isUserInteractionEnabled = true // Ensure the view is interactive
        
        // Back Button
        let backButton = UIButton(type: .custom)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.isUserInteractionEnabled = true
        let backImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        backButton.setImage(backImage, for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.tintColor = CometChatTheme.primaryColor
        backButton.addTarget(self, action: #selector(onBackButtonTapped), for: .touchUpInside)
        navigationBarView.addSubview(backButton)
        
        // Add constraints for back button
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: navigationBarView.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: navigationBarView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 24),  // Standard width
        ])
        
        // View after back button
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 1
        
        // Title Label
        let title = UILabel()
        title.text = "Thread"
        title.textColor = CometChatTheme.textColorPrimary
        title.font = CometChatTypography.Heading4.bold
        stackView.addArrangedSubview(title)
        
        // Subtitle Label
        let subtitle = UILabel()
        subtitle.text = (((parentMessage?.receiver as? User)?.name) ?? ((parentMessage?.receiver as? Group)?.name) ?? "")
        subtitle.textColor = CometChatTheme.textColorSecondary
        subtitle.font = CometChatTypography.Caption1.regular
        stackView.addArrangedSubview(subtitle)
        
        navigationBarView.addSubview(stackView)
        
        // Add constraints for stackView
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            stackView.centerYAnchor.constraint(equalTo: navigationBarView.centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: navigationBarView.trailingAnchor)
        ])
        
        // Set the height of the navigationBarView
        NSLayoutConstraint.activate([
            navigationBarView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        let leftItem = UIBarButtonItem(customView: navigationBarView)
        navigationItem.leftBarButtonItem = leftItem
        
        // Log taps to ensure action is firing
        backButton.addTarget(self, action: #selector(logTap), for: .touchUpInside)
    }

    @objc func logTap() {
        print("Back button tapped")
    }

    @objc func onBackButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    
    func buildUI() {
        
        self.view.backgroundColor = .systemBackground
        
        view.addSubview(parentMessageView)
        view.addSubview(messageListView)
        view.addSubview(composerView)
        view.addSubview(blockedUserView)
        view.addSubview(composerView)
        blockedUserView.addSubview(blockedUserLabel)
        
        NSLayoutConstraint.activate([
            parentMessageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
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
        
        blockedUserLabel.text = "Can’t send a message to blocked \(user?.name ?? "")"
        
        if user?.blockedByMe == true{
            self.composerView.removeFromSuperview()
        }
    }
}
