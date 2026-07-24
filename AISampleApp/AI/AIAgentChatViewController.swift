//
//  AIAgentChatViewController.swift
//  CometChatAISampleApp
//
//  The agentic (user.isAgentic == true) path of master-app's MessagesVC,
//  extracted as a standalone chat screen. Every user shown by this app is an
//  AI agent (role "@agentic"), so the agentic branches apply unconditionally.
//

import UIKit
import CometChatSDK
import CometChatUIKitSwift

class AIAgentChatViewController: UIViewController {

    var user: User?
    var parentMessage: BaseMessage? = nil
    var withParent: Bool = false
    /// When `true`, an agent chat opens fresh even if a previous conversation exists.
    /// Set this on the "New Chat" entry points so they behave like starting a brand new
    /// session.
    var isNewChat: Bool = false
    public var aiOptionSelected: String?
    var targetMessageId: Int?
    lazy var randamID = Date().timeIntervalSince1970

    //Setting Up header
    lazy var headerView: CometChatMessageHeader = {
        let headerView = CometChatMessageHeader()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        if let user = user { headerView.set(user: user) }
        headerView.set(controller: self) //passing controller needs to be mandatory

        // Custom back navigation for AI agents - go directly to the AI Agents home
        headerView.hideBackButton = false
        headerView.set(onBack: { [weak self] in
            guard let self = self,
                  let navController = self.navigationController else { return }

            // Find AIAgentsHomeViewController in the navigation stack and pop to it
            if let homeVC = navController.viewControllers.first(where: { $0 is AIAgentsHomeViewController }) {
                navController.popToViewController(homeVC, animated: true)
            } else {
                // Fallback to standard back navigation
                navController.popViewController(animated: true)
            }
        })

        headerView.onAiNewChatClicked = { [weak self] user in
            guard let self = self, let navController = self.navigationController else { return }

            let filteredStack = navController.viewControllers.filter {
                !($0 is AIAgentChatViewController) && !($0 is CometChatAIAssistanceChatHistory)
            }
            navController.setViewControllers(filteredStack, animated: false)

            let newChatVC = AIAgentChatViewController()
            newChatVC.parentMessage = nil
            newChatVC.user = user
            newChatVC.withParent = false
            newChatVC.isNewChat = true
            navController.pushViewController(newChatVC, animated: false)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak navController] in
                guard let nav = navController else { return }

                var stack = nav.viewControllers
                if let lastChatIndex = stack.lastIndex(where: { $0 is AIAgentChatViewController }) {
                    stack = stack.enumerated().filter { index, vc in
                        !(vc is AIAgentChatViewController && index != lastChatIndex) && !(vc is CometChatAIAssistanceChatHistory)
                    }.map { $0.element }

                    nav.setViewControllers(stack, animated: false)
                }
            }
        }

        headerView.onAiChatHistoryClicked = { [weak self] user in
            let vc = CometChatAIAssistanceChatHistory()
            vc.user = user
            vc.onMessageClicked = { baseMessage in
                let selfVC = vc

                if let navController = selfVC.navigationController {
                    var filteredStack = navController.viewControllers.filter { !($0 is AIAgentChatViewController) }

                    if let lastHistoryIndex = filteredStack.lastIndex(where: { $0 is CometChatAIAssistanceChatHistory }) {
                        filteredStack = filteredStack.enumerated().filter { index, viewController in
                            !(viewController is CometChatAIAssistanceChatHistory && index != lastHistoryIndex)
                        }.map { $0.element }
                    }

                    navController.setViewControllers(filteredStack, animated: false)
                }

                let threadedView = AIAgentChatViewController()
                threadedView.parentMessage = baseMessage
                threadedView.user = user
                threadedView.withParent = true
                selfVC.navigationController?.pushViewController(threadedView, animated: true)
            }

            vc.onNewChatButtonClicked = { user in

                if let navController = vc.navigationController {
                    var filteredStack = navController.viewControllers.filter { !($0 is AIAgentChatViewController) }

                    if let lastHistoryIndex = filteredStack.lastIndex(where: { $0 is CometChatAIAssistanceChatHistory }) {
                        filteredStack = filteredStack.enumerated().filter { index, viewController in
                            !(viewController is CometChatAIAssistanceChatHistory && index != lastHistoryIndex)
                        }.map { $0.element }
                    }

                    navController.setViewControllers(filteredStack, animated: false)
                }

                let freshChatVC = AIAgentChatViewController()
                freshChatVC.parentMessage = nil
                freshChatVC.user = user
                freshChatVC.withParent = false
                freshChatVC.isNewChat = true
                vc.navigationController?.pushViewController(freshChatVC, animated: false)
            }
            self?.navigationController?.pushViewController(vc, animated: false)
        }

        return headerView
    }()

    lazy var messageListView: CometChatMessageList = {

        let messageListView = CometChatMessageList(frame: .null)
        messageListView.translatesAutoresizingMaskIntoConstraints = false
        if let user = user {
            // Only opt into loading the previous agent conversation when:
            //   - the conversation is with an AI agent
            //   - we aren't already opening a specific thread (chat history)
            //   - the caller didn't explicitly request a fresh "New Chat"
            let shouldLoadLastAgentConversation = user.isAgentic && !self.withParent && !self.isNewChat
            messageListView.set(loadLastAgentConversation: shouldLoadLastAgentConversation)
            messageListView.set(user: user, parentMessage: parentMessage, withParent: self.withParent)
        }
        messageListView.set(controller: self)

        //adding tap gesture on mention click
        let mentionsFormatter = CometChatMentionsFormatter()
        mentionsFormatter.set { [weak self] message, uid, controller in
            let messageVC = AIAgentChatViewController()
            if let tappedUser = message.mentionedUsers.first(where: { $0.uid == uid }) {
                messageVC.user = tappedUser
                if CometChat.getLoggedInUser()?.uid != tappedUser.uid{
                    self?.navigationController?.pushViewController(messageVC, animated: true)
                }
            }
        }
        messageListView.onAIOptionSelected = { [weak self] option in
            self?.aiOptionSelected = option
            self?.composer.set(aiOptionsText: option)
        }
        messageListView.onLastAgentConversationLoaded = { [weak self] parentMessageId in
            self?.composer.set(parentMessageId: parentMessageId)
        }
        messageListView.set(textFormatters: [mentionsFormatter])

        // Agentic bubble styling (exact master-app overrides)
        messageListView.messageBubbleStyle.outgoing.textBubbleStyle.textColor = CometChatTheme.neutralColor900
        messageListView.messageBubbleStyle.outgoing.textBubbleStyle.backgroundColor = CometChatTheme.neutralColor300
        messageListView.messageBubbleStyle.outgoing.dateStyle.textColor = CometChatTheme.neutralColor600

        messageListView.showMarkAsUnreadOption = true
        messageListView.startFromUnreadMessages = true
        return messageListView
    }()

    // Agentic chats use the full CometChatMessageComposer (NOT the compact one):
    // it is the composer that receives set(aiOptionsText:) / set(parentMessageId:).
    lazy var composer: CometChatMessageComposer = {
        let messageComposer = CometChatMessageComposer(frame: .null)
        if let user = user { messageComposer.set(user: user) }
        messageComposer.set(controller: self)
        if let mssg = parentMessage {
            messageComposer.set(parentMessageId: mssg.id)
        }
        messageComposer.translatesAutoresizingMaskIntoConstraints = false
        return messageComposer
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        buildUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        CometChatUIEvents.addListener("ai-chat-ui-event-listener-\(randamID)", self)
        CometChatUserEvents.addListener("ai-chat-user-event-listener-\(randamID)", self)

        if let targetId = targetMessageId {
            messageListView.goToMessage(withId: targetId)
            self.targetMessageId = nil
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self // for swipe back gesture
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        navigationItem.hidesBackButton = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        // Show navigation bar when leaving, except when pushing to another chat VC
        let topVC = self.navigationController?.viewControllers.last
        let isPushingToChatVC = topVC is AIAgentChatViewController && topVC !== self

        if !isPushingToChatVC {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        // Only restore navigation bar when popping back
        if self.isMovingFromParent || self.isBeingDismissed {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }

    deinit {
        CometChatUIEvents.removeListener("ai-chat-ui-event-listener-\(randamID)")
        CometChatUserEvents.removeListener("ai-chat-user-event-listener-\(randamID)")
    }

    // MARK: - Layout

    func buildUI() {

        self.view.backgroundColor = CometChatTheme.backgroundColor01

        view.addSubview(headerView)
        view.addSubview(messageListView)
        view.addSubview(composer)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            messageListView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            messageListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageListView.bottomAnchor.constraint(equalTo: composer.topAnchor),

            composer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            composer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            composer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

//MARK: - HANDLING BACK GESTURE AND UI EVENT -
extension AIAgentChatViewController: CometChatUIEventListener, UIGestureRecognizerDelegate {

    func openChat(user: User?, group: Group?) {
        let chat = AIAgentChatViewController()
        chat.user = user
        self.navigationController?.pushViewController(chat, animated: true)
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: - HANDLING USER EVENTS -
extension AIAgentChatViewController: CometChatUserEventListener {
}
